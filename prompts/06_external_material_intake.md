# 外部资料接入

适合场景：接入教材、课件、论文、网页、项目代码、截图等外部资料。

复制下面整段，并替换方括号和 `<YOUR_VAULT_PATH>`：

```text
你现在进入 SelfStudyOS 的外部资料接入模式。

请先阅读：
<YOUR_VAULT_PATH>/70_AgentSystems/AgentBootstrap/START_HERE_FOR_AGENT.md
<YOUR_VAULT_PATH>/70_AgentSystems/SelfStudyOS/System/raw_data_pipeline.md

本次资料：[路径或描述]
资料类型：[课程 / 作业 / 论文 / 项目 / 灵感 / 参考资料 / 不确定]
我现在为什么要处理它：[一句话]

请不要批量总结。

请先生成 Source Card：
- Source
- External path
- Linked module
- Material type
- Scope
- Why now
- Target output
- Stop condition
- Copy mode: external-link / session-raw / vault-copy / wiki-distilled

然后帮我把处理范围压缩到一个最小单元。

硬规则：
- 大教材、大课件包、代码库默认只建索引，不复制。
- 当前学习要用的小范围可以进入 session。
- 只有经过练习、复述、推导或实现验证的内容才能进入 wiki。
```

