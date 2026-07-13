---
name: selfstudyos-workflow
description: Use this skill when working in an Obsidian SelfStudyOS vault, starting a self-study session, ingesting course/research/project materials, updating a learning knowledge base, or running CourseOS, ResearchWiki, ProjectLab, problem-loop, course-review, reading-mission, or weekly-review workflows.
---

# SelfStudyOS Workflow

Use this skill to operate an Obsidian-based AI self-study system.

The user should provide the Vault path. If they do not, ask for it once or infer it from the current workspace.

## First Move

Before making recommendations or editing notes, read:

1. `70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md`
2. `70_AgentSystems/SelfStudyOS/AGENTS.md`
3. `70_AgentSystems/SelfStudyOS/home.md`
4. `70_AgentSystems/SelfStudyOS/System/learner_profile.md`
5. `70_AgentSystems/SelfStudyOS/Review/progress.md`

Then choose the smallest relevant workflow.

## Workflow Selection

### Daily Learning

Use when the user wants to study, start the day, review progress, or asks what to do next.

1. Check `Review/progress.md`.
2. Read `01_LearningDesk/02_今日状态.md` and `01_LearningDesk/03_行动队列.md`.
3. Choose one main task.
4. Report whether due review exists, but do not expand review debts unless the learner chooses review mode.
5. Default to the current main course unless the user names another course.
6. Open the matching CourseOS MOC and raw queue.
7. Ask for the user's current understanding, first attempt, or cold-recall output.
8. Use layered hints before answers.
9. End by updating progress and next action only when meaningful.

### Material Intake

Use when the user gives raw material, external folders, PDFs, PPTs, papers, code, or screenshots.

1. Classify the material: course, assignment, paper, project, direction, reference.
2. Route the file:
   - Course material → `10_Courses/<CourseName>/<Type>/` (真题/PPT/教材/作业)
   - Non-course material → `70_AgentSystems/SelfStudyOS/Raw/<Type>/` (papers/books/clips)
   - Large external file → keep outside vault, index in `60_Resources/ExternalIndexes/external_material_index.md`
   - Do not put entity files in `CourseOS/<CourseName>/raw/` — that folder only holds `material_queue.md`
3. Update the material queue: add a row in `CourseOS/<CourseName>/raw/material_queue.md` with the file path.
4. Choose processing mode:
   - `external-link`: path or URL only
   - `session-raw`: referenced in a learning session
   - `vault-copy`: small file copied for repeated annotation
   - `wiki-distilled`: stable knowledge after evidence
5. Never bulk-copy or bulk-summarize external folders.
6. Create or update the relevant course/project/research queue.

### CourseOS

First identify the mode:

- Start-learning mode: new concept, new section, or not ready for full homework.
- Homework mode: real assigned problems, textbook exercises, screenshots, or a specified problem set.
- Review mode: cold recall, mistake replay, spaced review, or concept gap checks.

For homework or exercises:

1. Ask the learner to attempt first.
2. Identify the stuck point: concept, formula, calculation, modeling, or pattern recognition.
3. Give Hint 1, Hint 2, Hint 3 before a full solution.
4. Do not expand `Review/revision_notes.md` by default.
5. If a review debt directly blocks the current problem, insert only a 3-10 minute prerequisite patch, then return to the original problem.
6. Record mistakes only when there is evidence.

For a learning session:

1. Read the course MOC and raw queue.
2. Narrow the task to one small unit.
3. Ask 2-5 diagnostic questions.
4. Teach only after the learner responds.
5. Do not expand review debts unless they directly block the current topic.
6. Require a recap, example, or minimal exercise.
7. Update progress only when meaningful.

For review:

1. Read `01_LearningDesk/05_复习入口.md`, due review rows in `03_行动队列.md`, and `Review/revision_notes.md`.
2. Start with cold recall or mistake replay before explanation.
3. Record the pass mode: no hint / Hint 1 / Hint 2 / Hint 3 / after solution correction.
4. Update revision notes only when repeated evidence justifies it.

### ResearchWiki

Use when reading papers or exploring research directions.

1. Write a Reading Mission before reading deeply.
2. Pick target level L0-L4.
3. Most papers stop at L0/L1.
4. Only create paper/concept/connection/question pages after the mission has evidence.

### ProjectLab

Use when working on projects, portfolios, demos, or ability trees.

1. Read `ProjectLab/project_lab.md`.
2. Record the real problem, user, demo state, AI-assisted parts, and missing abilities.
3. If foundation-course work is being avoided, say so directly and require a minimal course task first.
4. Map every project push to a skill or ability debt.

## Hard Rules

- Do not directly solve homework before the learner attempts or explains the stuck point.
- Do not batch ingest large folders.
- Do not turn sources into long summaries without practice evidence.
- Do not create decorative Obsidian links.
- Do not treat old notes as proof of current mastery.
- Do not expand review debts in homework or start-learning mode unless they directly block the current task.
- If the user drifts into projects to avoid foundations, point it out.

## Closeout

At the end of every session, report:

- Material handled
- What the learner did independently
- What AI helped with
- Remaining unclear point
- Next smallest action
- Files updated

Update the relevant `progress.md`, queue, concept index, problem index, mistake index, or review note when meaningful.
