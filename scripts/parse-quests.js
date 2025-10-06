#!/usr/bin/env bun

import { promises as fs } from 'node:fs';
import path from 'node:path';
import process from 'node:process';

import { loadLocalization } from './utils/localization.js';
import { generateMarkdown } from './utils/markdown.js';
import { buildQuestMap, resolveChapterContext } from './utils/quest-data.js';
import { analyseQuests } from './utils/quest-graph.js';
import { collectSnbtFiles, parseSnbtText } from './utils/snbt.js';

const SUMMARY_DIR = '.quest_summaries';

function printHelp() {
  console.log(`Usage: bun ${path.basename(process.argv[1])} <file-or-directory>\n\n`
    + 'Parses FTB Quests SNBT chapters into AI-friendly markdown summaries.');
}

async function ensureSummaryDir() {
  await fs.mkdir(SUMMARY_DIR, { recursive: true });
}

async function processFile(filePath) {
  const absolute = path.resolve(filePath);
  const chapterName = path.basename(filePath, path.extname(filePath));
  const relative = path.relative(process.cwd(), absolute) || path.basename(filePath);

  let text;
  try {
    text = await fs.readFile(absolute, 'utf8');
  }
  catch (error) {
    return { status: 1, message: `✗ Error: File not found\n  Path: ${relative}` };
  }

  let chapter;
  try {
    chapter = parseSnbtText(text);
  }
  catch (error) {
    return {
      status: 2,
      message: `✗ Error: Failed to parse SNBT\n  File: ${relative}\n  Issue: ${error instanceof Error ? error.message : String(error)}`,
    };
  }

  const localization = await loadLocalization(absolute);
  const chapterContext = resolveChapterContext(chapter, localization, chapterName);
  const quests = buildQuestMap(chapter.quests, localization);
  const analysis = analyseQuests(quests);

  let exitStatus = 0;
  if (analysis.cycles.length > 0) {
    exitStatus = 3;
  }

  const markdown = generateMarkdown({ ...chapterContext, chapterName }, quests, analysis);
  const outputPath = path.join(SUMMARY_DIR, `${chapterName}.md`);

  await ensureSummaryDir();
  await fs.writeFile(outputPath, markdown, 'utf8');

  const summaryLines = [
    `✓ Parsed: ${relative}`,
    `  Quests: ${quests.length} total`,
    `  Entry points: ${analysis.entryPoints.length} quests`,
    `  Max chain depth: ${analysis.maxDepth} levels`,
    `  Output: ${path.relative(process.cwd(), outputPath)}`,
  ];

  if (analysis.cycles.length > 0) {
    const cycleDescriptions = analysis.cycles
      .map(cycle => `  ⚠ Circular dependency: ${cycle.join(' → ')}`)
      .join('\n');
    summaryLines.push(cycleDescriptions);
  }

  if (analysis.warnings.length > 0) {
    analysis.warnings.forEach((warning) => {
      if (warning.type === 'missing-dependency') {
        summaryLines.push(`  ⚠ Missing parent: quest ${warning.questId} references ${warning.missing}`);
      }
    });
  }

  return {
    status: exitStatus,
    message: summaryLines.join('\n'),
  };
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
    printHelp();
    process.exit(args.length === 0 ? 1 : 0);
  }

  const target = args[0];
  let files;
  try {
    files = await collectSnbtFiles(target);
  }
  catch (error) {
    console.error(`✗ Error: Invalid path\n  Path: ${target}`);
    process.exit(1);
  }

  if (files.length === 0) {
    console.error('✗ Error: No .snbt files found');
    process.exit(1);
  }

  const results = [];
  let aggregateStatus = 0;
  for (const file of files) {
    const result = await processFile(file);
    results.push(result);
    console.log(result.message);
    if (result.status !== 0) aggregateStatus = result.status;
  }

  if (files.length > 1) {
    const successCount = results.filter(result => result.status === 0).length;
    const cycleCount = results.filter(result => result.status === 3).length;
    const failureCount = results.length - successCount - cycleCount;
    const outputs = results.filter(result => result.status !== 1).length;

    console.log(`✓ Parsed: ${files.length} files`);
    console.log(`  ✓ Successful: ${successCount}`);
    if (cycleCount > 0) console.log(`  ⚠ With cycles: ${cycleCount}`);
    if (failureCount > 0) console.log(`  ✗ Failed: ${failureCount}`);
    console.log(`  Total output: ${outputs} markdown files`);
  }

  process.exit(aggregateStatus);
}

main().catch((error) => {
  console.error(`✗ Error: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(4);
});
