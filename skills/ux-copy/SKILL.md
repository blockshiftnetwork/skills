---
name: ux-copy
description: Design, write, audit, and implement user-interface copy for web and app products. Use whenever a user asks to create, revise, review, or ship words inside a product—buttons, labels, forms, errors, empty/loading/success states, onboarding, settings, permissions, billing, notifications, destructive confirmations, AI or agent states, or a UX voice and terminology system—even if they call it microcopy, product copy, UI text, content design, wording, or copy cleanup. Do not use for primarily promotional marketing copy or long-form documentation unless the task is specifically about functional in-product guidance.
---

# UX Copy

Design interface language as part of the interaction. The result should help a person understand the current state, predict an action's result, complete the task, recover from problems, and trust what the product says.

## Choose the operating mode

- **Write or revise:** Produce final copy for a component, flow, mockup, specification, or screenshot.
- **Audit:** Identify copy and content-design problems, prioritize them, and propose fixes.
- **Implement:** Locate and change UI strings in a codebase without changing unrelated behavior.
- **Systematize:** Create or extend voice principles, terminology, message patterns, or a content inventory.
- **Validate:** Review state coverage, accessibility, localization, trust, and test evidence.

Read only the references needed for the task:

- For component-level patterns, read [references/component-patterns.md](references/component-patterns.md).
- When editing code or preparing strings for localization and accessibility, read [references/implementation.md](references/implementation.md).
- For AI, permissions, privacy, billing, destructive actions, or other consequential flows, read [references/trust-and-ai.md](references/trust-and-ai.md).
- For audits, experiments, or research plans, read [references/review-and-testing.md](references/review-and-testing.md).
- When the user asks for the rationale or sources behind the guidance, read [references/source-notes.md](references/source-notes.md).

## Establish the interaction truth

Inspect available designs, code, requirements, research, support evidence, product terminology, and existing content before drafting. Determine:

- who is acting and what they are trying to accomplish;
- the trigger, current state, and next state;
- what the action changes, its scope, timing, cost, reversibility, and failure modes;
- what the system actually knows, has done, or can guarantee;
- the product's established terms, voice, capitalization, and localization approach;
- component and space constraints, including accessible name and description needs;
- dynamic values, units, date or currency rules, and message variants.

If a missing fact changes the truth or consequence of the copy, ask a focused question or label the dependency as `[confirm: ...]`. Never invent product behavior, prices, retention, security or privacy guarantees, legal claims, execution status, or AI capability.

## Work from meaning to wording

1. Give each message one primary job: orient, explain, instruct, warn, confirm, report status, or help recovery.
2. Draft a plain functional version before applying brand voice. Front-load the information needed to act.
3. Use the audience's vocabulary. Give one concept one name and reuse the same noun and action verb across the journey.
4. Check the complete state path, not just the happy path: before, in progress, success, empty, partial success, validation error, system failure, no access, offline, canceled, and recovery where relevant.
5. Apply tone to the moment. Keep the voice recognizable, but reduce personality when the person is blocked, at risk, or handling sensitive information.
6. Edit in this order: truthful, useful, clear, concise, consistent, accessible, localizable, then distinctive.
7. Flag interaction problems that wording cannot solve. Copy must not disguise a missing control, unsafe default, ambiguous state, or broken recovery path.

## Quality gates

### Truth and state

- Describe the observable state precisely. Distinguish draft, recommendation, queued, running, awaiting approval, partially completed, completed, failed, and canceled.
- Claim success only after the system has evidence of success. If completion is asynchronous, say what has started and how the person will know it finished.
- Keep user-facing details consistent with backend rules and authorization. Expose a safe reference ID for support when useful; do not leak secrets or internals.

### Action and consequence

- Prefer labels that describe the result, such as `Send invoice` or `Delete worker`, over generic labels such as `Submit`, `OK`, `Yes`, or `Confirm`.
- Before consequential actions, state the object and scope, immediate result, delayed effects, cost, and whether the action can be undone when those facts matter.
- Keep cancel, decline, and opt-out choices direct and neutral. Do not use shame, false urgency, hidden material terms, or unequal wording to steer consent.

### Recovery

- Write errors in plain language: identify what happened, connect it to the affected item or task, and offer a specific next step when one is known.
- Do not blame the person, erase their work, present a correction they cannot perform, or use humor in a stressful failure.
- If the service is at fault, say so without making the user inspect or re-enter data unnecessarily.

### Accessibility and inclusion

- Do not communicate meaning only through color, icon, location, shape, sound, or visual order.
- Use persistent visible labels for inputs; placeholders are examples or hints, not replacements for labels.
- Make links and controls understandable in context and align visible text with the accessible name.
- Provide errors in text and implementation notes for their programmatic association. Identify dynamic status messages that need assistive-technology announcement without forcing focus.
- Use direct, respectful language. Avoid stereotypes, ableist language, unnecessary gender, idioms, and knowledge assumptions.
- Do not claim that copy alone makes an interface accessible; preserve semantic implementation and test with assistive technology when warranted.

### Localization

- Write complete messages rather than concatenated fragments. Preserve variables and use locale-aware plural or selection rules.
- Keep terminology, grammar, capitalization, and variable meaning consistent. Add translator context for ambiguous strings and placeholders.
- Avoid jokes, puns, slang, culture-specific references, and wordplay when they impede comprehension or translation.
- Format dates, times, numbers, and currency by locale. Allow for text expansion and right-to-left layouts instead of trimming required meaning to fit one language.

## Deliver the smallest useful output

Match the deliverable to the request:

- **Single component:** final copy, one alternative only when it represents a real tradeoff, and a brief dependency or implementation note if needed.
- **Flow or inventory:** a table with `Location/ID`, `State or trigger`, `Component`, `Current copy`, `Proposed copy`, `Variables`, and `Notes`. Omit columns that add no value.
- **Audit:** prioritized findings with severity, evidence, user impact, proposed copy, and any behavior or implementation dependency.
- **Code change:** edit the existing localization or component structure, preserve variables and semantics, run relevant tests, and summarize assumptions and affected states.
- **Voice system:** define a small set of evidence-based voice traits, each with “is / is not” boundaries and examples; add a terminology map and component conventions.

Do not pad the answer with a generic explanation of UX writing. When alternatives are materially equivalent, choose one and explain the decision only if it helps implementation or review.
