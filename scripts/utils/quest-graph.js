import { keyBy, sortedIndexBy } from 'es-toolkit/compat';

export function questLabel(quest) {
  if (!quest) return '[unknown] (missing quest)';
  const id = quest.id ?? 'unknown';
  const title = quest.title?.toString().trim();
  return `[${id}] ${title && title.length > 0 ? title : '(untitled quest)'}`;
}

export function analyseQuests(quests) {
  const questRecord = keyBy(quests, quest => quest.id);
  const questMap = new Map(Object.entries(questRecord));
  const adjacency = new Map();
  const indegree = new Map();
  const warnings = [];

  for (const quest of quests) {
    adjacency.set(quest.id, new Set());
    indegree.set(quest.id, 0);
  }

  for (const quest of quests) {
    const deps = Array.from(new Set(quest.dependencies.filter(Boolean)));
    quest.dependencies = deps;
    for (const dep of deps) {
      if (!questMap.has(dep)) {
        warnings.push({ type: 'missing-dependency', questId: quest.id, missing: dep });
        continue;
      }
      adjacency.get(dep)?.add(quest.id);
      indegree.set(quest.id, (indegree.get(quest.id) ?? 0) + 1);
    }
  }

  const entryPoints = quests
    .filter(quest => (indegree.get(quest.id) ?? 0) === 0)
    .map(quest => quest.id)
    .sort((a, b) => questLabel(questMap.get(a)).localeCompare(questLabel(questMap.get(b))));

  const queue = [];
  const order = [];
  const depth = new Map(entryPoints.map(id => [id, 1]));

  function pushQueue(id) {
    if (queue.includes(id)) return;
    const index = sortedIndexBy(queue, id, questId => questLabel(questMap.get(questId)));
    queue.splice(index, 0, id);
  }

  entryPoints.forEach(id => pushQueue(id));

  while (queue.length > 0) {
    const current = queue.shift();
    order.push(current);
    const currentDepth = depth.get(current) ?? 1;
    for (const child of adjacency.get(current) ?? []) {
      const degree = (indegree.get(child) ?? 0) - 1;
      indegree.set(child, degree);
      depth.set(child, Math.max(depth.get(child) ?? 1, currentDepth + 1));
      if (degree === 0) pushQueue(child);
    }
  }

  const maxDepth = depth.size > 0 ? Math.max(...depth.values()) : 0;
  const unordered = quests.filter(quest => !order.includes(quest.id)).map(quest => quest.id);
  const cycleNodes = new Set(unordered);

  function detectCycles() {
    const cycles = [];
    const visited = new Set();
    const onStack = new Set();
    const seenCycles = new Set();

    function dfs(node, path) {
      visited.add(node);
      onStack.add(node);
      path.push(node);

      for (const next of adjacency.get(node) ?? []) {
        if (!cycleNodes.has(next)) continue;
        if (onStack.has(next)) {
          const idx = path.indexOf(next);
          if (idx !== -1) {
            const cycle = path.slice(idx);
            const key = cycle.join('→');
            if (!seenCycles.has(key)) {
              seenCycles.add(key);
              cycles.push(cycle);
            }
          }
        }
        else if (!visited.has(next)) {
          dfs(next, path);
        }
      }

      onStack.delete(node);
      path.pop();
    }

    for (const node of cycleNodes) {
      if (!visited.has(node)) dfs(node, []);
    }
    return cycles;
  }

  const cycles = cycleNodes.size > 0 ? detectCycles() : [];

  return {
    questMap,
    adjacency,
    entryPoints,
    topologicalOrder: order,
    warnings,
    cycles,
    cycleNodes,
    maxDepth,
  };
}

export function formatProgressionFlow({ entryPoints, adjacency, questMap, cycleNodes }) {
  if (entryPoints.length === 0) return 'No entry points found.';
  const lines = [];
  const visited = new Set();

  function traverse(id, prefix, isLast, isRoot = false) {
    const quest = questMap.get(id);
    if (!quest) return;
    const label = questLabel(quest) + (cycleNodes.has(id) ? ' ⚠ cycle' : '');
    const connector = isRoot ? '' : isLast ? '└─ ' : '├─ ';
    let line = `${prefix}${connector}${label}`;
    if (visited.has(id)) {
      line += ' (shared)';
      lines.push(line);
      return;
    }
    lines.push(line);
    visited.add(id);

    const children = [...(adjacency.get(id) ?? [])]
      .filter(child => !cycleNodes.has(child))
      .sort((a, b) => questLabel(questMap.get(a)).localeCompare(questLabel(questMap.get(b))));

    const childPrefix = isRoot ? '' : `${prefix}${isLast ? '   ' : '│  '}`;
    children.forEach((child, index) => traverse(child, childPrefix, index === children.length - 1));
  }

  entryPoints.forEach((id, index) => {
    traverse(id, '', index === entryPoints.length - 1, true);
  });

  return lines.join('\n');
}
