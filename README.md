# Elmo Application Studio III 简体中文语言包

Elmo Application Studio III（EAS III）的**非官方简体中文汉化包**，适用于 **3.0.0.26**。
官方与开源社区均无中文语言包，本项目通过 .NET 卫星程序集实现界面汉化。

> 非官方项目，与 Elmo Motion Control 无任何关联。本仓库不包含 EAS III 的任何原始程序文件，
> 只包含翻译数据、构建脚本和生成的中文卫星程序集。

## 下载与安装

到 [Releases](../../releases/latest) 下载最新的 `EAS3-zh-CN-v*.zip`，然后任选一种方式：

**方式一：手动复制（最简单）**

把 `zh-CN` 整个文件夹复制到 EAS III 安装目录下，与 `ElmoMotionControl.View.Main.exe` 同层：

```
C:\Program Files\Elmo Motion Control\Elmo Application Studio III\zh-CN\
```

**方式二：用脚本**

以管理员身份打开 PowerShell，在解压后的目录中执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

EAS 装在别处时加 `-AppDir "D:\...\Elmo Application Studio III"`。装完启动 EAS III 即为中文界面。

卸载只需删除安装目录下的 `zh-CN` 文件夹，或执行 `uninstall.ps1`；`verify.ps1` 可统计已安装的条目数。

## 覆盖情况

| 项目 | 数量 |
| --- | --- |
| 扫描的程序集 | 134 |
| 已汉化程序集 | 130 |
| 唯一英文字符串 | 15,349 |
| 实际写入条目（含跨模块重复） | 22,913 |
| 保留原文（品牌名、单位、代码、枚举） | 825 |

主程序 `ElmoMotionControl.View.Main.exe` 自身也带一份 resx（左下角活动导航等 23 条），
已一并汉化为 `ElmoMotionControl.View.Main.resources.dll`。

## 原理

EAS III 是 WPF/.NET 应用，界面文案全部走 .NET 资源管理器（XAML 通过 `{x:Static}` 引用资源键），
.NET 在 `CurrentUICulture` 为 `zh-CN` 时会自动到程序目录下的 `zh-CN\` 子目录查找同名卫星程序集。

因此本汉化**只新增一个 `zh-CN\` 目录**，内含 130 个 `<程序集名>.resources.dll`；
原 exe、原 DLL、配置文件、注册表一律不改动，删除该目录即完全还原。

## 兼容性

卫星程序集绑定了主程序版本 **3.0.0.26**。EAS III 升级后需要重新生成语言包，
否则 .NET 会因版本不匹配而忽略它们（界面退回英文，不会出错）。

## 已知限制

1. 以下 4 个程序集经过混淆，其资源以"链接资源"形式指向一个已被合并、实际不存在的程序集名，
   无法用常规方式读取，保持英文：`Tuner.A`、`Tuner.Command`、`ErrorMapping.ViewModel`、`GMAS.Cad2Prt`。
   对应的 `Tuner.View/ViewModel/Model`、`ErrorMapping.View/Model` 已汉化。
2. 标签页标题里的英文后缀 "Page"（如"轴配置 Page"）由代码拼接，不在资源表中，未汉化。
3. `locales\*.pak` 是内嵌 CefSharp 浏览器的 Chromium 语言包，与界面语言无关，未改动。
4. 帮助文档（`NetHelp`）为 HTML 帮助，不在本次范围内。

## 仓库结构

```
data/
  index.json          程序集/资源流/资源键 -> 字符串 ID
  translations.json   字符串 ID -> 中文译文
scripts/              提取、翻译、质检、打包脚本
  dev/                开发期探查脚本（一般无需使用）
release/              本地打包输出（不提交）
```

`catalog/`、`work/`、`dist/` 为本地生成的中间目录，不提交。

## 重新打包

只需重新生成发布包时，用已提交的 `data/` 即可，无需原程序：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/make_package.ps1
```

输出 `release/EAS3-zh-CN-v1.0.0.zip`。

完整流水线（从已安装的 EAS III 重新提取资源并翻译）：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/extract_all.ps1 -Dir "<EAS 安装目录>" -OutDir catalog
powershell -ExecutionPolicy Bypass -File scripts/extract_exe.ps1 -Exe "<EAS 安装目录>\ElmoMotionControl.View.Main.exe" -Out catalog\ElmoMotionControl.View.Main.exe.json
python -I scripts/build_inventory.py      # catalog/ -> work/strings.json + data/index.json
python -I scripts/translate.py plan       # 切分翻译批次
python -I scripts/translate.py run        # 调用 Codex 翻译（可 --shard 0/3 并行）
python -I scripts/qa.py                   # 质量报告
powershell -ExecutionPolicy Bypass -File scripts/make_package.ps1
```

翻译步骤默认使用 `~/.claude/skills/codex/scripts/codex_ask.py`，可用环境变量 `CODEX_ASK`
指向其他包装脚本；只重新打包则无需这一步。

## 免责声明与许可

本汉化包为非官方作品，仅供学习与个人使用，与 Elmo Motion Control 无关。
如原厂提出要求，请停止使用并删除本包。

仓库中的构建脚本采用 MIT 许可（见 [LICENSE](LICENSE)）；汉化文本与生成的中文卫星程序集
不主张额外版权，请勿用于商业再分发。

## 作者

gb
