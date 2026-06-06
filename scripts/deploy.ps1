# deploy.ps1 -- 安全部署 Quarto Book 到 GitHub Pages
# 必须在项目根目录（有 _quarto.yml 的地方）运行
# 前提：已执行 quarto render，_book/ 目录存在

$ErrorActionPreference = "Stop"

# 检查状态
if (-not (Test-Path "_book")) {
    Write-Error "_book/ not found. Run 'quarto render' first."
    exit 1
}

$branch = git branch --show-current
if ($branch -ne "main") {
    Write-Error "Must be on 'main' branch. Current: $branch"
    exit 1
}

# 1. 复制渲染结果到临时目录
$tmpDir = Join-Path $env:TEMP "quarto_deploy_$(Get-Random)"
Write-Host "[1/6] Copying _book to temp..." -ForegroundColor Cyan
Copy-Item -Recurse _book $tmpDir

# 2. 保存 main 上的未提交变更
Write-Host "[2/6] Stashing working changes..." -ForegroundColor Cyan
git stash

# 3. 切换到 gh-pages
Write-Host "[3/6] Switching to gh-pages..." -ForegroundColor Cyan
git fetch origin gh-pages 2>$null
git checkout gh-pages

# 4. 清空并复制（保留 .git）
Write-Host "[4/6] Updating gh-pages files..." -ForegroundColor Cyan
Get-ChildItem -Exclude .git | Remove-Item -Recurse -Force
Copy-Item -Recurse "$tmpDir\*" . -Force

# 5. 提交推送
Write-Host "[5/6] Committing and pushing..." -ForegroundColor Cyan
git add -A
git commit -m "Deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin gh-pages

# 6. 回到 main
Write-Host "[6/6] Back to main..." -ForegroundColor Cyan
git checkout main
git stash pop

# 清理
Remove-Item -Recurse -Force $tmpDir

Write-Host "Done! Site will update in ~2 min." -ForegroundColor Green
Write-Host "https://zengzhiyu.github.io/sample-size-with-r/" -ForegroundColor Green
