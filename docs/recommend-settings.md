# 建議設定

## VS Code Extension

- [Chinese (Traditional) Language Pack for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-zh-hant)
  - [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
  - [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)
  - [One Dark Pro](https://marketplace.visualstudio.com/items?itemName=zhuangtongfa.Material-theme)
    (色彩主題，看你喜好安裝)
  - [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)

## VS Code Settings

建議設定如下，可以自行決定要使用哪些、自行決定使用者/工作區範圍
```json
{
    // 控制按兩下索引標籤時，編輯器群組調整大小的方式。當未設為 multiple 時，會忽略 Workbench › Editor: Show Tabs。
    // 個人覺得按兩下最大化比較方便，可自行決定
    "workbench.editor.doubleClickTabToToggleEditorGroupSizes": "maximize",


    // 當聊天中收到回應時播放音效/音訊提示。
    // 自行決定
    "accessibility.signals.chatResponseReceived": {
        "sound": "on"
    },
    // 當聊天中需要使用者採取動作時，播放訊號 - 音效 (音訊提示) 和/或公告 (警示)。
    // 自行決定
    "accessibility.signals.chatUserActionRequired": {
        "sound": "on"
    },
    // 聲音音量的百分比 (0-100)。
    // 自行決定
    "accessibility.signalOptions.volume": 100,
    // 控制在確認或問題需要需入時，聊天工作階段是否應向使用者顯示作業系統通知。這包括視窗徽章以及通知快顯通知。
    // 預設是 windowNotFocused ，如果常常會維持在 VS Code 視窗但放給他跑然後換去用別台電腦或手機，建議開
    "chat.notifyWindowOnConfirmation": "always",


    // 在整合終端機當中，控制輸入時是否應自動顯示建議。另外也請注意 Terminal › Integrated › Suggest: Suggest On Trigger Characters 設定，其會控制建議是否由特殊字元所觸發。
    // 開了比較方便，建議開
    "terminal.integrated.suggest.quickSuggestions": {
        "commands": "on",
        "arguments": "on",
        "unknown": "on"
    },
    // 是否要啟用下一個編輯建議
    // 開了比較方便，建議開
    "github.copilot.nextEditSuggestions.enabled": true,
    // 是否要在背景終端命令完成或需要輸入時，自動通知代理程式。啟用後，系統會向聊天工作階段傳送包含退出代碼與終端機輸出的導向訊息，且輸出監控器會持續執行以偵測輸入的提示。
    // 實驗性設定，目前體感沒什麼用，但看描述效果還不錯，也可以先開起來試試
    "chat.tools.terminal.backgroundNotifications": true,
    // 啟用後，聊天代理程式可使用瀏覽器工具開啟整合瀏覽器中的頁面並與其互動。
    // 建議開，幾乎等於 VS Code 內建 Playwright 工具，讓 LLM 可以操作瀏覽器
    "workbench.browser.enableChatTools": true,
    // 啟用記憶工具，讓代理程式在交談中儲存並重新叫用筆記。記憶儲存在 VS Code 的本機儲存空間中
    // 建議關閉，因為已使用 memory-server MCP 工具，重複的記憶工具會讓 LLM 不知道要使用哪個
    "github.copilot.chat.tools.memory.enabled": false,


    // GitLens
    // Specifies the preferred layout of the Commit Graph
    // 預設是在下方跟終端機同一群組，個人喜歡在中間跟編輯器一起
    "gitlens.graph.layout": "editor",
    // Specifies whether to dim (deemphasize) merge commit rows in the Commit Graph
    // Commit Graph 中淡化合併分支的 commit，自行決定
    "gitlens.graph.dimMergeCommits": true,
    // Specifies how the Commit Details view will display files
    // Commit 詳細資訊中以樹狀或列表檢視變更檔案，自行決定
    "gitlens.views.commitDetails.files.layout": "tree",
    // Specifies how the Search & Compare view will display files
    // 搜尋跟比較 詳細資訊中以樹狀或列表檢視變更檔案，自行決定
    "gitlens.views.searchAndCompare.files.layout": "tree",


    // Markdown Preview Enhanced
    // 打開 md 檔案時自動開啟預覽頁，自行決定
    "markdown-preview-enhanced.automaticallyShowPreviewOfMarkdownBeingEdited": true,
    // 以 GitHub 深色風格預覽 Markdown，自行決定
    "markdown-preview-enhanced.previewTheme": "github-dark.css"
}
```

## PowerShell Profile

先確認預設編碼，如果不是 utf-8 (Code Page: 65001)，建議改為預設 utf-8。
```PowerShell
[console]::OutputEncoding
[console]::InputEncoding
$OutputEncoding
```

查看預設 PROFILE 路徑
```PowerShell
$PROFILE
```

在 PROFILE 檔案裡面加入
```ps1
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
```
