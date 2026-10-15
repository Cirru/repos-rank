# Development

This is a Node-only crawler, not a frontend app. Use Node 24 and the exact
Calcit / `@calcit/procs` version recorded in `deps.cirru` and `package.json`.

Before editing, read `calcit docs agents --full`, inspect `calcit query config`
and query the affected definitions. Never edit `calcit.cirru` as plain text:
use official query/tree/edit/config commands, with a reviewed transaction
dry-run and revision guard for related changes. Keep imports without extra `[]`.

Local checks:

```bash
yarn install --immutable
calcit --check-only --all-defs
calcit fix --workflow strict --verify
yarn build
yarn test
```

The test uses fake responses and temporary data under ignored `.calcit/`.
Do not run `node main.mjs` for routine verification: it reads credentials,
calls GitHub and overwrites `data/result.cirru`. Do not inspect `.env` or
existing result data during migration. Live crawls require an explicit task.

Preserve the first-two-languages limit, chunk size 815, first chunk only,
4500ms nonblocking delay and existing data paths unless asked to change them.
Do not add COS/CDN deployment, generated JS, unsafe casts, compatibility flags,
dependency age exceptions or broad Git dependency allowlists.
