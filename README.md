
Count repos by language on GitHub
----

### Usage

本项目是 Node 抓取脚本，不是前端应用，不配置 COS/CDN。

### 使用者影响

升级到 Calcit 和 `@calcit/procs` **0.37.0** 后，请用 Node 24、Caps 和 Yarn 4.18.0 重新安装依赖并构建。抓取范围、等待时间和结果文件格式继续适用。响应中的计数在 JSON 边界解码为 Number。网络及定时器使用正式 `js-ffi` **0.2.13**。

读取排名时，排序及输出直接使用 `Tuple<String, Number>`，保留按计数降序输出。原离线测试使用合成响应，另用合成结果文件验证了生成 JS 的排序和名称。

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
