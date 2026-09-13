
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :native)
      :reload-fn 'app.main/reload!
      :feature-policy $ {}
      :modules $ [] |calcit-json/ |calcit-fetch/ |calcit.std/
      :type-slots $ {}
  :files $ {}
    'app.config $ %{} 'FileEntry
      :defs $ {} $ 'dev?
        %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ option:unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        'chan-count-language! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chan-count-language! (lang cb)
            let
                github-token $ option:unwrap-or
                  get-env |GITHUB_API_TOKEN
                  , |
                url $ str |https://api.github.com/search/repositories?q=language: (.replace lang "| " |+) | |&per_page=1
              fetch url
                {} $ :headers $ {}
                  |Authorization $ str "|token " github-token
                  |User-Agent |calcit-repos-rank
                fn (res)
                  tag-match res
                    (:ok text)
                      let
                          parsed $ parse text
                        cb $ or (get parsed :total_count) 0
                    (:err msg)
                      do (println "|Failed request:" msg) (cb 0)
          :examples $ []
          :schema $ :: 'Dynamic
        'count! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn count! ()
            let
                all-langs $ take
                  parse $ read-file |./data/languages.json
                  , 2
                chunk-size 815
              let
                  chunks $ split-chunks all-langs chunk-size
                process-chunk! ({}) (first chunks)
                  fn (merged) (println |Saving...)
                    write-file |data/result.cirru $ format-cirru-edn merged
                    println |Done!
          :examples $ []
          :schema $ :: 'Dynamic
        'load-data! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-data! ()
            let
                raw-data $ parse-cirru-edn $ read-file |data/result.cirru
                entries $ to-pairs raw-data
                sorted $ -> entries (.to-list)
                  .sort-by $ fn (entry)
                    - 0 $ last entry
                data $ join-str
                  map-indexed sorted $ fn (idx entry)
                    let[] (lang size) entry $ str idx "|\t" size "|\t" lang
                  , "|\n"
              println |size data
          :examples $ []
          :schema $ :: 'Dynamic
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (println |Started.) (count!)
          :examples $ []
          :schema $ :: 'Dynamic
        'process-chunk! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn process-chunk! (acc items cb)
            if (empty? items) (cb acc)
              let
                  lang $ first items
                chan-count-language! lang $ fn (repos-count)
                  println |Got (format-cirru-edn lang) repos-count
                  wait-ms 4500 $ fn () $ process-chunk! (assoc acc lang repos-count) (rest items) cb
          :examples $ []
          :schema $ :: 'Dynamic
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (println |Reloaded.) (count!)
          :examples $ []
          :schema $ :: 'Dynamic
        'split-chunks $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn split-chunks (xs size)
            if (empty? xs) ([])
              if
                <= (count xs) size
                [] xs
                let
                    chunk $ take xs size
                    remains $ drop xs size
                  concat ([] chunk) (split-chunks remains size)
          :examples $ []
          :schema $ :: 'Dynamic
        'wait-ms $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn wait-ms (ms cb)
            async-sleep $ / ms 1000
            cb
          :examples $ []
          :schema $ :: 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            json.core :refer $ parse
            fetch.core :refer $ fetch
            app.config :refer $ dev?
            calcit.std :as std
