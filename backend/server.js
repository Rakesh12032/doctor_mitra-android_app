const http = require("http");
const fs = require("fs");
const path = require("path");
const {
  now,
  seedState,
  normalizeState,
  validateState,
  applyAction,
  readJsonBody,
  sendJson,
  sendError
} = require("./lib/doctorMitraCore");

const port = Number(process.env.PORT || 8080);
const dataDir = process.env.DATA_DIR || path.join(__dirname, "data");
const dataFile = path.join(dataDir, "doctor_mitra_state.json");

function ensureState() {
  fs.mkdirSync(dataDir, { recursive: true });
  if (!fs.existsSync(dataFile)) {
    fs.writeFileSync(dataFile, JSON.stringify(seedState(), null, 2));
  }
}

function readState() {
  ensureState();
  return normalizeState(JSON.parse(fs.readFileSync(dataFile, "utf8")));
}

function writeState(state) {
  const normalized = validateState(state);
  fs.mkdirSync(dataDir, { recursive: true });
  fs.writeFileSync(dataFile, JSON.stringify(normalized, null, 2));
  return normalized;
}

const server = http.createServer(async (req, res) => {
  if (req.method === "OPTIONS") {
    sendJson(res, 204, {});
    return;
  }

  try {
    const url = new URL(req.url, `http://${req.headers.host || "localhost"}`);

    if (req.method === "GET" && url.pathname === "/health") {
      sendJson(res, 200, { ok: true, service: "doctor-mitra-api", storage: "file", time: now() });
      return;
    }

    if (req.method === "GET" && url.pathname === "/api/state") {
      sendJson(res, 200, readState());
      return;
    }

    if (req.method === "PUT" && url.pathname === "/api/state") {
      const state = writeState(await readJsonBody(req));
      sendJson(res, 200, { ok: true, updatedAt: state.updatedAt });
      return;
    }

    if (req.method === "POST" && url.pathname === "/api/actions") {
      const action = await readJsonBody(req);
      const result = applyAction(readState(), action);
      writeState(result.state);
      sendJson(res, 200, result);
      return;
    }

    if (req.method === "POST" && (url.pathname === "/api/reset" || url.pathname === "/api/state")) {
      const state = writeState(seedState());
      sendJson(res, 200, state);
      return;
    }

    sendJson(res, 404, { ok: false, error: "Not found" });
  } catch (error) {
    sendError(res, error);
  }
});

server.listen(port, () => {
  ensureState();
  console.log(`Doctor Mitra API running on port ${port}`);
});
