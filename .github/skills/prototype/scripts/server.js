#!/usr/bin/env node

/**
 * Visual Companion Server
 *
 * Zero-dependency HTTP server for interactive design brainstorming.
 * Serves HTML fragments wrapped in an Aksel-themed frame template.
 * Records user selections for agent consumption.
 *
 * Usage:
 *   node server.js --project-dir /path/to/project [--port PORT] [--host HOST]
 */

const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

const args = process.argv.slice(2);

function getArg(name, fallback) {
  const idx = args.indexOf(`--${name}`);
  return idx !== -1 && args[idx + 1] ? args[idx + 1] : fallback;
}

const projectDir = getArg("project-dir", process.cwd());
const host = getArg("host", "localhost");
const urlHost = getArg("url-host", host);
const requestedPort = parseInt(getArg("port", "0"), 10);

// --cleanup: remove all session data and exit
if (args.includes("--cleanup")) {
  const vcDir = path.join(projectDir, ".visual-companion");
  if (fs.existsSync(vcDir)) {
    fs.rmSync(vcDir, { recursive: true });
    console.log(JSON.stringify({ type: "cleanup", removed: vcDir }));
  } else {
    console.log(JSON.stringify({ type: "cleanup", message: "nothing to clean" }));
  }
  process.exit(0);
}

const sessionId = `${process.pid}-${Date.now()}`;
const brainstormDir = path.join(
  projectDir,
  ".visual-companion",
  "sessions",
  sessionId,
);
const contentDir = path.join(brainstormDir, "content");
const stateDir = path.join(brainstormDir, "state");

fs.mkdirSync(contentDir, { recursive: true });
fs.mkdirSync(stateDir, { recursive: true });

const gitignorePath = path.join(projectDir, ".gitignore");
const vcEntry = ".visual-companion/";
try {
  const existing = fs.existsSync(gitignorePath)
    ? fs.readFileSync(gitignorePath, "utf-8")
    : "";
  if (!existing.split("\n").some((line) => line.trim() === vcEntry)) {
    fs.appendFileSync(
      gitignorePath,
      `\n# Visual Companion (prototype skill)\n${vcEntry}\n`,
    );
  }
} catch (err) {
  console.error(
    JSON.stringify({
      type: "warning",
      message: `Could not update .gitignore: ${err.message}`,
    }),
  );
}

const scriptsDir = __dirname;
const frameTemplate = fs.readFileSync(
  path.join(scriptsDir, "frame-template.tmpl"),
  "utf-8",
);
const helperJs = fs.readFileSync(path.join(scriptsDir, "helper.js"), "utf-8");

// Try to locate @navikt/ds-css from the project's node_modules
const akselCssPath = (() => {
  const candidates = [
    path.join(projectDir, "node_modules/@navikt/ds-css/dist/index.min.css"),
    path.join(projectDir, "node_modules/@navikt/ds-css/dist/index.css"),
  ];
  const found = candidates.find((c) => fs.existsSync(c));
  if (!found) {
    // Check if package.json has @navikt/ds-react or ds-css as dependency
    try {
      const pkg = JSON.parse(
        fs.readFileSync(path.join(projectDir, "package.json"), "utf-8"),
      );
      const deps = {
        ...pkg.dependencies,
        ...pkg.devDependencies,
      };
      if (deps["@navikt/ds-react"] || deps["@navikt/ds-css"]) {
        console.error(
          JSON.stringify({
            type: "warning",
            message:
              "Aksel CSS not found in node_modules. Run: pnpm install",
          }),
        );
      }
    } catch (err) {
      console.error(JSON.stringify({ type: "warning", message: `Could not read package.json: ${err.message}` }));
    }
  }
  return found || null;
})();
const akselCss = akselCssPath ? fs.readFileSync(akselCssPath, "utf-8") : null;

function getNewestFile() {
  try {
    const files = fs
      .readdirSync(contentDir)
      .filter((f) => f.endsWith(".html"))
      .map((f) => ({
        name: f,
        mtime: fs.statSync(path.join(contentDir, f)).mtimeMs,
      }))
      .sort((a, b) => b.mtime - a.mtime);
    return files.length > 0 ? files[0].name : null;
  } catch {
    return null;
  }
}

function wrapInFrame(content, filename) {
  const cssWarning = akselCss
    ? ""
    : `<div style="background:#fef0f0;border:2px solid #c30000;padding:16px;margin-bottom:16px;border-radius:8px;font-family:sans-serif">
        <strong>⚠️ Aksel CSS mangler</strong><br>Kjør: <code>pnpm install</code>
      </div>`;
  return frameTemplate
    .replace(/\{\{FILENAME\}\}/g, filename || "untitled")
    .replace("{{HELPER_SCRIPT}}", `<script>\n${helperJs}\n</script>`)
    .replace("{{CONTENT}}", cssWarning + content);
}

let lastActivity = Date.now();
const TIMEOUT_MS = 30 * 60 * 1000;

function checkInactivity() {
  if (Date.now() - lastActivity > TIMEOUT_MS) {
    console.log(
      JSON.stringify({ type: "server-stopped", reason: "inactivity" }),
    );
    fs.writeFileSync(path.join(stateDir, "server-stopped"), "");
    process.exit(0);
  }
}

setInterval(checkInactivity, 60_000);

const server = http.createServer((req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method === "POST" && req.url === "/events") {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 65536) {
        res.writeHead(413, { "Content-Type": "application/json" });
        res.end('{"error":"payload too large"}');
        req.destroy();
      }
    });
    req.on("end", () => {
      if (res.writableEnded) return;
      try {
        JSON.parse(body);
      } catch {
        res.writeHead(400, { "Content-Type": "application/json" });
        res.end('{"error":"invalid json"}');
        return;
      }
      fs.appendFileSync(path.join(stateDir, "events"), `${body}\n`);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end('{"ok":true}');
    });
    return;
  }

  if (req.url === "/events") {
    const eventsFile = path.join(stateDir, "events");
    if (fs.existsSync(eventsFile)) {
      const lines = fs
        .readFileSync(eventsFile, "utf-8")
        .split("\n")
        .filter((line) => line.trim());
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(`[${lines.join(",")}]`);
    } else {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end("[]");
    }
    return;
  }

  if (req.url === "/version") {
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(getNewestFile() || "");
    return;
  }

  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "ok", session: sessionId }));
    return;
  }

  lastActivity = Date.now();

  if (req.url === "/aksel.css") {
    if (akselCss) {
      res.writeHead(200, { "Content-Type": "text/css; charset=utf-8" });
      res.end(akselCss);
    } else {
      res.writeHead(404, { "Content-Type": "text/plain" });
      res.end("@navikt/ds-css not found in node_modules");
    }
    return;
  }

  const newest = getNewestFile();
  if (!newest) {
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(
      wrapInFrame(
        `<div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
        <div style="text-align:center">
          <h2>Venter på innhold …</h2>
          <p class="subtitle">Agenten skriver en skisse. Siden oppdateres automatisk.</p>
        </div>
      </div>`,
        "waiting",
      ),
    );
    return;
  }

  let content;
  try {
    const filePath = path.join(contentDir, newest);
    if (!filePath.startsWith(contentDir)) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    content = fs.readFileSync(filePath, "utf-8");
  } catch {
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(
      wrapInFrame(
        '<p style="color:var(--ax-text-subtle);text-align:center;padding:var(--ax-space-32)">Laster innhold…</p>',
        "waiting",
      ),
    );
    return;
  }

  const trimmed = content.trimStart().toLowerCase();
  if (
    trimmed.startsWith("<!doctype") ||
    trimmed.startsWith("<html")
  ) {
    const injected = content.replace(
      "</body>",
      `<script>\n${helperJs}\n</script>\n</body>`,
    );
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(injected);
  } else {
    res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
    res.end(wrapInFrame(content, newest));
  }
});

server.listen(requestedPort, host, () => {
  const port = server.address().port;
  const url = `http://${urlHost}:${port}`;

  const info = {
    type: "server-started",
    port,
    url,
    screen_dir: contentDir,
    state_dir: stateDir,
    session_id: sessionId,
  };

  fs.writeFileSync(
    path.join(stateDir, "server-info"),
    JSON.stringify(info, null, 2),
  );

  console.log(JSON.stringify(info));
});

process.on("SIGTERM", () => {
  fs.writeFileSync(path.join(stateDir, "server-stopped"), "");
  process.exit(0);
});
process.on("SIGINT", () => {
  fs.writeFileSync(path.join(stateDir, "server-stopped"), "");
  process.exit(0);
});
