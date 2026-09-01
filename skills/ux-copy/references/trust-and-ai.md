# Trust, consequential actions, and AI

Use this reference when copy affects money, permissions, privacy, external systems, deletion, legal commitments, regulated work, or AI-mediated decisions and actions.

## Scale detail with consequence

The more consequential or difficult to reverse an action is, the more the interface must reveal before commitment. Include the applicable facts:

- action and object;
- scope: person, team, organization, tenant, integration, or external system;
- immediate result and delayed or downstream effects;
- price, credits, recurrence, or quota impact;
- data sent, stored, retained, shared, or used for training;
- whether the action can be reviewed, corrected, canceled, rolled back, or recovered;
- who will be notified or able to see the result.

Do not bury a material term in a tooltip or policy link when the person needs it to decide.

For legal, financial, privacy, security, or compliance language, make the operational facts clear and flag the copy for the appropriate specialist review. Do not present writing guidance as legal approval.

## Human-AI interaction

### Set expectations

- State what the AI feature is designed to do and the inputs or domains it supports.
- Calibrate language to actual performance. Do not describe probabilistic output as certain, comprehensive, unbiased, or verified without evidence.
- Name important limitations near the decision they affect, not only in a generic disclaimer.
- Use examples to demonstrate supported inputs, but do not imply the examples are the complete capability boundary.

### Distinguish assistance from action

Use consistent state language for the product's autonomy model:

- **Drafted:** content exists for human review; nothing was sent or applied.
- **Recommended:** the system proposed a choice; the person remains the decision-maker.
- **Awaiting approval:** the exact action and payload must still be authorized.
- **Approved:** authorization exists; execution may not have started.
- **Running or queued:** execution has started or is waiting; completion is not yet known.
- **Completed:** the target system confirmed the intended result.
- **Partially completed:** identify what succeeded, what did not, and whether retry is safe.

Do not use anthropomorphic language when it obscures responsibility, capability, or system state. A friendly voice is acceptable; false agency, intent, or understanding is not.

### Preserve meaningful human control

- Before approval, summarize the exact action, target, material inputs, and consequences. If the payload changes, the UI should require renewed approval rather than merely changing the copy.
- Provide the relevant controls: edit, inspect source, approve, reject, stop, retry, undo, escalate, or contact support according to actual capability.
- Show provenance or an explanation when it helps the person evaluate an output. An explanation can increase trust even when the output is wrong, so do not treat explanation as proof.
- Make uncertainty actionable: say what is uncertain, why it matters, and what the person can check.
- Avoid progress theater. Show real stages or honest indeterminate progress.

### AI privacy and data boundaries

- State which data the feature uses, where it is processed or stored when material, who controls it, and whether it may be used for model training or improvement.
- Distinguish current deployed behavior from architecture under development or a future option.
- Do not compress a nuanced deployment model into claims such as `your data never leaves your environment` unless every relevant data object and operational path supports the claim.
- Separate model-provider behavior from the product's own logs, memory, audit records, files, analytics, and support access.

## Permissions and authorization

- Explain the capability granted, the data or resources within scope, and what the product will do with it.
- Distinguish read, write, delete, administer, impersonate, and approve permissions.
- For organization-wide roles, say whether a change affects existing members, future members, or both.
- If access is blocked, identify the required permission or responsible administrator without exposing restricted resource details.
- Do not call access `secure`, `private`, `isolated`, or `compliant` solely because a permission screen exists.

## Billing and virtual units

- Before purchase or consumption, disclose the actual currency relationship, quantity, bonus, expiration, renewal, and refund or rollover behavior that applies.
- Distinguish allocated limits from reserved balances. Explain what happens when an individual, team, or organization reaches a limit.
- State whether usage estimates are final, delayed, or subject to reconciliation.
- Pair a virtual credit amount with real-money meaning when the relationship is fixed or material to the decision.

## Avoid manipulative copy

Reject copy strategies that impair informed choice, including:

- false scarcity, countdowns, or urgency;
- confirmshaming or emotional pressure;
- vague or visually de-emphasized opt-out and cancellation language;
- hidden fees, recurring charges, data uses, or cancellation conditions;
- disguised ads, sponsored recommendations, or AI output;
- preselection or wording that changes a neutral choice into implied consent;
- success language that masks a partial result or failed external action.

Optimize for informed task success and durable trust, not clicks or conversion alone.
