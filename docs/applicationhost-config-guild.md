# applicationhost.config 超簡易配置指南

1. 使用 Visual Studio 2022 (或更高版本) 打開你的 .NET Framework 解決方案
1. 找到根目錄下 `.vs/<YOUR_WEB_CSPROJ_NAME>/config/applicationhost.config`
1. 配置完成

### 複製使用

如果不同 worktree 你不想每一份都使用 Visual Studio 打開一次，可以直接複製同一份使用，但是要修改一個地方

1. 假設你是從 main 複製到 dev-1 worktree ，複製後打開該檔案
1. 搜尋 `physicalPath`
1. 找到一個看起來是你的 main 的絕對路徑，例如: `<YOUR_ROOT_DIR>\my-project\my-project\XXXWeb`
1. 修改它改成你的 worktree 路徑，例如: `<YOUR_ROOT_DIR>\my-project\my-project.worktrees\dev-1\XXXWeb`