# 百日战记 HundredLineMod

Windows x64 原生 MOD，使用 `winmm.dll` 代理加载，在游戏进程内通过 AOB 特征码扫描应用补丁。无需 BepInEx，不修改游戏 EXE、资源包或存档文件。

## 功能

- **锁定探索素材与币倍率**：探索币及四类探索素材默认固定为 **5 倍**，覆盖 TOTAL POINTS 的全部五行。是最终倍率覆盖，不是在原有加成上再乘一次；游戏内倍率变化不会影响锁定值。不会改变素材种类抽选、稀有度或背包上限。1.1 版补上了 1.0 版遗漏的币倍率。
- **显示送礼喜好**：送礼对象列表显示当前礼物对应的真实喜好图标，包括尚未送过的礼物。使用游戏自身的喜好数据和图标，不将所有礼物改成喜欢，不修改赠送历史。

查看位置：选择一件礼物后，在选择赠送对象的角色列表中查看喜好图标。角色档案 `REPORT CARD → 想要的事物` 页不在补丁范围内，该页的 `???` 不会被解锁。

## 安装与配置

关闭游戏，运行 `install.ps1`，或仅将发行包内 `winmm.dll` 放到 **HUNDRED_LINE.exe 同级目录**，然后从 Steam 正常启动游戏。配置文件不存在时，DLL 会在同目录自动生成 `HundredLineMod.ini`，默认启用 5 倍探索素材与币、送礼喜好显示；已有配置不会被覆盖。

目录无法写入时会尝试记录错误，配置不可用时仍使用内置默认值。生成配置过程中若写入失败，则本次停止应用补丁并记录错误。

其他安装位置：

```powershell
.\install.ps1 -GameDirectory 'D:\你的游戏目录'
```

如果已有其他 MOD 的 `winmm.dll`，安装脚本会拒绝覆盖；本版本不提供多个同名代理 DLL 的链式加载。

在游戏目录的 `HundredLineMod.ini` 中配置：

```ini
[Mod]
Enabled=1
LockExplorationMaterials=1
MaterialMultiplier=5.0
ShowGiftPreferences=1
```

开关接受 `0` / `1`。`LockExplorationMaterials` 和 `MaterialMultiplier` 为兼容旧配置保留原名，现在同时控制币和四类素材。倍率接受 `1.0`～`100.0`，精确到百分之一倍，整数结算仍按游戏原来的取整规则执行。修改后重启游戏，重新打开送礼菜单／触发下一次探索结算。

加载结果在游戏目录 `HundredLineMod.log`：应有 `APPLIED materials`、`APPLIED gift preferences` 和 `Initialization complete`。日志中 `NOT APPLIED` 表示校验失败；特征码缺失或重复时不会应用任何启用的补丁。

## 卸载

脚本安装的版本：关闭游戏后运行 `uninstall.ps1`。它核对安装记录和 DLL 哈希，仅移除本 MOD 的 DLL 与安装记录，保留配置及日志。

手动安装的版本：关闭游戏后移走放入的 `winmm.dll` 即可。重启后恢复原游戏行为。已通过正常游戏结算获得并保存的素材不会因卸载而扣回。

## 构建与验证

需要 Visual Studio C++ x64 Build Tools 和 Windows SDK；发布 DLL 使用静态 C++ 运行库。生成的 WinMM 导出文件已包含在源码中，普通构建不需要 Python。

```powershell
.\build.ps1
.\dist\verify.exe 'D:\你的游戏目录\HUNDRED_LINE.exe' "$PWD\dist\winmm.dll"
```

如需重新从本机系统 WinMM 生成代理导出，执行 `build.ps1 -RegenerateExports`，这一步需要 Python 3。WinMM 的 180 个命名导出和 ordinal 2 均保留，x64 汇编转发保存寄存器参数与栈参数，真实 DLL 仅从 System32 的绝对路径加载。

代理允许系统缺少未使用的导出（例如 Wine/Proton 的 `WOWAppExit`），并记录函数名与序号；只有实际调用缺失函数时才记录错误并终止进程。运行 `test-proxy.ps1` 可在无需游戏 EXE 的情况下模拟缺失导出并验证转发。此检查不能替代 SteamOS/Proton 实机验证。

验证程序只读映射游戏 EXE，检查两个特征码唯一性，并复制游戏的实际机器码到测试页运行：检查币与四类素材锁定、越界类型回退、恢复原指令，以及五种真实礼物喜好的显示分支。还验证 WinMM 导出和真实 API 转发。它不会运行游戏场景或修改存档。

完整 DLL 加载与配置保护测试：运行 `test-integration.ps1 -GameExe 'D:\你的游戏目录\HUNDRED_LINE.exe'`（需要 Python 3）。测试只使用独立宿主与提取的指令片段。

## 已分析版本及限制

- 本机 `gamedata/disp_revision`：`85162`。
- `HUNDRED_LINE.exe` SHA-256：`04FDA45AB7D5D639EF3DC8AFA00C90CB29E11C0E19D69390C221A01DC4457E9A`。
- 不使用固定绝对地址进行定位；扫描主 EXE 的可执行节。当前版本的参考 RVA 仅用于分析记录，不参与寻址。
- 已完成离线原生代码测试；实际游戏启动与场景验证结果见 `VALIDATION.md`。
- 仅支持启动时加载，不能在游戏运行中热替换／卸载 DLL。未来更新可能改变指令、结构或功能语义；特征码扫描不能保证任意版本兼容。

代码结构、构建和打包流程见 [开发说明](docs/DEVELOPMENT.md)，详细逆向依据见 [定位依据](docs/RESEARCH.md)。
