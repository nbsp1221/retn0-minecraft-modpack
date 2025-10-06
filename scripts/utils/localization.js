import { promises as fs } from 'node:fs';
import path from 'node:path';
import { castArray, uniq } from 'es-toolkit/compat';
import fg from 'fast-glob';

import { parseSnbtText } from './snbt.js';

const COLOR_CODE_REGEX = /[&§][0-9a-fk-or]/gi;
const PLACEHOLDER_REGEX = /\{([^{}]+)\}/g;

export function stripFormatting(text) {
  return text
    .replace(/\\\\/g, '\\')
    .replace(COLOR_CODE_REGEX, '')
    .replace(/\u00A7[0-9a-fk-or]/gi, '')
    .replace(/§[0-9a-fk-or]/gi, '')
    .replace(/\r?\n/g, '\n')
    .trim();
}

export function resolvePlaceholders(text, localization) {
  if (!text) return '';
  const replaced = text.replace(PLACEHOLDER_REGEX, (match, key) => {
    const normalizedKey = key.trim();
    if (localization.has(normalizedKey)) return localization.get(normalizedKey);
    const fallbackKey = normalizedKey.replace(/^ftbquests\./, '');
    if (localization.has(fallbackKey)) return localization.get(fallbackKey);
    return normalizedKey;
  });
  return stripFormatting(replaced);
}

export function resolveText(value, localization) {
  if (value === null || value === undefined) return '';
  if (Array.isArray(value)) {
    return resolveText(value.join('\n'), localization);
  }
  return resolvePlaceholders(String(value), localization);
}

export function resolveTextLines(value, localization) {
  const lines = [];
  const entries = castArray(value ?? []);
  entries.forEach((entry) => {
    const resolved = resolveText(entry, localization);
    resolved.split('\n').forEach((line) => {
      const trimmed = line.trim();
      if (trimmed) lines.push(trimmed);
    });
  });
  return uniq(lines);
}

export function resolveStringsInObject(source, localization) {
  if (source === null || source === undefined) return source;
  if (typeof source === 'string') return resolveText(source, localization);
  if (typeof source === 'number' || typeof source === 'boolean') return source;

  if (Array.isArray(source)) {
    return source.map(entry => resolveStringsInObject(entry, localization));
  }

  if (typeof source === 'object') {
    const result = {};
    for (const [key, value] of Object.entries(source)) {
      result[key] = resolveStringsInObject(value, localization);
    }
    return result;
  }

  return source;
}

function localizationScore(filePath) {
  const lower = filePath.toLowerCase();
  if (lower.includes(`${path.sep}en_us`)) return 0;
  if (lower.endsWith('en_us.snbt')) return 0;
  if (lower.includes('en_us')) return 1;
  return 2;
}

function extractLocalizationEntries(data, prefix = '') {
  if (data === null || data === undefined) return [];
  if (typeof data === 'string' || typeof data === 'number' || typeof data === 'boolean') {
    if (!prefix) return [];
    return [[prefix, stripFormatting(String(data))]];
  }

  if (Array.isArray(data)) {
    const text = data
      .map(entry => (typeof entry === 'string' ? entry : String(entry)))
      .join('\n');
    if (!prefix) return [];
    return [[prefix, stripFormatting(text)]];
  }

  const entries = [];
  for (const [key, value] of Object.entries(data)) {
    const nextKey = prefix ? `${prefix}.${key}` : key;
    if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
      entries.push([nextKey, stripFormatting(String(value))]);
    }
    else if (Array.isArray(value)) {
      entries.push(...extractLocalizationEntries(value, nextKey));
    }
    else if (value && typeof value === 'object') {
      entries.push(...extractLocalizationEntries(value, nextKey));
    }
  }
  return entries;
}

export async function loadLocalization(absoluteChapterPath) {
  let current = path.dirname(absoluteChapterPath);
  let questsDir;
  while (current && current !== path.parse(current).root) {
    if (path.basename(current) === 'chapters') {
      questsDir = path.dirname(current);
      break;
    }
    current = path.dirname(current);
  }

  if (!questsDir) return new Map();
  const langDir = path.join(questsDir, 'lang');
  try {
    const stats = await fs.stat(langDir);
    if (!stats.isDirectory()) return new Map();
  }
  catch (error) {
    return new Map();
  }

  const files = await fg('**/*.snbt*', { cwd: langDir, absolute: true });
  files.sort((a, b) => localizationScore(a) - localizationScore(b));

  const localization = new Map();
  for (const file of files) {
    try {
      const text = await fs.readFile(file, 'utf8');
      const parsed = parseSnbtText(text);
      const entries = extractLocalizationEntries(parsed);
      for (const [key, value] of entries) {
        if (!key || !value) continue;
        if (!localization.has(key)) localization.set(key, value);
      }
    }
    catch (error) {
      // Ignore malformed localization files
    }
  }

  return localization;
}
