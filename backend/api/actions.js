const { applyAction, readJsonBody, sendError } = require("../lib/doctorMitraCore");
const { readState, writeState } = require("./state");

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.status(204).end();
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ ok: false, error: "Method not allowed" });
    return;
  }

  try {
    const body = await readJsonBody(req);
    const current = await readState();
    const result = applyAction(current, body);
    await writeState(result.state);
    res.status(200).json(result);
  } catch (error) {
    sendError(res, error);
  }
};
