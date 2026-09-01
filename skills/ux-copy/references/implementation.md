# Implementation, accessibility, and localization

Read this reference when changing product code, localization resources, design-system content, or accessibility metadata.

## Inspect before editing

Use repository-native conventions rather than introducing a new content architecture for a copy-only task.

1. Find the rendered component and every state that selects its content.
2. Search for duplicate or related strings, existing terminology, content tokens, and tests.
3. Identify the i18n framework, fallback locale, message format, naming convention, and translator-comment support.
4. Trace variables to their sources and confirm their types, formatting, and possible values.
5. Check whether the same key is reused in contexts that require different grammar or meaning.

Prefer `rg` for locating strings and keys. Preserve unrelated user changes and do not refactor behavior merely to make the wording easier to edit unless the user asks or the existing implementation cannot express the required states accurately.

## String architecture

- Externalize user-facing strings when the project localizes UI. Keep logs and developer diagnostics separate from user messages.
- Use semantic, stable message IDs that describe purpose and context rather than the current English words.
- Store complete sentences or complete component messages. Do not build translatable copy from fragments, attach English plural suffixes, or move punctuation outside a localized message.
- Use the project's ICU, CLDR, or equivalent plural/select mechanism for counts, gender where unavoidable, and grammatical variants.
- Give translators context for ambiguous verbs and nouns, component type, character constraints, variable meaning, and markup.
- Avoid sharing one translation key across different contexts solely because the current English text matches.
- Preserve placeholders, rich-text tags, escapes, and interpolation syntax exactly. Treat user-provided values as data, not translatable markup.
- Prefer safe structured rich text to raw HTML inside translations. Sanitize any user-controlled or externally supplied content before rendering.

## Locale-aware values

- Format dates, times, time zones, numbers, percentages, currencies, and units with locale-aware libraries.
- Avoid ambiguous numeric dates and unexplained time zones in consequential messages.
- Plan for expansion, contraction, wrapping, and right-to-left layout. Do not solve layout failures by deleting necessary meaning.
- Test zero, one, two, few/many where supported, large values, negative values, long names, and missing optional data.
- Use pseudo-localization when available to reveal hard-coded strings, clipping, and bidirectional problems.

## Accessible implementation notes

Copy and semantics must agree:

- Associate each input with a programmatic label. Connect hints and errors with the framework's semantic description mechanism.
- Keep the visible control label within or at the start of its accessible name. Do not provide a conflicting `aria-label` merely to shorten the UI.
- Use native elements and established design-system components before adding ARIA.
- Announce important dynamic status changes using the existing status or live-region pattern without moving focus unnecessarily.
- Move focus only when the interaction pattern requires it, such as a blocking dialog or a page-level error summary.
- Provide text for icon-only controls and non-text status indicators; decorative images should not acquire redundant descriptions.
- Do not use `title` attributes or hover-only tooltips as the only source of essential instructions.

When the task changes only words, add implementation notes for missing semantics but do not silently claim or simulate accessibility compliance.

## Error boundaries and diagnostics

- Map technical failures to user-safe messages based on what the person can do. Do not expose stack traces, queries, credentials, internal hosts, raw provider responses, or personal data.
- Preserve a correlation or reference ID when support needs it, but keep it visually secondary and copyable.
- Distinguish validation, authorization, conflict, rate limit, offline, timeout, provider failure, and unknown failure when the recovery differs.
- If retrying may duplicate a transaction or external action, do not offer `Try again` until idempotency or reconciliation makes it safe.
- Show retained input and partial results accurately.

## Testing code changes

Run the project's relevant formatter, linter, type check, and focused tests. Add or update tests when the copy represents a contractual product state or when a new branch is introduced.

Prefer tests that verify:

- the correct state selects the correct semantic message;
- required variables and plural variants exist;
- labels, hints, and errors are programmatically associated;
- dynamic status messages use the intended announcement mechanism;
- no raw technical error is exposed;
- each supported locale can resolve the key.

Avoid brittle full-string snapshots when a semantic state or key assertion proves the behavior more reliably. Exact copy assertions are appropriate when wording is legally reviewed, safety-critical, or otherwise contractual.
