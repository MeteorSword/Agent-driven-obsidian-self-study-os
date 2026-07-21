# Skill 外部引用清单

记录每个 skill 引用了哪些 vault 内外部文件。供平台适配时打包参考。

路径变量定义见 `${OPERATING_RULES}` 的路径变量表段。

## selfstudyos-workflow
- ${OPERATING_RULES} — 规则定义（复习债务路由、stale 规则等）
- ${STARTUP_PROMPT} — First Move 引用
- ${REVIEW_PROGRESS} — Daily Learning step1
- ${TODAY_STATUS} — Daily Learning step2
- ${ACTION_QUEUE} — Daily Learning step2, step4, step8
- ${REVISION_NOTES} — Daily Learning step8
- ${MATERIAL_QUEUE} — Daily Learning step6
- ${AGENTS} — First Move
- ${HOME} — First Move
- ${LEARNER_PROFILE} — First Move

## selfstudyos-course-workflow
- ${OPERATING_RULES} — 三模式规则、Hint 分层、桥接题/补丁标记、题号格式
- ${LEARNING_CLOSE_5LINES} — 收口段
- ${TODAY_STATUS} — 通用前置 step1、收口（主线变更）
- ${ACTION_QUEUE} — 通用前置 step5、复习模式 step8、收口（archive）
- ${COURSE_MOC} — 通用前置 step2、开始学习模式 step1、复习模式 step1
- ${MATERIAL_QUEUE} — 开始学习模式 step1、作业模式 step1
- ${REVIEW_ENTRY} — 复习模式 step2
- ${REVISION_NOTES} — 复习模式 step2、作业模式 step11、收口
- ${STUDY_PLAN} — 考试冲刺模式
- ${EXAM_TOPIC_INDEX} — 开始学习模式 step2

## agent-material-intake
- ${MATERIAL_QUEUE} — 归档流程 step3（课程资料工单）
- ${EXTERNAL_MATERIAL_INDEX} — 归档流程 step3（非课程资料索引）
- agent-exam-mapping skill — 真题归档特殊提示（用户确认后调用）

## agent-memory-write
- ${MEMORY_INDEX} — 写入流程 step2（查重）、step4（更新索引）、读取规则
- ${AGENT_MEMORY_DIR} — 写入流程 step2（新建 feedback）、硬约束

## agent-exam-mapping
- ${EXAM_TOPIC_INDEX} — 映射流程 step4
- ${CONCEPT_INDEX} — 映射流程 step3
- agent-material-intake skill — 协作关系（归档后用户确认调用）

## agent-weekly-review
- ${WEEKLY_REVIEW} — 复盘流程 step2、step3
- ${DAILY_NOTE_DIR} — 复盘流程 step1、step4
- ${REVIEW_PROGRESS} — 复盘流程 step1、step4、step5
- ${TODAY_STATUS} — 复盘流程 step4
