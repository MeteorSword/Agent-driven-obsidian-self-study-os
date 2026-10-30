# migrations/ 目录说明

这里放**版本升级**用的数据文件。它不参与日常学习，只有升级时才被读取。

## 文件

| 文件 | 作用 | 谁读 |
|---|---|---|
| `index.json` | 版本链登记表。只列**真实发布过**的版本跳跃 | `scripts/upgrade.ps1` |
| `steps/` | 真实的升级步骤文件，如 `v1.0.0-to-v1.1.0.json`。当前为空（还没有 v1.1） | `scripts/upgrade.ps1` |
| `examples/` | 示例步骤，**永不登记进 index.json**，只用于工具自测 | 自测流程 |
| `index-<版本>.json` | 该版本的完整文件清单：路径 / 归属 / sha256 / 归一化哈希 / 起始版本 / 上次修改版本。由 `scripts/gen-index.ps1` 生成；同目录 `index-<版本>.md` 是人读树形版 | `scripts/upgrade.ps1` |

## 为什么示例不能进 index.json

`upgrade.ps1` 读 `index.json` 决定"从当前版本能升到哪"。如果把示例 `example-1.0.0-to-1.0.1.json` 登记进去，一个跑在 1.0.0 的用户会被"升级"到一个并不存在的 1.0.1，并且执行示例里那些假操作。

所以 `index.json` 的 `chains` 只允许指向 `steps/`，示例放 `examples/`，物理上够不到。

## 什么时候要动这里

**发布新版本时**（比如 v1.1.0）：

1. 写 `steps/v1.0.0-to-v1.1.0.json`（格式参照 `examples/` 那份，属性和操作类型完全一致）。
2. 在 `index.json` 的 `chains` 里加一条：
   ```json
   { "from": "1.0.0", "to": "1.1.0", "step": "steps/v1.0.0-to-v1.1.0.json" }
   ```
3. 跑 `scripts/gen-index.ps1 -Version 1.1.0` 更新归属清单。
4. 更新 `vault-template/99_Meta/SelfStudyOS_Version.md` 的版本号。

## 四种操作（只有这四种）

| 类型 | 能自动做 | 冲突时 | 说明 |
|---|---|---|---|
| `add` | ✅ | 跳过（视为已完成） | 新增文件，幂等 |
| `move` | ✅ | **停止整条链** | 移动/改名 |
| `replace` | ✅（先出 diff） | — | 按 glob 匹配文件，做文本替换 |
| `manual` | ❌ | **阻断** | 需要人/AI 判断，工具只登记不执行 |

**故意没有 `delete`。** 要删文件只能走 `manual`，由人自己删——迁移工具不做静默删除。

## 备份与回滚

`upgrade.ps1` 在执行 `-Apply` 前，会把所有将被触碰的文件备份到 Vault 内的 `.selfstudyos/backup/<时间戳>/`，然后才开始改。回滚就是"从备份恢复 + 删掉新增的文件"，不依赖语义反推。

因此 `.selfstudyos/` 属于机器数据，在 manifest 里是 `neverTouch`，也不应进入任何模板仓库。
