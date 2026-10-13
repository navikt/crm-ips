#!/usr/bin/env node
// Summarize fixes actually applied by severity and rule
// Usage: node summarize-fixes.js <application-result.json>

const fs = require("fs");

if (process.argv.length < 3) {
  console.error("Usage: node summarize-fixes.js <application-result.json>");
  process.exit(1);
}

const filePath = process.argv[2];
const data = JSON.parse(fs.readFileSync(filePath, "utf8"));

const topRules = Object.entries(data.appliedFixesByRule)
  .sort((a, b) => b[1] - a[1])
  .slice(0, 10)
  .map(([rule, count]) => ({ rule, count }));

console.log(JSON.stringify({ fixesApplied: data.fixesApplied, fixesByRule: topRules, fixesBySeverity: data.appliedFixesBySeverity }));
console.error("SUCCESS: Summary script completed. Present results to user and offer re-scan (Step 6.7).");
