# Component patterns

Use these patterns as decision aids, not fill-in-the-blank templates. The product truth, the person's task, and the complete interaction determine the wording.

## Titles and headings

- Orient the person: where they are, what changed, or what decision is required.
- Front-load the distinguishing words so headings remain useful when scanned or truncated.
- Prefer specific titles such as `Review payment details` over labels that merely name the UI, such as `Confirmation`.
- Avoid repeating the same title in the subtitle unless the supporting text adds a consequence, constraint, or next step.

## Buttons, links, and menu items

- Start action labels with the verb that best predicts the result: `Invite member`, `Save changes`, `Run report`.
- Include the object when several objects or consequences are plausible.
- Use `Continue` or `Next` only for a genuinely linear, low-consequence step whose destination is already clear.
- Use descriptive link text that remains meaningful when read apart from nearby prose. Avoid `Click here`, `Learn more` without context, and icon-only actions when a short visible label is practical.
- In confirmation dialogs, repeat the actual action on the primary button. Keep the safe exit direct, usually `Cancel`.

## Forms

- Use a persistent label that names the requested information or asks one short, answerable question.
- Put instructions and format constraints before input when knowing them prevents failure. Use hint text for nonessential clarification or a compact example.
- Mark required or optional fields consistently according to the form's dominant pattern; do not make the person infer it from color or an asterisk alone.
- Avoid asking for information the system already has. Explain why sensitive or surprising information is required at the point of collection.
- Keep placeholder text optional, brief, and realistic. Never store the only label or essential instruction in a placeholder that disappears during entry.

## Validation and system errors

Build the message from the most useful applicable parts:

1. **Problem:** what is missing, invalid, unavailable, or unfinished.
2. **Location or object:** what field, record, connection, or action is affected.
3. **Recovery:** what the person can do now.
4. **Preserved state:** whether their work was saved.
5. **Support reference:** a safe identifier when self-recovery is not possible.

Examples:

- Weak: `Invalid input.`
- Better: `Enter an email address in the format name@example.com.`
- Weak: `Agent error 502.`
- Better: `The worker could not connect to QuickBooks. Your task is still saved. Reconnect QuickBooks, then retry.`

Do not present validation styling while the person is still entering a plausible value. Do not reuse a validation message for eligibility, authorization, capacity, or service failures the person cannot fix.

## Empty and zero states

Identify the actual state before writing:

- **First use:** explain what belongs here and offer the most useful starting action.
- **No results:** restate the relevant filter or query and suggest a recovery such as clearing filters.
- **All done:** confirm completion without implying that data is missing.
- **No access:** explain the permission boundary and who can help, without exposing restricted details.
- **Unavailable or failed:** use an error or service-status pattern, not cheerful empty-state copy.
- **Still loading:** use progress language; do not claim the collection is empty.

An illustration or joke cannot replace the state explanation or next action.

## Loading, progress, and background work

- Name the current operation when the wait is meaningful: `Importing 42 invoices`.
- Give a time estimate only when the product can support it. Otherwise explain whether the person can leave safely and where completion will appear.
- For staged work, expose useful stages rather than a fake percentage.
- If work continues in the background, say what started, what can be done meanwhile, and how completion or failure will be communicated.

## Success and confirmation

- Confirm the actual outcome and identify the object when ambiguity is possible.
- Add the next useful action only when one exists.
- Avoid premature `Done` or `Completed` messages for queued, partially successful, or externally unverified work.
- Reduce celebration for sensitive, routine, medical, financial, compliance, or failure-recovery moments.

## Notifications

- Lead with the event, its relevance, or the action required.
- Include enough context to distinguish similar records without exposing sensitive data on a lock screen or shared device.
- Use an action only if it can resolve or advance the notification's task.
- Match urgency to actual time sensitivity. Do not use emergency language merely to increase engagement.

## Destructive actions

- Name the action and object in the title: `Delete this worker?`
- Explain scope and consequences in the body: affected data, collaborators, connected systems, retention, billing, or downstream work as applicable.
- Label the destructive action with the same verb and object: `Delete worker`.
- State whether recovery is possible. Prefer an undo or reversible state when the product supports it.
- `Are you sure?` may accompany useful information, but it is not useful information by itself.

## Permissions and privacy

- Ask in context, when the feature needs access.
- State the user benefit, the exact data or capability requested, and how it will be used.
- Explain storage, sharing, training, retention, or administrator visibility when material to an informed choice.
- Keep the deny or later path clear. Do not make a pre-permission screen imitate the system permission decision.

## Settings and toggles

- Label the controlled state rather than the click: `Email notifications` with supporting text `Receive an email when a task needs approval.`
- Prefer positive statements and avoid double negatives.
- Ensure the label remains intelligible with the current on/off state announced separately.
- Explain dependencies, delayed effects, and organization-wide scope before the setting changes them.

## Plans, billing, credits, and quotas

- Show the real price or unit, currency, recurrence, taxes or fees, renewal behavior, and effective date before commitment.
- Explain what expires, rolls over, is refundable, or happens at a limit. Do not hide a real-money relationship behind internal credits.
- Distinguish a quota, a reservation, a forecast, and current usage.
- For upgrades or packages, describe the actual change rather than using empty superlatives such as `Best value` without substantiation.

## Tables, dashboards, and audit views

- Use column labels that name the value, not implementation fields.
- State timezone, unit, data freshness, filter scope, and metric definition when omission could change interpretation.
- Distinguish no data, zero, not applicable, redacted, and unavailable.
- Use status terms consistently across tables, filters, detail pages, exports, and notifications.
