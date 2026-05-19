const {
  STATE_KEY,
  seedState,
  normalizeState,
  validateState,
  readJsonBody,
  sendError
} = require("../lib/doctorMitraCore");

let memoryState = null;

async function redis() {
  if (!process.env.UPSTASH_REDIS_REST_URL || !process.env.UPSTASH_REDIS_REST_TOKEN) {
    return null;
  }
  const { Redis } = await import("@upstash/redis");
  return Redis.fromEnv();
}

async function readState() {
  const client = await redis();
  if (!client) {
    memoryState = normalizeState(memoryState || seedState());
    return memoryState;
  }

  const state = await client.get(STATE_KEY);
  if (state) return normalizeState(state);

  const seeded = seedState();
  await client.set(STATE_KEY, seeded);
  return seeded;
}

async function writeState(state) {
  const normalized = validateState(state);
  const client = await redis();

  if (!client) {
    memoryState = normalized;
    return normalized;
  }

  await client.set(STATE_KEY, normalized);
  return normalized;
}

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, PUT, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).end();
    return;
  }

  try {
    if (req.method === "GET") {
      res.status(200).json(await readState());
      return;
    }

    if (req.method === "PUT") {
      const body = await readJsonBody(req);
      const state = await writeState(body);
      res.status(200).json({ ok: true, updatedAt: state.updatedAt });
      return;
    }

    if (req.method === "POST") {
      const seeded = await writeState(seedState());
      res.status(200).json(seeded);
      return;
    }

    res.status(405).json({ ok: false, error: "Method not allowed" });
  } catch (error) {
    sendError(res, error);
  }
};

module.exports.readState = readState;
module.exports.writeState = writeState;
