# Elmo Application Studio III 简体中文语言包

版本 **1.0.0**，适用于 **Elmo Application Studio III 3.0.0.26**（`ElmoMotionControl.View.Main.exe`）。

> 非官方汉化包，与 Elmo Motion Control 无任何关联。包内不含 EAS III 的任何原始程序文件。

## 这是什么

EAS III 是 WPF/.NET 应用，界面文字全部来自 .NET 资源表。本包提供 130 个
**卫星程序集**（`zh-CN\*.resources.dll`），.NET 在系统 UI 语言为中文时会自动加载它们，
把英文界面显示成简体中文。

**本包不改动任何原有文件**：exe、DLL、配置、注册表一律不动，只是新增了一个
`zh-CN\` 子目录。卸载就是删掉这个目录。

## 包内文件

| 文件 | 用途 |
| --- | --- |
| `zh-CN\` | 130 个中文卫星程序集 |
| `install.ps1` | 安装脚本（自动装到默认路径） |
| `uninstall.ps1` | 卸载脚本 |
| `verify.ps1` | 校验脚本，统计已装条目数 |

## 安装

**方式一：手动复制（最简单）**

把 `zh-CN` 整个文件夹复制到 EAS III 的安装目录下，与 `ElmoMotionControl.View.Main.exe`
放在同一层：

```
C:\Program Files\Elmo Motion Control\Elmo Application Studio III\zh-CN\
```

**方式二：用脚本**

以管理员身份打开 PowerShell，在本包目录下执行：

```
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

如果 EAS 装在别的位置：

```
powershell -ExecutionPolicy Bypass -File .\install.ps1 -AppDir "D:\你的路径\Elmo Application Studio III"
```

装完直接启动 EAS III，界面即为中文。

## 卸载

删除安装目录下的 `zh-CN` 文件夹即可，或执行：

```
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## 校验

```
powershell -ExecutionPolicy Bypass -File .\verify.ps1
```

会输出已安装的卫星程序集数量和中文条目数。

## 覆盖情况

- 已汉化：15,349 条唯一英文字符串，写入 22,913 条资源条目
- 保留原文：品牌名、单位符号、IEC 61131 代码模板、枚举名、错误码等约 825 条
- 主程序导航栏、功能区、属性面板、错误提示、向导均已覆盖

## 已知限制

1. 以下 4 个程序集经过混淆，其资源以"链接资源"形式指向一个已被合并、实际不存在的
   程序集名，无法读取，保持英文：
   `Tuner.A`、`Tuner.Command`、`ErrorMapping.ViewModel`、`GMAS.Cad2Prt`。
   它们对应的 `Tuner.View/ViewModel/Model`、`ErrorMapping.View/Model` 已汉化。
2. 标签页标题里的英文后缀 "Page"（如"轴配置 Page"）是代码拼接的，不在资源表中，未汉化。
3. `locales\*.pak` 是内嵌浏览器的 Chromium 语言包，与界面语言无关，未改动。
4. 帮助文档（`NetHelp`）为独立 HTML 帮助，不在本包范围内。

## 兼容性

卫星程序集绑定了主程序的版本号 3.0.0.26。EAS III 升级后需要重新生成语言包，
否则 .NET 会因版本不匹配而忽略它们（界面退回英文，不会出错）。

## 免责声明

本包为非官方作品，仅供学习与个人使用，与 Elmo Motion Control 无关。
安装前请自行评估风险；如原厂提出要求，请停止使用并删除本包。

> 作者：gb
