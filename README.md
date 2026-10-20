
Count repos by language on GitHub
----

### Usage

本项目是 Node 抓取脚本，不是前端应用，不配置 COS/CDN。

迁移后需要 Node 24、Calcit 0.30.1-alpha.5（与 `@calcit/procs` 精确配对）、Caps 和 Yarn 4.18.0。
JSON 解析使用 core `.parse-json`，网络和定时器使用正式 `js-ffi` 0.2.3，
不再依赖已归档的 `calcit-json`、旧 `calcit-fetch` 或未使用的 `calcit.std` / Axios。

本轮仅对齐 0.30.1 候选工具链和 lock，不改变抓取源码、API 参数、延迟或结果格式。
截至 2026-10-20，正式 0.30.1 的 release tag 已存在，但 CLI assets 为空、npm runtime
尚不可用，因此候选版本不称为正式版。不增加验证脚本、类型预算或 COS 工作流。

```bash
corepack enable
caps --strict --ci
yarn install --immutable
yarn build
yarn test
```

`yarn test` 只使用假响应和 `.calcit/` 中的临时数据，不访问 GitHub API、不读取现有数据或 `.env`。
它只覆盖两次抓取、异步续接和结果写入，不代表真实 GitHub 授权或限流已验证。

手动抓取前准备 `data/languages.yml`，然后执行 `node scripts/generate-languages.mjs`。
在环境或本地 `.env` 设置 `GITHUB_API_TOKEN` 后，执行 `node main.mjs`。
这会调用 GitHub API，并覆盖 `data/result.cirru`；不要将它当作普通构建检查运行。

保留原限制：只取语言列表前两个语言，chunk size 为 815，仅处理首个 chunk，
每次请求结果后仍等待 4500ms。修复原 `wait-ms` 仅返回回调而不调用的停滞问题，
改为 `delay!` 使用 Node 非阻塞定时器；现在第二个语言也会实际执行。
结果仍是语言 String 到计数 Number 的 Cirru EDN Map，`load-data!` 保留按计数降序输出。
请求失败仍记录并返回计数 0，缺失/null/false 计数仍默认 0；
JSON 语法错误或非 Number 计数会报错，不通过静默默认值掩盖无效响应。

Based on API: https://api.github.com/search/repositories?q=language:Cirru&per_page=1

Based on languages list: https://raw.githubusercontent.com/github/linguist/master/lib/linguist/languages.yml

Result https://gist.github.com/jiyinyiyong/39d906cec0c2ea62ce871b1d1eb95963#file-cirru-text-L305

### License

MIT
