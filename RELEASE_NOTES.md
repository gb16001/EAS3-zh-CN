# v1.0.0 — Elmo Application Studio III 简体中文语言包

首个公开发布版本。适用于 **Elmo Application Studio III 3.0.0.26**。

## 下载

- `EAS3-zh-CN-v1.0.0.zip`
  SHA-256：`d9496e621527f83c7d478cedaa7abf190ff5bd6091ae68c8077b63d7b905d4a0`

## 安装

解压后任选一种方式：

1. 把 `zh-CN` 文件夹复制到 EAS III 安装目录，与 `ElmoMotionControl.View.Main.exe` 同层；
2. 以管理员身份运行 `install.ps1`。

装完启动 EAS III 即为中文界面。卸载只需删除 `zh-CN` 文件夹，或运行 `uninstall.ps1`。

## 本版内容

- 130 个中文卫星程序集（`zh-CN\*.resources.dll`）
- 15,349 条唯一英文字符串，写入 22,913 条资源条目
- 主程序导航栏、功能区、属性面板、错误提示、向导均已覆盖
- 不修改任何原文件，只新增 `zh-CN\` 目录，可完全还原

## 已知限制

- `Tuner.A`、`Tuner.Command`、`ErrorMapping.ViewModel`、`GMAS.Cad2Prt` 为混淆程序集，保持英文；
  其对应的 `Tuner.View/ViewModel/Model`、`ErrorMapping.View/Model` 已汉化。
- 标签页标题中的英文后缀 "Page" 由代码拼接，不在资源表中，未汉化。
- 内嵌浏览器的 Chromium 语言包（`locales\*.pak`）与帮助文档（`NetHelp`）不在本次范围内。
- 卫星程序集绑定 3.0.0.26；EAS 升级后需重新生成语言包，否则界面退回英文（不会报错）。

## 说明

非官方汉化包，与 Elmo Motion Control 无任何关联，仅供学习与个人使用。
