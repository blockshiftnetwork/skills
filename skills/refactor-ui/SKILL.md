---
name: refactor-ui
description: Helps critique and refactor a single product screen into a clearer, more polished interface. Use when you say "critique this UI", "make this screen feel more polished", "help me improve the hierarchy", "refactor this dashboard", or "what should I change in this form?"
---

# Refactor UI Review

## Overview
It focuses on the repeatable process behind polished UI work: start with the feature, clarify hierarchy, constrain decisions with systems, then refine spacing, typography, color, depth, and finishing details. The goal is to turn a cluttered, bland, or inconsistent interface into a clear, intentional, shippable design.

## When to Use This Skill
- You have a screen that feels cluttered, bland, or unpolished and want concrete improvements
- You want feedback on a form, dashboard, settings page, table, card, or empty state
- You are designing a new feature and want a hierarchy-first, systems-based UI plan before polishing details

## Instructions

### Step 1: Define the feature and the smallest useful version
Start with the specific feature, not the whole app shell.

1. Identify the exact screen or feature being worked on.
2. Ask what the user is trying to help someone do on that screen.
3. Name the single primary action.
4. List supporting content, secondary actions, and any nice-to-have elements.
5. Strip the scope down to the smallest useful version that could ship now.
6. If the user is asking about a whole product, narrow the review to one screen or one feature state first.

Apply these principles:
- Start with a feature, not a layout
- Detail comes later
- Don’t design too much
- Be a pessimist about complexity and defer nice-to-haves

### Step 2: Establish hierarchy and personality
Decide what deserves attention and what should fade into the background.

1. Classify content and actions as primary, secondary, or tertiary.
2. Identify what is competing for attention unnecessarily.
3. Recommend what to emphasize and what to de-emphasize.
4. Choose or confirm the intended personality using:
   - font direction
   - color tone
   - border radius style
   - voice and UI language
5. Treat labels as supporting content unless the user is clearly scanning for labels.
6. Separate visual hierarchy from document semantics. Do not assume headings must look large just because they are headings in markup.

Apply these principles:
- Not all elements are equal
- Emphasize by de-emphasizing
- Labels are a last resort
- Semantics are secondary
- Choose a personality

### Step 3: Clean up layout, spacing, and typography with systems
Replace ad hoc visual decisions with a constrained system.

1. Start by increasing white space more than feels necessary, then reduce it deliberately.
2. Check whether grouped elements have tighter internal spacing and more space around the group.
3. Create or infer a spacing and sizing scale instead of suggesting arbitrary pixel nudges.
4. Keep elements only as wide as they need to be. Do not stretch components just to fill space.
5. Recommend fixed widths or max widths when that serves the content better than fluid grid behavior.
6. Create or infer a type scale with a limited number of font sizes.
7. Use weight and contrast before increasing font size too aggressively.
8. Check line length, alignment, and line-height for readability.
9. For mixed text sizes on one line, align by baseline rather than center.
10. Suggest fewer borders and more separation through spacing, background shifts, or shadows.

Apply these principles:
- Start with too much white space
- Establish a spacing and sizing system
- Avoid ambiguous spacing
- Establish a type scale
- Keep your line length in check
- Baseline, not center
- Line-height is proportional
- Grids are overrated
- Relative sizing doesn’t scale

### Step 4: Refine color and contrast
Use color to support hierarchy, not to substitute for it.

1. If the structure is weak, recommend reviewing the design in grayscale first.
2. Build or infer a palette that includes:
   - a grey scale
   - one primary color scale
   - accent colors only where needed
3. Recommend fixed shades up front instead of one-off tints.
4. Use HSL-style reasoning when suggesting color adjustments:
   - hue for color family
   - saturation for intensity
   - lightness for brightness
5. On colored backgrounds, do not suggest plain grey text or reduced-opacity white as the default fix. Hand-pick a related color that reduces contrast cleanly.
6. If accessibility and emphasis are fighting each other, flip the contrast:
   - dark text on a light tint instead of white text on a dark block
7. Make sure color is never the only signal for status, change, or meaning.

Apply these principles:
- Ditch hex for HSL
- You need more colors than you think
- Define your shades up front
- Don’t use grey text on colored backgrounds
- Accessible doesn’t have to mean ugly
- Don’t rely on color alone

### Step 5: Add depth, image treatment, and finishing touches
Only add polish after hierarchy and systems are working.

1. Decide whether the screen needs raised, inset, or flat elements.
2. Use shadows to communicate elevation, not decoration.
3. If helpful, suggest a small elevation system with a few shadow levels.
4. Use two-part shadows when the design needs both soft separation and a crisp contact shadow.
5. Use lighter surfaces to feel raised and darker surfaces to feel recessed.
6. If the screen uses images:
   - prefer high-quality photos
   - preserve text contrast with overlays, lowered image contrast, or colorizing
   - respect intended image size
   - control user-uploaded image cropping and containment
7. Improve empty states so the first-use experience is intentional.
8. Add accent borders, subtle background decoration, or overlap only if they reinforce the hierarchy instead of distracting from it.

Apply these principles:
- Emulate a light source
- Use shadows to convey elevation
- Shadows can have two parts
- Even flat designs can have depth
- Text needs consistent contrast
- Everything has an intended size
- Don’t overlook empty states
- Add color with accent borders

### Step 6: Deliver a prioritized refactor plan
Provide an output the user can act on immediately.

Organize the response into:
1. Screen diagnosis
2. Primary action and hierarchy summary
3. Top issues ranked by impact
4. Exact refactor recommendations
5. Optional system suggestions for spacing, type, color, and elevation
6. A smallest useful next iteration the user can ship now

For each recommendation, include:
- what is wrong
- what to change
- why it works
- how urgent it is

Prefer concrete language such as:
- reduce emphasis on the sidebar
- combine label and value into one readable unit
- widen the gap between form groups
- replace three button styles with primary, secondary, and tertiary
- convert the status chip to dark text on a light tint
- remove borders and separate sections with background contrast and spacing

## Diagnostic Questions
Before proceeding, ask the user:

- What exact screen or feature do you want to improve?
- Do you have a screenshot, mockup, or text description of the current UI?
- What is the primary action on this screen?
- What are users most likely trying to find, understand, or do first?
- Who is the audience, and should the interface feel serious, playful, neutral, premium, or something else?
- Is this a dense power-user screen or a simpler task-focused screen?
- Are there brand constraints for fonts, colors, radius, or tone of voice?
- Are there accessibility requirements or known contrast issues?
- Which part feels worst right now: hierarchy, spacing, typography, color, depth, content, or consistency?
- Do you want a quick critique, a prioritized refactor plan, or suggested design tokens and system values?

## Output Format
A complete successful output should include:

1. A one-paragraph diagnosis of the current screen
2. A hierarchy map naming:
   - primary content
   - secondary content
   - tertiary content
   - primary action
   - secondary actions
3. A prioritized refactor plan grouped under:
   - hierarchy
   - layout and spacing
   - typography
   - color and contrast
   - depth and polish
4. Concrete before-and-after style recommendations, not vague opinions
5. Optional reusable system guidance such as:
   - spacing scale
   - type scale
   - color shades
   - elevation levels
6. A smallest useful version to ship now, with deferred nice-to-have ideas clearly separated

## Examples

### Example 1: Cluttered dashboard
User says: "Critique this dashboard and make it feel less busy"
Claude should:
1. Identify the primary goal of the dashboard and the single most important metric or action
2. Map competing elements into primary, secondary, and tertiary layers
3. Recommend de-emphasizing side information, reducing borders, and simplifying action styles
4. Apply spacing, type, and color system fixes instead of arbitrary one-off tweaks
5. Return a prioritized refactor plan with quick wins and deeper improvements
Result: A screen review that clarifies the main metric, reduces noise, simplifies button hierarchy, improves spacing, and gives the user a concrete order of changes to make

### Example 2: Polishing a signup form
User says: "What should I change in this signup form to make it look more polished?"
Claude should:
1. Start with the form as a feature, not the overall page shell
2. Identify the primary action and remove or defer nonessential elements
3. Check form-group spacing so labels and inputs read as clear units
4. Improve typography, action hierarchy, and empty-state or helper text treatment
5. Suggest a restrained color and shadow treatment only after the structure is fixed
Result: A focused set of improvements such as more generous spacing, clearer grouping, a stronger primary button, fewer borders, better label treatment, and a cleaner personality

### Example 3: Designing a new feature state
User says: "Help me design a flight search screen from scratch"
Claude should:
1. Start with the core feature fields and search action instead of navigation or page chrome
2. Define the smallest useful version that can ship
3. Lay out the feature with strong hierarchy in grayscale first
4. Recommend a spacing scale, type scale, and simple action hierarchy
5. Add color, personality, and elevation only after the feature structure is solid
Result: A practical feature-first UI plan that avoids over-designing the full app and gives the user a shippable first version of the screen

## Key Concepts from the Book
- Start with a feature, not a layout
- Design the smallest useful version first
- Work in short design and implementation cycles
- Visual hierarchy is the core of good interface design
- Emphasize by de-emphasizing competing elements
- Labels are a last resort
- Separate visual hierarchy from document hierarchy
- Build systems for spacing, sizing, type, color, and shadows
- Use HSL thinking and define color shades up front
- Accessibility should support clarity without making the interface harsh
- Depth comes from light, elevation, overlap, and surface contrast
- Finishing touches only matter after hierarchy and systems are working

## Troubleshooting
### If user is stuck at "everything feels equally important":
Start by identifying one true primary action and one primary content block. Reduce emphasis everywhere else using softer color, lighter weight, smaller size, or less prominent backgrounds. If needed, temporarily remove color and review the screen in grayscale to rebuild hierarchy first.

### If user is stuck at "I keep making tiny arbitrary tweaks":
Stop making one-off decisions. Create a limited spacing scale, type scale, color scale, and action hierarchy, then choose by process of elimination from those options instead of nudging values one at a time.

### If user is stuck at "the design still feels plain after cleanup":
Check whether the basics are already solid. Then add restrained polish through elevation, accent borders, background decoration, empty-state design, improved image treatment, or overlapping layers. Do not add decorative effects until hierarchy, spacing, and contrast already work.
