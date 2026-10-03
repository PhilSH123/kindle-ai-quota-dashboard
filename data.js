window.DASH_DATA = {
  "updatedAt": "2026-10-03T11:02:34.473+08:00",
  "weather": {
    "ok": true,
    "description": "晴",
    "iconKey": "clear",
    "tempC": 19.6,
    "feelsLikeC": 18.2,
    "humidity": 39,
    "windKph": 5.1,
    "windDir": "东南风",
    "place": "石家庄",
    "observedAt": "2026-10-03T11:00:00.000+08:00",
    "fetchedAt": "2026-10-03T11:02:29.163+08:00",
    "stale": false,
    "error": null
  },
  "quote": {
    "text": "海内存知己，天涯若比邻。",
    "source": "王勃《送杜少府之任蜀州》"
  },
  "sources": {
    "claude": {
      "ok": false,
      "label": "Claude",
      "windows": [],
      "fetchedAt": "2026-10-03T11:02:31.080+08:00",
      "error": "未启用",
      "disabled": true
    },
    "codex": {
      "ok": true,
      "label": "Codex",
      "windows": [
        {
          "name": "5小时",
          "usedPct": 13,
          "barPct": 87,
          "displayValue": "87%",
          "resetAt": "2026-10-03T04:16:57.000+08:00"
        },
        {
          "name": "周",
          "usedPct": 90,
          "barPct": 10,
          "displayValue": "10%",
          "resetAt": "2026-10-04T10:52:59.000+08:00"
        }
      ],
      "fetchedAt": "2026-10-02T23:22:24.657+08:00",
      "error": "failed to fetch codex rate limits: error sending request for url (https://chatgpt.com/backend-api/wham/usage)",
      "stale": true,
      "lastAttemptAt": "2026-10-03T11:02:31.081+08:00"
    },
    "kimi": {
      "ok": false,
      "label": "Kimi",
      "windows": [],
      "fetchedAt": "2026-10-03T11:02:31.474+08:00",
      "error": "未启用",
      "disabled": true
    },
    "deepseek": {
      "ok": true,
      "label": "DeepSeek",
      "balance": 121.16,
      "currency": "CNY",
      "detail": "余额 ¥121.16",
      "fetchedAt": "2026-10-03T11:02:31.474+08:00",
      "error": null
    },
    "glm": {
      "ok": true,
      "label": "GLM",
      "windows": [
        {
          "name": "MCP 月",
          "usedPct": 0,
          "resetAt": "2026-11-02T10:00:32.998+08:00"
        },
        {
          "name": "5小时",
          "usedPct": 0,
          "resetAt": null
        },
        {
          "name": "周",
          "usedPct": 0,
          "resetAt": "2026-10-09T09:34:00.999+08:00"
        }
      ],
      "fetchedAt": "2026-10-03T11:02:31.508+08:00",
      "error": null
    }
  }
};
