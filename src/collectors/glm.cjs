'use strict';

const { clampPct, failedWindows, fetchJson, isoBeijing } = require('../lib/common.cjs');

const QUOTA_URL = 'https://open.bigmodel.cn/api/monitor/usage/quota/limit';

function parseGlmLimits(payload) {
  const rows = payload && payload.data && payload.data.limits;
  if (!Array.isArray(rows)) throw new Error('GLM 响应中没有额度列表');
  const windows = [];
  for (const row of rows) {
    if (!row || !['TOKENS_LIMIT', 'TIME_LIMIT', 'CREDIT_LIMIT'].includes(row.type)) continue;
    const used = Number(row.percentage);
    if (!Number.isFinite(used)) continue;
    let name = '额度';
    if (row.type === 'TIME_LIMIT') name = 'MCP 月';
    else if (Number(row.unit) === 3) name = '5小时';
    else if (Number(row.unit) === 6) name = '周';
    else if (row.type === 'TOKENS_LIMIT') name = 'Token';
    const reset = Number(row.nextResetTime);
    windows.push({
      name,
      usedPct: clampPct(used),
      resetAt: Number.isFinite(reset) && reset > 0 ? isoBeijing(reset) : null,
    });
  }
  if (!windows.length) throw new Error('GLM 响应中没有可识别的额度');
  return windows;
}

async function collectGlm(config = {}) {
  const fetchedAt = isoBeijing();
  if (!config.enabled) return { ...failedWindows('GLM', '未启用', fetchedAt), disabled: true };
  const envName = String(config.apiKeyEnv || 'GLM_CODING_API_KEY');
  const key = String(process.env[envName] || '').trim();
  if (!key) return failedWindows('GLM', `没有设置环境变量 ${envName}`, fetchedAt);
  try {
    // Zhipu's own usage plugin sends the Coding Plan key as the raw Authorization value.
    const payload = await fetchJson(QUOTA_URL, {
      redirect: 'error',
      headers: { Authorization: key, Accept: 'application/json' },
    });
    if (payload && payload.success === false) throw new Error('GLM 用量查询失败');
    return { ok: true, label: 'GLM', windows: parseGlmLimits(payload), fetchedAt, error: null };
  } catch (error) {
    return failedWindows('GLM', String(error && error.message || error).replaceAll(key, '[已隐藏]'), fetchedAt);
  }
}

module.exports = { collectGlm, parseGlmLimits };
