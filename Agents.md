Developer runs `cr js` for JavaScript build, and `node main.mjs` to run the crawl/analysis script.

## 开工前必须看

先读通用 Calcit Agent 指南：

```bash
cr docs agents --full
```

## 高频命令

优先用查询命令定位，再做最小修改：

```bash
cr query config
cr query ns <ns>
cr query defs <ns>
cr query def <ns/def>
cr query search '<keyword>' --filter '<ns/def>'
cr tree show <ns/def> --path '<path>'
```

高频修改命令（`--code` 须用 `quote` 前缀）：

```bash
# 替换节点 — leaf 值用 quote |value，表达式用 quote (expr ...)
cr tree replace <ns/def> --path '<path>' --code 'quote |new-value'
cr tree replace <ns/def> --path '<path>' --code 'quote (new-expr ...)'

# 按内容搜索替换 leaf
cr tree search-replace <ns/def> --pattern '<old>' --code 'quote |<new>'

# 从文件读取替换内容
cr tree replace <ns/def> --path '<path>' --file snippet.cirru  # 内容须以 quote 开头

# 添加/更新定义
cr edit def <ns/def> --code 'quote (defn my-fn () ...)'

# 添加 import
cr edit add-import <ns> --code 'quote (src.ns :refer $ sym)'
```

高频验证命令：

```bash
# 编译为 JavaScript 模块
cr js

# 运行生成的 node 脚本
node main.mjs
```

## 高频工作流

- 先定位再修改。先 `query def/search`，再 `tree show`，最后做 `tree replace` 或 `edit def`。
- 优先局部替换。不要整段重写 `calcit.cirru`，只改目标节点 or 小段结构。
- 复杂结构先自检。尤其是 `let`、嵌套列表、异步流程控制（`hint-fn`）。
- 每次改完都重新编译和运行。默认先跑 `cr js`，然后 `node main.mjs` 验证输出。

## 高频踩坑

- `let` 只保留最后一个表达式。多个表达式要包一层 `do`，或者通过 `let` 直接返回值。
- `keys` 返回 set，不是 list。拼接前先 `.to-list`。
- `let` 绑定语法：必须用成对列表，形如 `let ((x 1)) x`。
- 变量必须保持 leaf。不要把单个变量用多余的括号包裹（例如，作为最终返回值时，变量单拉一行即可，不用括号）。
- 使用 JS Async 交互：用 `hint-fn $ {} (:async true)` 包装 async 函数。
- 所有的 `cr edit` / `cr tree` 操作都不支持 stdin 了，使用 `--code` 来传递简短表达式。

## 修改约束

- 严禁直接手改 `calcit.cirru`，必须使用 `cr tree` 或 `cr edit`。
- 路径不要猜。先用 `cr query search` 拿路径，再用 `cr tree show` 确认。
- `--code` / `--file` 输入的 Cirru 代码必须用 `quote` 前缀包裹。
