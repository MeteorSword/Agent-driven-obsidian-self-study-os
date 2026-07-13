# Raw Data Pipeline

目标：让原始资料进入系统后，被拆成可学习、可练习、可复用的内容。

## 总原则

人负责投放 raw data 和做判断。

Agent 负责：

- 分类
- 提取
- 提问
- 组织
- 更新 wiki
- 记录进度

但 agent 不能替代用户完成学习证据。

## 资料放置规则

- 课程资料（真题、PPT、教材、作业）：放 `10_Courses/<课程名>/<类型>/`。
- 非课程资料（论文、书籍、网页剪藏）：放 `70_AgentSystems/SelfStudyOS/Raw/<类型>/`。
- 大文件优先放在 Vault 外部，只在 `60_Resources/ExternalIndexes/external_material_index.md` 中记录路径。
- 实体文件不放进 `CourseOS/<课程名>/raw/`，那里只存 material_queue.md 工单。

## 8 步流程

### 1. Capture

把原始资料放入合适位置：

- 课程资料 → `10_Courses/<课程名>/<类型>/`
- 非课程资料 → `70_AgentSystems/SelfStudyOS/Raw/<类型>/`
- 大文件 → 保留外部，在 `60_Resources/ExternalIndexes/external_material_index.md` 记路径

### 2. Classify

判断资料类型：

- 课程
- 作业
- 错题
- 论文
- 项目
- 灵感
- 参考资料

### 3. Scope

每次只处理一个小范围。

### 4. Extract

提取核心概念、前置知识、公式、例题、误区和必须练的题型。

### 5. Interrogate

Agent 先问用户：

- 你觉得这个知识点解决什么问题？
- 你能不能不用书面定义复述？
- 你能不能做一个最小例题？
- 你卡住的是概念、公式、计算还是题型？

### 6. Practice

进入练习：

- 课程：做题。
- 项目：实现一个可验证小任务。
- 论文：回答 Reading Mission。
- 概念：复述、举例、连接到已有知识。

### 7. Distill

只把稳定内容放进 wiki。

### 8. Lint

定期检查：

- 哪些 concept 没有来源？
- 哪些 mistake 没有复习动作？
- 哪些 question 太大？
- 哪些 connection 没有证据？
- 哪些页面没有被 MOC 索引？

