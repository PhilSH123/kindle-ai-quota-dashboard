'use strict';

const { loadConfig } = require('../src/lib/config.cjs');
const { fetchJson, isoBeijing, writeAtomic } = require('../src/lib/common.cjs');

const quotes = [
  ['山重水复疑无路，柳暗花明又一村。', '陆游《游山西村》'],
  ['长风破浪会有时，直挂云帆济沧海。', '李白《行路难》'],
  ['海内存知己，天涯若比邻。', '王勃《送杜少府之任蜀州》'],
  ['会当凌绝顶，一览众山小。', '杜甫《望岳》'],
  ['春种一粒粟，秋收万颗子。', '李绅《悯农》'],
  ['纸上得来终觉浅，绝知此事要躬行。', '陆游《冬夜读书示子聿》'],
  ['行到水穷处，坐看云起时。', '王维《终南别业》'],
];

function weatherDescription(code) {
  if (code === 0) return ['晴', 'clear'];
  if (code <= 3) return ['多云', 'cloudy'];
  if (code <= 48) return ['雾', 'fog'];
  if (code <= 67 || code === 80 || code === 81 || code === 82) return ['雨', 'rain'];
  if (code <= 77 || code === 85 || code === 86) return ['雪', 'snow'];
  if (code >= 95) return ['雷阵雨', 'thunder'];
  return ['多云', 'cloudy'];
}

async function updateWeather(config) {
  if (!config.weatherFile || !config.weatherLocation) return;
  const location = config.weatherLocation;
  const url = new URL('https://api.open-meteo.com/v1/forecast');
  url.searchParams.set('latitude', String(location.latitude));
  url.searchParams.set('longitude', String(location.longitude));
  url.searchParams.set('current', 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m');
  url.searchParams.set('timezone', 'Asia/Shanghai');
  url.searchParams.set('forecast_days', '1');
  const payload = await fetchJson(url.toString());
  const current = payload && payload.current;
  if (!current || !Number.isFinite(Number(current.temperature_2m))) {
    throw new Error('天气响应缺少当前气温');
  }
  const [description, iconKey] = weatherDescription(Number(current.weather_code));
  const degrees = Number(current.wind_direction_10m);
  const directions = ['北', '东北', '东', '东南', '南', '西南', '西', '西北'];
  const windDir = Number.isFinite(degrees) ? directions[Math.round(degrees / 45) % 8] + '风' : '';
  const observedAt = current.time ? isoBeijing(`${current.time}:00+08:00`) : isoBeijing();
  writeAtomic(config.weatherFile, JSON.stringify({
    description, iconKey,
    tempC: Number(current.temperature_2m),
    feelsLikeC: Number(current.apparent_temperature),
    humidity: Number(current.relative_humidity_2m),
    windKph: Number(current.wind_speed_10m),
    windDir,
    place: String(location.name || '石家庄'),
    observedAt,
    fetchedAt: isoBeijing(),
  }, null, 2) + '\n');
}

function updateQuote(config) {
  if (!config.quoteFile) return;
  const day = Math.floor((Date.now() + 8 * 3600000) / 86400000);
  const [text, source] = quotes[day % quotes.length];
  writeAtomic(config.quoteFile, JSON.stringify({ text, source }, null, 2) + '\n');
}

async function main() {
  const config = loadConfig();
  updateQuote(config);
  try {
    await updateWeather(config);
    process.stdout.write('天气和每日一语已更新\n');
  } catch (error) {
    process.stderr.write(`天气更新失败：${error.message}\n`);
    process.stderr.write('继续使用上一次成功的天气数据。\n');
  }
}

if (require.main === module) main();
module.exports = { updateQuote, updateWeather, weatherDescription };
