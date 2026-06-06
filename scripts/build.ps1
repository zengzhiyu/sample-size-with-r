# build.ps1 -- 本地构建 Quarto Book
# 参数：可选 .qmd 文件名（只渲染该章），不传则全量渲染

param([string]$Chapter)

if ($Chapter) {
    Write-Host "Rendering: $Chapter" -ForegroundColor Cyan
    quarto render $Chapter
} else {
    Write-Host "Rendering full book..." -ForegroundColor Cyan
    quarto render
}

if (Test-Path "_book\index.html") {
    Write-Host "Build OK. Preview: quarto preview" -ForegroundColor Green
} else {
    Write-Host "Build may have warnings, check output above." -ForegroundColor Yellow
}
