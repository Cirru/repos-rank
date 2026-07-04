
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `cr query` to inspect and `cr edit`/`cr tree` to modify. Run `cr docs agents --full` first. Manual edits must follow format and schema conventions, then run `cr edit format`.") (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |calcit-json/ |calcit-fetch/ |calcit.std/
  :entries $ {}
  :files $ {}
    |app.config $ %{} :FileEntry
      :defs $ {}
        |dev? $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            def dev? $ = |dev (get-env |mode |release)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote (ns app.config)
    |app.main $ %{} :FileEntry
      :defs $ {}
        |chan-count-language! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn chan-count-language! (lang cb)
              let
                  github-token $ or (get-env |GITHUB_API_TOKEN) |
                  url $ str |https://api.github.com/search/repositories?q=language: (.replace lang "| " |+) | |&per_page=1
                fetch url
                  {} $ :headers
                    {}
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
        |count! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn count! () $ let
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
        |load-data! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn load-data! () $ let
                raw-data $ parse-cirru-edn (read-file |data/result.cirru)
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
        |main! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn main! () (println |Started.) (count!)
          :examples $ []
        |process-chunk! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn process-chunk! (acc items cb)
              if (empty? items) (cb acc)
                let
                    lang $ first items
                  chan-count-language! lang $ fn (repos-count)
                    println |Got (format-cirru-edn lang) repos-count
                    wait-ms 4500 $ fn ()
                      process-chunk! (assoc acc lang repos-count) (rest items) cb
          :examples $ []
        |reload! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn reload! () (println |Reloaded.) (count!)
          :examples $ []
        |split-chunks $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn split-chunks (xs size)
              if (empty? xs) ([])
                if
                  <= (count xs) size
                  [] xs
                  let
                      chunk $ take xs size
                      remains $ drop xs size
                    concat ([] chunk) (split-chunks remains size)
          :examples $ []
        |wait-ms $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn wait-ms (ms cb)
              async-sleep $ / ms 1000
              cb
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.main $ :require
            json.core :refer $ parse
            fetch.core :refer $ fetch
            app.config :refer $ dev?
            calcit.std :as std
