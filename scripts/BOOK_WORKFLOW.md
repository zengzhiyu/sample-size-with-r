# Quarto 书籍工作流：从 Word 到线上发布

## 项目结构

```
QuartoBook/
├── _quarto.yml          # 书籍配置（书名、作者、章节列表、主题）
├── index.qmd            # 首页（关于本书）
├── S0_preface.qmd       # 前言
├── S1-S15/*.qmd         # 各章节源码
├── S16 Appendix.qmd     # 附录
├── styles.css           # 自定义样式
├── scripts/             # 自动化脚本
│   ├── build.ps1        # 本地构建
│   ├── deploy.ps1       # 本地部署到 gh-pages
│   └── docx2qmd.ps1     # Word 批量转 QMD
├── .github/workflows/
│   └── publish.yml      # GitHub Actions 自动部署
├── _book/               # 渲染输出（gitignore）
└── media/               # 图片资源
```

---

## 流程一：Word → QMD 转换（再版时用）

### 前提
- 安装 [pandoc](https://pandoc.org/) 和 [Quarto](https://quarto.org/)
- 所有 .docx 文件放在项目根目录

### 执行

```powershell
.\scripts\docx2qmd.ps1
```

### 转换后手动检查清单

| 检查项 | 说明 |
|--------|------|
| 标题格式 | pandoc 可能生成双行标题（`# 标题\n## 副标题`），需手动合并 |
| 代码块 | R 代码块是否正确标注 `{r}` |
| 图片路径 | 确认 `![]()` 路径指向 `media/` 目录 |
| BOM 编码 | 确保 .qmd 文件为 UTF-8 without BOM |
| 数学公式 | `$...$` 行内和 `$$...$$` 块级公式是否正确 |

### ⚠️ 踩过的坑

1. **双行标题**：Word 中的标题如果自带换行或编号，pandoc 会拆成 `#` + `##`，需手动合并为一行
2. **EMF 图片**：Word 中的 .emf 矢量图 pandoc 导出后浏览器不支持，需转为 .png
3. **中文编码**：- 必须在 `_quarto.yml` 中设 `lang: zh`

---

## 流程二：配置书籍

### `_quarto.yml` 关键字段

```yaml
project:
  type: book

book:
  title: "书名"           # ⚠️ 这是唯一书名来源，会覆盖各章 YAML 的 title
  author: "作者"
  date: "2025"            # ⚠️ 必须是纯日期格式，不能放版本号
  chapters: [...]         # 章节顺序
  appendices: [...]       # 附录

format:
  html:
    theme:
      light: flatly
      dark: darkly
    toc: true
    toc-depth: 3
    number-sections: false
    code-fold: true
    code-tools: true
    css: styles.css

lang: zh
```

### ⚠️ 踩过的坑

1. **书名修改必须改两处**：`_quarto.yml` 的 `book.title` + `index.qmd` 的 YAML `title`
2. **版本号不能放 `date` 字段**：Quarto 会把 `date` 当日期解析，"2025 · ver 0.1" 会被截成 "2025"
3. **版本号正确做法**：用 `include-before-body` 加 `<div class="book-version">ver 0.1</div>`
4. **不要用 hero-banner 放标题**：Quarto 自动生成 `<h1 class="title">`，再加 banner 会导致双标题

---

## 流程三：本地构建

```powershell
# 全量渲染（改 _quarto.yml 或 styles.css 后必须）
quarto render

# 单章渲染（只改某一章内容时）
quarto render "S1 1Mean.qmd"

# 仅渲染首页（改 index.qmd 时）
quarto render index.qmd
```

---

## 流程四：部署上线

### 自动化（推荐）

推送 main 分支即可，GitHub Actions 自动渲染部署。

### 手动部署（备用）

```powershell
.\scripts\deploy.ps1
```

### ⚠️ 踩过的坑（重要！）

1. **绝对不要在主分支手动混合 gh-pages 操作**：曾因部署脚本把 HTML 文件误提交到 main，覆盖了源码
2. **正确的部署顺序**：
   - 在 main 分支渲染 `quarto render`
   - 复制 `_book` 到临时目录
   - `git stash` 保存未提交变更
   - 切换到 gh-pages 分支
   - 清空工作目录（保留 `.git`）
   - 从临时目录复制渲染结果
   - 提交并推送 gh-pages
   - 切回 main，`git stash pop`
3. **VPN 稳定性**：git clone 大仓库时 VPN 断开会导致重复失败，建议用 `--depth 10` 浅克隆
4. **GitHub Pages CDN 缓存**：部署后可能有几分钟延迟，加随机 query 参数验证：`?v=随机数`
5. **国内访问慢**：GitHub Pages 服务器在美国，国内用户可考虑 Gitee Pages 镜像

---

## 流程五：更新内容（日常使用）

```bash
# 1. 改完内容
git add -A
git commit -m "描述改动"

# 2. 推送（触发自动部署）
git push

# 3. 等待 2-3 分钟，刷新网页即可
```

无需本地渲染。但如果想看本地效果：

```powershell
quarto render index.qmd    # 只渲染首页，秒级完成
quarto preview index.qmd   # 启动本地预览服务器
```

---

## 常用命令速查

| 操作 | 命令 |
|------|------|
| 预览单章 | `quarto preview "S1 1Mean.qmd"` |
| 全量渲染 | `quarto render` |
| 添加新章节 | 1. 创建 .qmd → 2. 加入 `_quarto.yml` chapters 列表 |
| 修改书名 | 改 `_quarto.yml` book.title + `index.qmd` YAML title |
| 修改版本号 | 改 `index.qmd` 中的 `<div class="book-version">` |
| 修改样式 | 改 `styles.css` → `quarto render` 全量 |
| 查看构建状态 | https://github.com/zengzhiyu/sample-size-with-r/actions |
| 线上地址 | https://zengzhiyu.github.io/sample-size-with-r/ |
