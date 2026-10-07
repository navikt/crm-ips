#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SFDX_PROJECT_PATH="$REPO_ROOT/sfdx-project.json"
SFDX_BACKUP_PATH="$SFDX_PROJECT_PATH.backup"

TIMEOUT_SECONDS=120
MAX_RETRIES=2
RETRY_DELAY_SECONDS=5

updates_available=()

is_valid_package_id() {
    [[ "$1" =~ ^0Ho[a-zA-Z0-9]{12,15}$ ]]
}

is_valid_version_string() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "❌ Required command not found: $1"
        exit 1
    fi
}

run_with_timeout() {
    perl -e 'alarm shift; exec @ARGV' "$TIMEOUT_SECONDS" "$@"
}

run_with_retry() {
    local attempt output status

    for ((attempt = 0; attempt <= MAX_RETRIES; attempt++)); do
        if output=$(run_with_timeout "$@" 2>&1); then
            printf '%s' "$output"
            return 0
        fi

        status=$?
        if (( attempt < MAX_RETRIES )) && [[ "$output" == *"Alarm clock"* || "$output" == *"timed out"* || "$output" == *"ETIMEDOUT"* ]]; then
            printf '    ⏳ Timeout, retrying (%d/%d)...\n' "$((attempt + 1))" "$MAX_RETRIES"
            sleep "$RETRY_DELAY_SECONDS"
        else
            printf '%s' "$output" >&2
            return "$status"
        fi
    done
}

read_project_dependencies() {
    osascript -l JavaScript <<'JXA' "$SFDX_PROJECT_PATH"
ObjC.import('Foundation');

function readFile(path) {
    const filePath = $(NSString).stringWithUTF8String(path);
    const data = $.NSData.dataWithContentsOfFile(filePath);
    return ObjC.unwrap($.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding));
}

const args = $.NSProcessInfo.processInfo.arguments;
const projectPath = ObjC.unwrap(args.objectAtIndex(4));
const project = JSON.parse(readFile(projectPath));
const aliases = project.packageAliases || {};
const lines = [];

(project.packageDirectories || []).forEach((dir) => {
    (dir.dependencies || []).forEach((dep) => {
        lines.push([dep.package || '', dep.versionNumber || '', aliases[dep.package] || ''].join('\t'));
    });
});

console.log(lines.join('\n'));
JXA
}

latest_version_from_result() {
    osascript -l JavaScript <<'JXA'
ObjC.import('Foundation');

const input = ObjC.unwrap(
    $.NSString.alloc.initWithDataEncoding(
        $.NSFileHandle.fileHandleWithStandardInput.readDataToEndOfFile,
        $.NSUTF8StringEncoding
    )
);

const parsed = JSON.parse(input);
const versions = parsed.result || [];
if (!versions.length) {
    console.log('');
} else {
    const latest = versions[versions.length - 1];
    console.log([latest.MajorVersion, latest.MinorVersion, latest.PatchVersion].join('.'));
}
JXA
}

update_sfdx_project() {
    local updates_payload
    updates_payload="$1"

    cp "$SFDX_PROJECT_PATH" "$SFDX_BACKUP_PATH"

    UPDATES_PAYLOAD="$updates_payload" osascript -l JavaScript <<'JXA' "$SFDX_PROJECT_PATH"
ObjC.import('Foundation');

function readFile(path) {
    const filePath = $(NSString).stringWithUTF8String(path);
    const data = $.NSData.dataWithContentsOfFile(filePath);
    return ObjC.unwrap($.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding));
}

function writeFile(path, content) {
    const filePath = $(NSString).stringWithUTF8String(path);
    const text = $(NSString).stringWithUTF8String(content);
    text.writeToFileAtomicallyEncodingError(filePath, true, $.NSUTF8StringEncoding, null);
}

const args = $.NSProcessInfo.processInfo.arguments;
const projectPath = ObjC.unwrap(args.objectAtIndex(4));
const updatesPayload = $.getenv('UPDATES_PAYLOAD');
const updates = {};

ObjC.unwrap(updatesPayload)
    .split('\n')
    .filter(Boolean)
    .forEach((line) => {
        const parts = line.split('\t');
        if (parts.length === 2) {
            updates[parts[0]] = parts[1];
        }
    });

const project = JSON.parse(readFile(projectPath));
(project.packageDirectories || []).forEach((dir) => {
    (dir.dependencies || []).forEach((dep) => {
        if (updates[dep.package]) {
            dep.versionNumber = updates[dep.package] + '.LATEST';
        }
    });
});

writeFile(projectPath, JSON.stringify(project, null, 4) + '\n');
JXA
}

require_command sf
require_command osascript
require_command perl

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This script is intended for macOS."
    exit 1
fi

if [[ ! -f "$SFDX_PROJECT_PATH" ]]; then
    echo "❌ Could not find sfdx-project.json at $SFDX_PROJECT_PATH"
    exit 1
fi

cd "$REPO_ROOT"

if ! run_with_retry sf org list --json >/dev/null; then
    echo
    echo "❌ SF CLI not authenticated or not installed. Run: sf org login devhub"
    echo
    exit 1
fi

printf '\n%-40s %-15s %s\n' 'Package Name' 'Current' 'Latest Released'
printf '%s\n' '--------------------------------------------------------------------------------'

while IFS=$'\t' read -r package_name version_number package_id; do
    [[ -z "$package_name" ]] && continue

    current_version="${version_number%.LATEST}"
    current_version="${current_version%.NEXT}"

    if [[ -z "$package_id" ]]; then
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" 'NO ALIAS FOUND'
        continue
    fi

    if ! is_valid_package_id "$package_id"; then
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" 'INVALID PACKAGE ID'
        continue
    fi

    if ! result=$(run_with_retry sf package version list --packages "$package_id" --released --order-by CreatedDate --json); then
        error_msg='ERROR: command failed'
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" "$error_msg"
        continue
    fi

    latest_version=$(printf '%s' "$result" | latest_version_from_result)

    if [[ -z "$latest_version" ]]; then
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" 'NO RELEASED VERSION'
        continue
    fi

    if ! is_valid_version_string "$latest_version"; then
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" 'INVALID VERSION FORMAT'
        continue
    fi

    if [[ "$current_version" != "$latest_version" ]]; then
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" "$latest_version ⚠️  UPDATE AVAILABLE"
        updates_available+=("$package_name"$'\t'"$current_version"$'\t'"$latest_version")
    else
        printf '%-40s %-15s %s\n' "$package_name" "$current_version" "$latest_version ✅"
    fi
done < <(read_project_dependencies)

if (( ${#updates_available[@]} == 0 )); then
    echo
    echo '✅ All packages are up to date!'
    echo
    exit 0
fi

printf '\n⚠️  %d package(s) have updates available:\n\n' "${#updates_available[@]}"
for i in "${!updates_available[@]}"; do
    IFS=$'\t' read -r package_name current_version latest_version <<<"${updates_available[$i]}"
    printf '  %d. %s: %s → %s\n' "$((i + 1))" "$package_name" "$current_version" "$latest_version"
done

read -r -p $'\nDo you want to update sfdx-project.json? (YES/NO): ' answer
if [[ "${answer^^}" != 'YES' ]]; then
    echo
    echo '❌ No changes made to sfdx-project.json'
    echo
    exit 0
fi

updates_payload=''
for update in "${updates_available[@]}"; do
    IFS=$'\t' read -r package_name _ latest_version <<<"$update"
    if ! is_valid_version_string "$latest_version"; then
        echo
        echo "❌ Invalid version format for $package_name: $latest_version"
        exit 1
    fi
    updates_payload+="$package_name"$'\t'"$latest_version"$'\n'
done

if update_sfdx_project "$updates_payload"; then
    echo
    echo '✅ sfdx-project.json has been updated!'
    echo 'Updated packages:'
    for update in "${updates_available[@]}"; do
        IFS=$'\t' read -r package_name current_version latest_version <<<"$update"
        printf '  ✅ %s: %s → %s\n' "$package_name" "$current_version" "$latest_version"
    done
    echo
    echo "💾 Backup saved to: $SFDX_BACKUP_PATH"
else
    echo
    echo '❌ Error updating file.'
    if [[ -f "$SFDX_BACKUP_PATH" ]]; then
        cp "$SFDX_BACKUP_PATH" "$SFDX_PROJECT_PATH"
        echo '🔄 Restored from backup.'
    fi
    exit 1
fi