# 知味

知味 (ZhiWei) A food ingredient knowledge app for iOS/macOS built with SwiftUI. Features - Browse ingredient categories (vegetables, fruits, meats, etc.) - Detailed ingredient information including seasonality and storage tips

## 用途与 Target 判定

原生 Swift / SwiftUI 工程（已归档）

- 移动端：需要
- 智能硬件：可选（可搁置）

## 目标平台

| 平台 | 方式 | 产出 |
|------|------|------|
| 移动端 | 原生 Swift | IPA / App |
| 智能硬件 | 可选 | — |

## 技术栈信号

- 检测到：swift

## 命令

```bash
# Xcode 打开工程，或 swift build（若 SPM）
```

## 状态

已归档。默认只做必要修复与知识库同步，不新开大范围需求。

## 助手约束

- Loop：先定可验证 Done 与停止条件；每切片过验证环；失败回灌；详见 docs/LOOP_ENGINEERING.md
- Harness：遵循根 AGENTS「Harness Engineering」；Guide=本文件，Sensor=测试/CI；同类失误二次须沉淀规则或测试（棘轮）。详见 docs/HARNESS_ENGINEERING.md
- 遵循仓库根 `/Users/skat/AGENTS.md` 与本文件的用途判定
- 可选 Target 可搁置；不适用形态不要硬加
- 改动聚焦；公共逻辑抽离复用
