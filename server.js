// server.js
import express from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import { spawn } from "node:child_process";

const PORT = Number(process.env.PORT || 8080);        // Render-provided
const MCP_PORT = Number(process.env.MCP_PORT || 9000); // Internal MCP port

const app = express();

// Simple health for Render
app.get("/health", (_req, res) => {
  res.status(200).send("ok");
});

// Start MCP as a child process on MCP_PORT
// It will read APP_ID, APP_SECRET, LARK_MCP_TOOLS etc. from env automatically.
const mcpArgs = [
  "-y",
  "@larksuiteoapi/lark-mcp",
  "start",
  "--port",
  String(MCP_PORT),
];
// Optional: add verbose logs if you want
if (process.env.MCP_DEBUG === "1") mcpArgs.push("--verbose");

const mcp = spawn("npx", mcpArgs, {
  stdio: "inherit",
  env: {
    ...process.env,
    PORT: String(MCP_PORT), // ensure no library accidentally reads PORT
  },
});

mcp.on("exit", (code, signal) => {
  console.error(`[mcp] exited code=${code} signal=${signal}`);
  // If MCP dies, exit so Render restarts the service
  process.exit(code ?? 1);
});

// Proxy everything except /health to MCP
app.use(
  "/",
  createProxyMiddleware({
    target: `http://127.0.0.1:${MCP_PORT}`,
    changeOrigin: false,
    ws: false,
    followRedirects: true,
  })
);

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[web] listening on ${PORT}, proxying to MCP at ${MCP_PORT}`);
});
