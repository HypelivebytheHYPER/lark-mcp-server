import express from "express";
import { execa } from "execa";

const PORT = process.env.PORT ? Number(process.env.PORT) : 8080;
const APP_ID = process.env.APP_ID;
const APP_SECRET = process.env.APP_SECRET;
const LARK_DOMAIN = process.env.LARK_DOMAIN || "https://open.larksuite.com";
const TOOLS = (process.env.LARK_MCP_TOOLS || "").trim();

if (!APP_ID || !APP_SECRET) {
  console.error("[fatal] APP_ID and APP_SECRET are required");
  process.exit(1);
}

const app = express();

// Lightweight health endpoint for Render
app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true, service: "lark-mcp-server" });
});

const server = app.listen(PORT, "0.0.0.0", () => {
  console.log(`[health] listening on :${PORT} (GET /health)`);
  startMcp();
});

let child;

function buildArgs() {
  const args = [
    "@larksuiteoapi/lark-mcp",
    "mcp",
    "-a",
    APP_ID,
    "-s",
    APP_SECRET,
    "--transport",
    "sse",
    "--host",
    "0.0.0.0",
    "--port",
    String(PORT),
    "--domain",
    LARK_DOMAIN
  ];

  if (TOOLS) {
    // limit tools explicitly: comma-separated (e.g. "im.v1.message.create,calendar.v4.calendarEvent.create")
    args.push("-t", TOOLS);
  } else {
    // default preset
    args.push("--preset", "preset.default");
  }
  return args;
}

async function startMcp() {
  const cliArgs = buildArgs();
  const cmd = "npx";
  console.log("[mcp] starting:", cmd, cliArgs.join(" "));
  try {
    child = execa(cmd, cliArgs, {
      stdio: "inherit",
      env: process.env
    });

    child.on("exit", (code, signal) => {
      console.error(`[mcp] exited code=${code} signal=${signal}`);
      // Exit whole container so Render restarts it
      process.exit(code ?? 1);
    });

    child.on("error", (err) => {
      console.error("[mcp] error:", err);
      process.exit(1);
    });
  } catch (e) {
    console.error("[mcp] failed to start:", e);
    process.exit(1);
  }
}

// graceful shutdown
function shutdown() {
  console.log("[srv] shutting down...");
  server.close(() => {
    if (child && !child.killed) {
      child.kill("SIGTERM");
      setTimeout(() => process.exit(0), 1500);
    } else {
      process.exit(0);
    }
  });
}
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);