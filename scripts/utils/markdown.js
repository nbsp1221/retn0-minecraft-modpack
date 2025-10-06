import { formatProgressionFlow, questLabel } from './quest-graph.js';

function describeKeyValues(source, ignoredKeys = new Set(['id', 'type'])) {
  const entries = Object.entries(source ?? {})
    .filter(([key, value]) => !ignoredKeys.has(key) && value !== undefined && value !== null)
    .map(([key, value]) => {
      if (Array.isArray(value)) return `${key}=[${value.map(item => JSON.stringify(item)).join(', ')}]`;
      if (typeof value === 'object') return `${key}=${JSON.stringify(value)}`;
      return `${key}=${value}`;
    });
  return entries.length > 0 ? ` ${entries.join(', ')}` : '';
}

function formatQuestDetails(quest, analysis) {
  const { adjacency, questMap } = analysis;
  const dependencies = quest.dependencies.length > 0
    ? quest.dependencies.map(dep => `[${dep}]`).join(', ')
    : 'None';

  const tasks = quest.tasks.length > 0
    ? quest.tasks.map(task => `  - ${task.type ?? 'unknown'}${describeKeyValues(task)}`).join('\n')
    : '  - None';

  const rewards = quest.rewards.length > 0
    ? quest.rewards.map(reward => `  - ${reward.type ?? 'unknown'}${describeKeyValues(reward)}`).join('\n')
    : '  - None';

  const children = [...(adjacency.get(quest.id) ?? [])];
  const childLabels = children
    .map(childId => questLabel(questMap.get(childId)))
    .sort((a, b) => a.localeCompare(b));

  let unlocks;
  if (childLabels.length === 0) {
    unlocks = '- Unlocks: None';
  }
  else if (childLabels.length <= 5) {
    unlocks = ['- Unlocks:', ...childLabels.map(label => `  - ${label}`)].join('\n');
  }
  else {
    const preview = childLabels.slice(0, 5).map(label => `  - ${label}`);
    unlocks = ['- Unlocks: ' + `${childLabels.length} quests`, ...preview, '  - …'].join('\n');
  }

  const description = quest.description
    .map(line => line?.toString().trim())
    .filter(line => line && line.length > 0);
  const descriptionBlock = description.length > 0
    ? ['- Description:', ...description.map(line => `  - ${line}`)].join('\n')
    : null;

  return [
    `### ${questLabel(quest)}`,
    `- Dependencies: ${dependencies}`,
    unlocks,
    `- Tasks:\n${tasks}`,
    `- Rewards:\n${rewards}`,
    descriptionBlock,
  ].filter(Boolean).join('\n');
}

export function generateMarkdown(context, quests, analysis) {
  const { entryPoints, adjacency, questMap, topologicalOrder, warnings, cycles, cycleNodes, maxDepth } = analysis;
  const { chapterTitle, chapterName, chapterDescription = [] } = context;
  const questCount = quests.length;
  const title = chapterTitle || chapterName || 'Unknown Chapter';

  const flowBlock = formatProgressionFlow({ entryPoints, adjacency, questMap, cycleNodes });

  const ordered = topologicalOrder
    .map(id => questMap.get(id))
    .filter(Boolean);
  const unordered = quests.filter(quest => !topologicalOrder.includes(quest.id));
  const details = [...ordered, ...unordered]
    .map(quest => formatQuestDetails(quest, analysis))
    .join('\n\n');

  const warningLines = warnings.map((warning) => {
    if (warning.type === 'missing-dependency') {
      return `- Quest ${warning.questId} references missing parent ${warning.missing}`;
    }
    return `- ${JSON.stringify(warning)}`;
  });

  const cycleLines = cycles.map((cycle) => {
    const labels = cycle.map((id) => {
      const quest = questMap.get(id);
      return quest ? questLabel(quest) : `[${id}]`;
    });
    return `- ${labels.join(' → ')}`;
  });

  const sections = [
    `# ${title} (${questCount} quests)`,
    '## Quest Progression Tree',
    '**Entry Points:**',
    entryPoints.length > 0 ? entryPoints.map(id => `- ${questLabel(questMap.get(id))}`).join('\n') : '- None',
    `**Progression Flow:**\n\`\`\`\n${flowBlock}\n\`\`\``,
  ];

  if (chapterDescription.length > 0) {
    sections.push('## Chapter Overview');
    sections.push(chapterDescription.join('\n'));
  }

  if (cycleLines.length > 0) {
    sections.push('## Circular Dependencies');
    sections.push(cycleLines.join('\n'));
  }

  if (warningLines.length > 0) {
    sections.push('## Warnings');
    sections.push(warningLines.join('\n'));
  }

  sections.push('## Quest Details');
  sections.push(details);

  sections.push('\n---\n');
  sections.push(`Quests: ${questCount} | Entry points: ${entryPoints.length} | Max depth: ${maxDepth}`);

  return sections.join('\n\n');
}
