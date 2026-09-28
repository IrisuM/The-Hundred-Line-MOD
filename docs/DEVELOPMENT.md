# 开发说明

## 目录

| 路径 | 用途 |
| --- | --- |
| `src/mod.cpp` | WinMM 代理初始化、配置、日志和补丁安装 |
| `src/patches.h` | PE 可执行节扫描、目标校验、倍率行为与内存写入 |
| `src/signatures.h` | 当前已验证的 AOB 特征码 |
| `src/generated/` | 自动生成并纳入版本管理的 WinMM 导出与汇编跳板 |
| `tools/generate_proxy.py` | 根据系统 WinMM 导出表重新生成代理文件 |
| `tests/` | 原指令执行验证及独立 DLL 宿主 |
| `docs/RESEARCH.md` | 补丁点逆向依据 |
| `VERSION` | 构建、日志、安装记录和发行包的统一版本号 |

工作目录的 `.analysis/`、`.deps/`、`.tools/` 为本地分析缓存和工具，不纳入 Git；`build/`、`dist/`、`release/` 为可再生成产物，同样忽略。游戏二进制、存档和提取出的机器码不进入仓库。

## 常用命令

需要 Windows x64、Visual Studio C++ x64 Build Tools 和 Windows SDK。Python 3 仅用于代理导出重建及独立宿主测试。

```powershell
# 编译（不安装、不启动游戏）
.\build.ps1

# 实际原指令和 WinMM 转发测试
.\dist\verify.exe 'D:\游戏目录\HUNDRED_LINE.exe' "$PWD\dist\winmm.dll"

# 实际 DLL 加载、配置及重复特征码保护测试
.\test-integration.ps1 -GameExe 'D:\游戏目录\HUNDRED_LINE.exe'

# 重新构建并生成二进制包、源码包和 SHA-256 清单
.\package.ps1

# 使用刚验证过的产物打包
.\package.ps1 -SkipBuild
```

## 修改约定

- 保留已有配置键的兼容性；币和四类素材共用 `MaterialMultiplier`。
- `build.ps1` 将根目录 `HundredLineMod.ini` 嵌入 DLL，作为首次启动生成配置的模板；修改模板后需要重新构建。生成采用 `CREATE_NEW`，不覆盖已有配置。
- 喜好功能作用于选择礼物后的赠送对象列表；角色档案「想要的事物」不在当前补丁范围内。
- 更换特征码时同时更新逆向依据，执行唯一性校验和原指令测试；不以固定地址替代扫描。
- 手写 C++ 按 `.clang-format` 格式化，`src/generated/` 通过脚本生成，避免手动修改。
- 测试程序与真正的游戏都可能名为 `HUNDRED_LINE.exe`；测试日志始终留在 `build/`，不能当作游戏实测日志。
- 用户确认的实际功能效果与自动化测试结果分别记录在 `VALIDATION.md`。
