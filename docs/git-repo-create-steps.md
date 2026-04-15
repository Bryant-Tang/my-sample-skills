# 本地 git 結構建立步驟

1. 建立專案資料夾 `<YOUR_ROOT_DIR>\my-project\` 、 `<YOUR_ROOT_DIR>\my-project\my-project\` 、 `<YOUR_ROOT_DIR>\my-project\my-project.worktrees\`
1. 在 `<YOUR_ROOT_DIR>\my-project\my-project\` 打開 VS Code
    (在檔案總管那個資料夾按右鍵選擇 **以 Code 開啟**)
1. VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30">，點 **初始化存放庫**
1. 把 [agent-pack.zip](../agent-pack.zip) 解壓縮放到 `<YOUR_ROOT_DIR>\my-project\my-project\`
1. 調整 [gitignore](../.gitignore.example) 當中的項目，裡面已經有建議項目，可自行修改
1. 設定 git config `user.name` 、 `user.email`
    (CMD / PowerShell / Bash)
    ```
    cd <YOUR_ROOT_DIR>\my-project\my-project\
    git config user.name "YOUR NAME"
    git config user.email "youremail@mail"
    ```
    或是全域設定
    ```
    git config --global user.name "YOUR NAME"
    git config --global user.email "youremail@mail"
    ```
1. 在 VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> 裡面
    1. 暫存所有變更
        <img src="./images/git-stage-change.png" height="30">
    1. 送出第一筆 commit
        <img src="./images/git-commit.png" height="30">
1. 建立 dev-1 worktree，在 VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> 裡面
    1. 存放庫 > `...`
        <img src="./images/git-repo-three-dot.png" height="30">
    1. 工作樹 > 建立工作樹
    1. 先建立任意分支
        (同時不能有兩個 worktree 放相同 branch ，所以這個時候選 main 分支會跳錯誤)
    1. 工作樹路徑填 `<YOUR_ROOT_DIR>\my-project\my-project.worktrees\dev-1`
    1. VS Code 頂端功能列 > 檔案 > 將資料夾新增至工作區，選擇剛才建立的 `<YOUR_ROOT_DIR>\my-project\my-project.worktrees\dev-1`
        此時你會發現 VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> > 存放庫 當中出現 dev-1
    1. VS Code 左側功能列 > 齒輪圖標 <img src="./images/setting-icon.png" height="30"> > 設定
        1. 工作區 <img src="./images/settings-workspace.png" height="35">
        1. 右上的開啟設定(JSON) <img src="./images/settings-go-to-json.png" height="30">，可以像下面這樣修改名稱
        ```json
        {
            "folders": [
                {
                    "name": "main",
                    "path": "<YOUR_ROOT_DIR>/my-project/my-project"
                },
                {
                    "name": "dev-1",
                    "path": "<YOUR_ROOT_DIR>/my-project/my-project.worktrees/dev-1"
                }
            ],
            "settings": {}
        }
        ```
    1. 剛才建立的 branch 如果不要，可以依照這個步驟刪除
        1. 點擊 VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> > 存放庫 中的 dev-1 的那個 branch 
        1. 選擇簽出已中斷連結
        1. 選擇那個 branch
        1. 點擊 VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> > 存放庫 > main > `...` <img src="./images/git-repo-three-dot.png" height="30"> > 分支 > 刪除分支
        1. 選擇那個 branch
    1. VS Code 頂端功能列 > 檔案 > 另存工作區為，把目前工作區儲存，以後直接打開 `xxx.code-workspace` 檔案就可以開啟這個工作區
1. 從這邊開始可以用 GitLens 的 Commit Graph ，會方便很多
    - VS Code 左側功能列 > 原始檔控制 <img src="./images/git.png" height="30"> > 存放庫 > 右鍵點擊你的存放庫 > Show Commit Graph
        > Commit Graph 操作可以參考 [GitLens 指南](./gitlens-guild.md)
1. 參考上面的步驟再建立 test-1 worktree + test/rc1 分支
1. 在 `<YOUR_ROOT_DIR>\my-project\my-project` 取出 SVN 中的專案
1. 把 SVN 取出的部分 git commit 到 main 分支
1. 合併 main 分支到 test/rc1 分支
1. 把 `<YOUR_ROOT_DIR>\my-project\my-project.worktrees\test-1` 上到 SVN