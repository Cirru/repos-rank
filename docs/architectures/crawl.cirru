{}
  :schema-version 1
  :feature 'crawl
  :roots $ #{} 'app.main/main!
  :doc "|Node crawl: read language list, fetch counts sequentially, schedule continuation, write EDN."
  :definitions $ {}
    'app.main/main! $ {} (:mode :external) (:kind :fn)
      :schema $ :: :fn $ {} (:args $ []) (:return 'Unit)
        :features $ #{} :js-ffi
    'app.main/count! $ {} (:mode :external) (:kind :fn)
      :schema $ :: :fn $ {} (:args $ []) (:return 'Unit)
        :features $ #{} :js-ffi
  :edges $ #{}
    :: :call 'app.main/main! 'app.main/count!
  :invariants $ []
    , "|Node-only; no frontend deployment or COS changes."
    , "|Keep first two languages, chunk size 815, first chunk only and 4500ms delay."
    , "|Keep data/languages.json input and data/result.cirru output; no live crawl during migration."
