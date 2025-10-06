import { promises as fs } from 'node:fs';
import path from 'node:path';
import { parse as parseSnbt } from 'ftbq-nbt';

export function normalizeTag(value) {
  if (value === null || value === undefined) return value;
  if (typeof value === 'bigint') return value.toString();
  if (Array.isArray(value)) return value.map(entry => normalizeTag(entry));
  if (value instanceof Map) {
    const obj = {};
    for (const [key, val] of value.entries()) obj[key] = normalizeTag(val);
    return obj;
  }
  if (typeof value === 'object') {
    const entries = Object.entries(value);
    if (entries.length === 1 && entries[0][0] === 'value') {
      return normalizeTag(entries[0][1]);
    }
    const obj = {};
    for (const [key, val] of entries) obj[key] = normalizeTag(val);
    return obj;
  }
  return value;
}

export function parseSnbtText(text) {
  return normalizeTag(parseSnbt(text, { skipComma: true }));
}

export async function collectSnbtFiles(targetPath) {
  const stats = await fs.stat(targetPath);
  if (stats.isFile()) return [targetPath];
  if (!stats.isDirectory()) return [];

  const files = [];

  async function walk(current) {
    const entries = await fs.readdir(current, { withFileTypes: true });
    for (const entry of entries) {
      const entryPath = path.join(current, entry.name);
      if (entry.isDirectory()) {
        await walk(entryPath);
      }
      else if (entry.isFile() && entry.name.endsWith('.snbt')) {
        files.push(entryPath);
      }
    }
  }

  await walk(targetPath);
  return files;
}
