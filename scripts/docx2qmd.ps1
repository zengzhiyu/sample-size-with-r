# docx2qmd.ps1 -- 批量转换 Word (.docx) 到 Quarto (.qmd)
# 用法：把所有 .docx 放在项目根目录，运行此脚本
# 依赖：pandoc（https://pandoc.org/）

param(
    [string]$SourceDir = ".",
    [string]$OutputDir = "."
)

$docxFiles = Get-ChildItem -Path $SourceDir -Filter "*.docx"

if ($docxFiles.Count -eq 0) {
    Write-Error "No .docx files found in $SourceDir"
    exit 1
}

Write-Host "Found $($docxFiles.Count) .docx files" -ForegroundColor Cyan

foreach ($file in $docxFiles) {
    $qmdName = [System.IO.Path]::ChangeExtension($file.Name, ".qmd")
    $qmdPath = Join-Path $OutputDir $qmdName

    Write-Host "  Converting: $($file.Name) -> $qmdName" -ForegroundColor Gray

    pandoc $file.FullName `
        -f docx `
        -t markdown `
        --wrap=none `
        --extract-media=media `
        --markdown-headings=atx `
        -o $qmdPath

    # 移除 pandoc 生成的 BOM（Quarto 偏好 UTF-8 without BOM）
    $content = Get-Content $qmdPath -Raw -Encoding UTF8
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($qmdPath, $content, $utf8NoBom)
}

Write-Host "`nConversion complete." -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Check each .qmd for title formatting (merge split titles)"
Write-Host "  2. Verify code blocks have correct language tags"
Write-Host "  3. Check image paths point to media/ directory"
Write-Host "  4. Add chapters to _quarto.yml"
Write-Host "  5. Run: quarto render"
