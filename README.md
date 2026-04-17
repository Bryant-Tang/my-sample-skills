# Sample skills for .NET Framework

這是一套我自己在使用的 skill + rule + MCP tool + settings ，可編譯、執行 .NET Framework 專案，歡迎複製使用  
後續可能會持續更新 skill 內容

## 安裝步驟

1. 如果你還沒有，安裝 [Microsoft VS Code <font style="opacity: 0.2;">~~微軟大戰程式碼~~</font>](https://code.visualstudio.com/)
1. MCP 工具建議使用 Docker 運行，如果你還沒有，安裝 [Docker/Docker Desktop](https://www.docker.com/)，然後就可以直接使用 [.vscode/mcp.json](./.vscode/mcp.json)
    > 如果不使用 Docker ，請自行確保 [.vscode/mcp.json](./.vscode/mcp.json) 中的 MCP 工具都可運行，可以參考 [各個 MCP 官方連結](#參考連結)
1. 參考 [建議設定](./docs/recommend-settings.md) 安裝套件、設定 VS Code
    如果 VS Code 設定打算只應用在工作區範圍，可以等下一步驟建立完成後，在 VS Code 左側功能列 > 齒輪圖標 <img src="./docs/images/setting-icon.png" height="35"> > 設定 > 工作區 <img src="./docs/images/settings-workspace.png" height="35">
    - 右上的開啟設定(JSON) <img src="./docs/images/settings-go-to-json.png" height="30"> 當中編輯 settings
    - 或是不開啟設定(JSON)，逐項在介面搜尋然後調整設定
1. 參考 [本地 git + 遠端 svn 結構指南](./docs/git-repo-create-steps.md) 建立多 worktree 專案結構
1. DBHub 設定 ([.vscode/dbhub.toml](./.vscode.example/dbhub.toml))：把 `<DB_NAME>` 、 `<ACCOUNT>` 、 `<PASSWORD>` 、 `<DOMAIN>` 、 `<PORT>` 換掉
    - 注意 dsn 裡面的都要 url 編碼
    - 如果有多個資料庫可以直接複製整段貼上多個，像 `<DB_NAME_2>` 那樣
    - 如果只有單一資料庫，記得把 `<DB_NAME_2>` 那段刪掉
1. skill 腳本所需設定 ([.agents/skill-scripts.psd1](./.agents/skill-scripts.psd1))
    |設定項目|用途|是否必填|範例|
    |-|-|-|-|
    |BUILD_PROJECT_PATH|要建置的 csproj 相對路徑(相對於根目錄，不用`./`)|**必填**|`'XXXWeb/XXXWeb.csproj'`|
    |BUILD_MSBUILD_PATH|`MSBuild.exe` 絕對路徑|**必填**|`'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe'`|
    |BUILD_FRONTEND_DIR_PATH|前端目錄路徑(相對於根目錄，不用`./`) 如果沒有則 build 時不會打包前端||`'XXXWeb/'`|
    |BUILD_NODE_VERSION|打包前端前確認的 node 版本||`'v24.14.0'`|
    |BUILD_FRONTEND_INSTALL_COMMAND|打包前端前 install 前端套件指令||`@('npm', 'install')`|
    |BUILD_FRONTEND_BUILD_COMMAND|打包前端指令||`@('npm', 'run', 'build')`|
    |RUN_IIS_EXPRESS_PATH|`iisexpress.exe` 絕對路徑|**必填**|`'C:/Program Files/IIS Express/iisexpress.exe'`|
    |RUN_IIS_APPLICATIONHOST_CONFIG_PATH|`applicationhost.config`相對路徑(相對於根目錄，不用`./`)(可以直接用 Visual Studio 產生的那份，參考 [applicationhost.config 簡易配置指南](./docs/applicationhost-config-guild.md))|**必填**|`'.vs/XXXWeb/config/applicationhost.config'`|
    |TEST_LOCAL_STASH_SHA|本機測試用 stash 的 SHA，如果沒有則測試時不會套用 stash||`'fakeshaabcdefghijklmnopqrstuvwxyz0123456'`|
1. 開始開發之前
    你可以先叫 LLM 探索你的整個專案，讓他了解你的專案的概況，明確告訴他要記住，然後~~祈禱~~他以後工作時會自己想起來。例如:
    ```
    深度探索這個專案，了解整個專案的運作方式，然後記住
    ```
    如果你的專案有各種奇奇怪怪的特性、偏好，你也可以先跟 LLM 說，明確告訴他要記住，然後~~祈禱~~他以後工作時會自己想起來。例如:
    ```
    這個專案雖然看起來有各種單元測試，但目前全都是棄用狀態，你要記住
    ```
    ```
    這個專案雖然看起來有各種文件說明，但大部分已過時，你要記住一切以實際程式碼運作為主
    ```
    後續開發途中，你都可以繼續補充， LLM 判斷需要或是你明確要求他記住時，他都會記，然後~~祈禱~~他以後工作時會自己想起來。

## Skill 說明

***<font size=4 color="red">不要在同一個 chat session 中接續使用 skill</font>***，尤其是開發流程的 `start-dev`, `write-plan`, `implement-task`, `testing-and-proof`。  
因為 LLM 傾向在 context window 快要不足之前，草草收尾，以避免撞到上限。  
盡管現在 AI 供應商都有提供壓縮聊天內容指令，但壓縮內容通常會造成 LLM 丟失資訊，並且你無從得知 LLM 丟失哪些資訊，一來一回補給它更多資訊還會又造成 context window 不足，最終得到品質低下的產出。  
(<font style="opacity: 0.2;">~~LLM 腦容量沒有那麼多可以一次到位處理計畫加實作加測試~~</font>)

你需要閱讀開發流程中產生的 `sepcs/` 、 `sql files/` 內的文件，確認內容符合你所期望的，因為後續 LLM 會依照這些檔案工作，大原則是**可以缺但不能錯**，有缺可以補，但是有錯要改會很麻煩，效率上不如重新開始。

> (至少在 LLM 使用該檔案開始工作之前，要檢查。例如 write-plan 之前檢查 `goal.md` 、 implement-task 之前檢查 `plan.md` 、 testing-and-proof 之前檢查 `test-plan.md` 跟 `test-n.md`)

如果需要修改可以再跟 LLM 說，但建議盡量一次講完所有需要修改的地方，避免同一個 chat session 多次來回修改，超出 context window。如果真的超出 context window 觸發自動壓縮，建議停止然後另開 chat session 重新修改。

### 各 skill 詳細說明

以下是各個 skill 的詳細說明，一般狀況下，你通常只會用到 `/start-dev` 、 `/write-plan` 、 `/implement-task` 、 `/testing-and-proof` 、 `/commit-msg`。

#### start-dev

使用 `/start-dev` 指令開始一個需求，跟 LLM 討論需求，叫他幫你產生需求目標檔案 `goal.md`，建立對應 git 分支。

#### write-plan

使用 `/write-plan` 指令，會根據指定的 `goal.md`，規劃實作計畫、任務、測試計畫在 `specs/`。

目前 LLM 產生的 `plan.md` 品質沒有很好，你需要引導 LLM 細分太過龐大的任務或是加上更多 AC 條件，後續實作與審查時才會有良好的品質。

#### implement-task

使用 `/implement-task` 指令，會根據指定的 `plan.md`，依序呼叫 subAgent 實作，並呼叫 subAgent 依據 `plan.md` 中定義的 AC 審查。

雖然 LLM 會審查，但仍然強烈建議你在 commit 前，自己大致審查過所有程式碼變更，除非你極度信任 `plan.md` 中的 AC 條件，認為那些 AC 條件足以完美確保程式碼不會有錯誤。

如果任務很多但其實不互相依賴，可以並行實作，你可以叫他並行實作各個任務，但建議要加上叫他讓不同 subAgent 使用不同終端機，以避免同時多個 subAgent 互相衝突。

如果一份 `plan.md` 中有很多項任務，不建議一次實作太多任務。 因為:  
如果是依序實作任務，盡管實作跟審查都是 subAgent 負責，連續處理太多任務仍然可能導致 context window 不足。  
如果是並行實作任務，就算 LLM 成功完成，太多任務所造成的大量程式碼變更，會導致你需要一次審查大量程式碼，我個人的經驗是，光是看到變更清單的大量檔案，就會減少我審查程式碼的動力。

#### testing-and-proof

如果是可以運行起來在瀏覽器驗證的功能或是 bug ，可以用這個 `/testing-and-proof` 指令叫他根據 `test-plan.md` 、 `test-n.md` 驗證。  
這部分會先 apply 一份本機測試用 stash，然後再 build 、 run 、 test。  
(可以在 [skill-scripts.psd1](./.agents/skill-scripts.psd1) 裡面設定，如果留空就不 apply)

#### commit-msg

使用 `/commit-msg` 指令，直接告訴 LLM 你要 commit 哪個 wroktree 的變更、哪些變更...之類的，然後它會給你適合的 commit 訊息。

#### build-project

使用 `/build-project` 指令或讓 LLM 自己觸發，使用已寫好的 ps1 腳本建置 .NET Framework 專案，如果有設定前端打包，也會打包前端。  
(可以在 [skill-scripts.psd1](./.agents/skill-scripts.psd1) 裡面設定)

#### run-project

使用 `/run-project` 指令或讓 LLM 自己觸發，使用已寫好的 ps1 腳本運行 .NET Framework 專案在 IIS Express 上，需要先提供 applicationhost.config 檔案。  
(在 [skill-scripts.psd1](./.agents/skill-scripts.psd1) 裡面設定)

#### db-management

定義了 db 相關的規則，通常不用手動使用，除非他看起來忘記 db 相關規則，可以標給他叫他依照 db 規則。
- 分為 local 、 test 、 main
- read:
    - local 可以用 DBHub 直接讀取
    - test 、 main 會寫一段 sql 請使用者幫 LLM 查詢
- write:
    - 一律寫到 [sql files/](./sql%20files/) 裡面，請使用者執行

#### memory

定義了記憶相關的部分，通常不用手動使用。  
因為只有單純開 memory-server MCP 工具給 LLM 使用的話，它幾乎只在明確提到記憶相關字詞時才會使用，所以用這個 skill 讓它自主使用記憶。

## 其他建議指南

- [GitLens 簡易指南](./docs/gitlens-guild.md)
- [applicationhost.config 簡易配置指南](./docs/applicationhost-config-guild.md)

## 專案結構

```text
<YOUR_ROOT_DIR>\my-project\
    my-project\           # Git repo, Git branch: main  + SVN repo: /my-project/main
    my-project.worktrees\
        dev-1\              # 純 Git 開發目錄，在裡面切換 feature/A、bugfix/some-bug、...
        dev-2\              # 純 Git 開發目錄，在裡面切換 feature/A、bugfix/some-bug、...
        ...
        test-1\             # Git branch: test/rc1  + SVN repo: /my-project/test/test1
        test-2\             # Git branch: test/rc2  + SVN repo: /my-project/test/test2
        ...
```

## 未來發展

目前的這些 skill ，我自己的評價僅為*堪用*。

後續會持續精進以下方向，如果有建議也歡迎提出或是發 Issue ，或是直接提出 PR 給我都可以。

- 發布 skill ，目前只有 build 、 run 的 skill，未來考慮加入發布 skill 或其他需要使用 Visual Studio 的功能，目標是徹底告別肥厚的 Visual Studio 。
- 精進 `plan.md` ，目前產出的 `plan.md` 品質沒有到很好，像是 AC 條件不會包含安全性、可讀性...等等的檢查，未來目標是讓 `plan.md` 可以更完善，以提升實作品質。
- 精進 testing-and-proof ，目前這個測試 skill 不是很理想，經常遇到一點小問題就停止並回報 block，速度上來說甚至可能比人工依照 `test-plan.md` 來測試還慢，目標是改善這個測試流程，讓測試也可以有良好的效果跟速度。

## 參考連結

- [Microsoft VS Code](https://code.visualstudio.com/)
- [Docker](https://www.docker.com/)
- [GitLens](https://www.gitkraken.com/gitlens)
- MCP 工具:
    - [DBHub](https://github.com/bytebase/dbhub)
    - [Knowledge Graph Memory Server](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
    - [MarkItDown-MCP](https://github.com/microsoft/markitdown/tree/main/packages/markitdown-mcp)

## Licence
MIT.