const { execSync } = require('child_process');
const fs = require('fs');
const readline = require('readline');
const path = require('path');

const sfdxProjectPath = path.join(__dirname, '..', 'sfdx-project.json');
const sfdxBackupPath = sfdxProjectPath + '.backup';
const sfdxProject = JSON.parse(fs.readFileSync(sfdxProjectPath, 'utf-8'));

// Configuration
const TIMEOUT_MS = 120000; // 2 minutes per command
const MAX_RETRIES = 2;
const RETRY_DELAY_MS = 5000; // 5 seconds between retries

// Strip VS Code / debugger injections so child sf processes start cleanly
const childEnv = { ...process.env, NODE_OPTIONS: '' };

// Validation helpers
function isValidPackageId(id) {
    return /^0Ho[a-zA-Z0-9]{12,15}$/.test(id);
}

function isValidVersionString(version) {
    return /^\d+\.\d+\.\d+$/.test(version);
}

function sleep(ms) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);
}

function runWithRetry(command, retries = MAX_RETRIES) {
    for (let attempt = 0; attempt <= retries; attempt++) {
        try {
            return execSync(command, {
                encoding: 'utf-8',
                stdio: ['pipe', 'pipe', 'pipe'],
                timeout: TIMEOUT_MS,
                env: childEnv
            });
        } catch (err) {
            if (attempt < retries && (err.message.includes('ETIMEDOUT') || err.message.includes('TIMEOUT'))) {
                console.log(`    ⏳ Timeout, retrying (${attempt + 1}/${retries})...`);
                sleep(RETRY_DELAY_MS);
            } else {
                throw err;
            }
        }
    }
}

// Get all dependencies from packageDirectories
const deps = sfdxProject.packageDirectories.filter((dir) => dir.dependencies).flatMap((dir) => dir.dependencies);

const aliases = sfdxProject.packageAliases || {};
const updatesAvailable = [];

// Verify SF CLI is authenticated
try {
    execSync('sf org list --json', {
        encoding: 'utf-8',
        stdio: ['pipe', 'pipe', 'pipe'],
        timeout: TIMEOUT_MS,
        env: childEnv
    });
} catch (err) {
    console.error('\n❌ SF CLI not authenticated or not installed. Run: sf org login devhub\n');
    process.exit(1);
}

console.log(`\n${'Package Name'.padEnd(40)} ${'Current'.padEnd(15)} ${'Latest Released'}`);
console.log('-'.repeat(80));

for (const dep of deps) {
    const pkgName = dep.package;
    const currentVersion = dep.versionNumber.replace('.LATEST', '').replace('.NEXT', '');
    const packageId = aliases[pkgName];

    if (!packageId) {
        console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} NO ALIAS FOUND`);
        continue;
    }

    if (!isValidPackageId(packageId)) {
        console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} INVALID PACKAGE ID`);
        continue;
    }

    try {
        const result = runWithRetry(
            `sf package version list --packages ${packageId} --released --order-by CreatedDate --json`
        );
        const json = JSON.parse(result);
        const versions = json.result || [];
        const latest = versions[versions.length - 1];

        if (latest) {
            const latestVersion = `${latest.MajorVersion}.${latest.MinorVersion}.${latest.PatchVersion}`;

            if (!isValidVersionString(latestVersion)) {
                console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} INVALID VERSION FORMAT`);
                continue;
            }

            const outdated = currentVersion !== latestVersion;
            const status = outdated ? ' ⚠️  UPDATE AVAILABLE' : ' ✅';
            console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} ${latestVersion}${status}`);

            if (outdated) {
                updatesAvailable.push({
                    packageName: pkgName,
                    currentVersion: currentVersion,
                    latestVersion: latestVersion
                });
            }
        } else {
            console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} NO RELEASED VERSION`);
        }
    } catch (err) {
        const errorMsg = err.message.includes('ETIMEDOUT') ? 'TIMEOUT (try again later)' : err.message.split('\n')[0];
        console.log(`${pkgName.padEnd(40)} ${currentVersion.padEnd(15)} ERROR: ${errorMsg}`);
    }
}

// ...existing code... (rest of file stays the same)
// After checking, ask user if they want to update
if (updatesAvailable.length === 0) {
    console.log('\n✅ All packages are up to date!\n');
    process.exit(0);
}

console.log(`\n⚠️  ${updatesAvailable.length} package(s) have updates available:\n`);
updatesAvailable.forEach((u, i) => {
    console.log(`  ${i + 1}. ${u.packageName}: ${u.currentVersion} → ${u.latestVersion}`);
});

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('\nDo you want to update sfdx-project.json? (YES/NO): ', (answer) => {
    if (answer.trim().toUpperCase() === 'YES') {
        try {
            updateSfdxProject(updatesAvailable);
            console.log('\n✅ sfdx-project.json has been updated!\n');
            console.log('Updated packages:');
            updatesAvailable.forEach((u) => {
                console.log(`  ✅ ${u.packageName}: ${u.currentVersion} → ${u.latestVersion}`);
            });
            console.log(`\n💾 Backup saved to: ${sfdxBackupPath}`);
        } catch (err) {
            console.error(`\n❌ Error updating file: ${err.message}`);
            if (fs.existsSync(sfdxBackupPath)) {
                fs.copyFileSync(sfdxBackupPath, sfdxProjectPath);
                console.log('🔄 Restored from backup.');
            }
        }
    } else {
        console.log('\n❌ No changes made to sfdx-project.json\n');
    }
    rl.close();
});

function updateSfdxProject(updates) {
    const projectData = JSON.parse(fs.readFileSync(sfdxProjectPath, 'utf-8'));
    fs.copyFileSync(sfdxProjectPath, sfdxBackupPath);

    for (const update of updates) {
        if (!isValidVersionString(update.latestVersion)) {
            throw new Error(`Invalid version format for ${update.packageName}: ${update.latestVersion}`);
        }

        for (const dir of projectData.packageDirectories) {
            if (!dir.dependencies) continue;

            for (const dep of dir.dependencies) {
                if (dep.package === update.packageName) {
                    dep.versionNumber = update.latestVersion + '.LATEST';
                }
            }
        }
    }

    fs.writeFileSync(sfdxProjectPath, JSON.stringify(projectData, null, 4) + '\n', 'utf-8');
}
