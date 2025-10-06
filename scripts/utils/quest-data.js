import { castArray, compact, uniq } from 'es-toolkit/compat';

import { resolveStringsInObject, resolveText, resolveTextLines } from './localization.js';
import { normalizeTag } from './snbt.js';

export function buildQuestMap(rawQuests, localization) {
  const quests = [];
  for (const raw of rawQuests ?? []) {
    const quest = normalizeTag(raw);
    if (!quest || typeof quest !== 'object') continue;

    const id = quest.id ?? '';
    const titleKey = `quest.${id}.title`;
    const subtitleKey = `quest.${id}.quest_subtitle`;
    const descriptionKey = `quest.${id}.quest_desc`;

    const title = resolveText(quest.title ?? localization.get(titleKey) ?? id, localization) || id;
    const subtitle = localization.has(subtitleKey)
      ? resolveText(localization.get(subtitleKey), localization)
      : '';

    let description = resolveTextLines(quest.description ?? [], localization);
    if (description.length === 0 && localization.has(descriptionKey)) {
      description = resolveTextLines(localization.get(descriptionKey), localization);
    }
    if (subtitle) description.unshift(subtitle);

    const dependencies = uniq(compact(castArray(quest.dependencies ?? [])));
    const tasks = compact(castArray(quest.tasks ?? [])).map(task => resolveStringsInObject(task, localization));
    const rewards = compact(castArray(quest.rewards ?? [])).map(reward => resolveStringsInObject(reward, localization));

    quests.push({
      ...quest,
      id,
      title,
      subtitle,
      description,
      dependencies,
      tasks,
      rewards,
    });
  }
  return quests;
}

export function resolveChapterContext(chapter, localization, fallbackName) {
  const chapterTitle = resolveText(chapter.title ?? fallbackName, localization) || fallbackName || 'Unknown Chapter';
  const chapterDescription = resolveTextLines(chapter.description ?? [], localization);
  return { chapterTitle, chapterDescription };
}
