# Review and testing

Use this reference for audits, release reviews, content experiments, and research plans.

## Audit rubric

Rate each dimension as `0 = blocked or misleading`, `1 = usable with friction`, or `2 = clear and complete`. Include evidence rather than only a score.

| Dimension | Review question |
| --- | --- |
| Truth | Does the copy match the actual state, behavior, scope, timing, and certainty? |
| Usefulness | Does it give the information needed to decide or act now? |
| Clarity | Does it use familiar, specific language with the important point first? |
| Concision | Is every word doing work without removing a needed consequence or recovery step? |
| Consistency | Are the same objects, actions, statuses, and conventions named the same way? |
| Recovery | Can the person understand and recover from foreseeable errors without losing work? |
| Accessibility | Do text and implementation semantics support labels, errors, status, and nonvisual use? |
| Localization | Are messages complete, variables meaningful, plurals supported, and cultural assumptions limited? |
| Trust | Are costs, data use, automation, limitations, and choices represented without manipulation? |

Treat a truth, consequence, consent, or accessibility failure as release-relevant even when the average score is high.

## State-coverage review

For each significant action, inspect the applicable states:

| Before | During | Result | Exception |
| --- | --- | --- | --- |
| default | validating | success | validation error |
| first use | queued | partial success | system or provider failure |
| existing data | running | canceled | conflict or stale data |
| no permission | awaiting approval | undone | offline or timeout |

Also check zero versus no data, single versus plural, long values, expired or revoked access, and different roles. Missing states often indicate a product or implementation gap, not merely a missing sentence.

## Prioritize findings

- **Critical:** misleading consent, money, privacy, security, authorization, destructive action, or claimed success.
- **High:** blocks completion or recovery; omits a consequential constraint; creates an accessibility barrier.
- **Medium:** creates hesitation, inconsistency, avoidable error, or localization risk.
- **Low:** polish that does not materially affect understanding or action.

Do not label every style preference as a usability problem. Explain the observed or plausible user impact.

## Test content in context

Prefer realistic tasks over asking which wording people like.

### Comprehension or paraphrase test

Show the interface at the decision point, then ask the participant to explain:

- what is happening;
- what the primary action will do;
- what data, money, or people it affects;
- whether it can be undone;
- what they would do next.

Record misunderstandings, not just confidence ratings.

### Task-based usability test

Give a believable goal without revealing the control label. Observe whether the participant finds the action, predicts its result, completes it, and recovers from a seeded error. Include participants who use assistive technologies when the surface or risk warrants it.

### Cloze or readability checks

Use them as diagnostic signals for longer instructional text, not as proof that interface copy works. Short labels and context-dependent messages require task-based evaluation.

### A/B tests

Use experiments after both variants meet truth, accessibility, and informed-choice requirements. Define the behavior the copy is meant to improve, then pair the primary metric with guardrails.

Examples:

- completion rate + correction rate + abandonment;
- approval rate + post-approval reversal or incident rate;
- upgrade conversion + refunds + cancellations + support contacts;
- error recovery + repeated failure + time to completion;
- AI suggestion acceptance + later edits + verified outcome quality.

A higher click or conversion rate can reflect confusion or pressure. Do not select a winner on a proxy metric that undermines the person's goal.

## Release evidence

For significant changes, preserve:

- the user need and task;
- before and after copy with component and state IDs;
- behavior and data assumptions confirmed by product or engineering;
- accessibility and localization notes;
- research question, method, participant context, and observed evidence;
- metrics with definitions and guardrails;
- unresolved dependencies and owner.

Keep the record proportional to risk. A routine label does not need the same evidence as billing consent or an autonomous external action.
