
{} (:about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `cr query` to inspect and `cr edit`/`cr tree` to modify. Run `cr docs agents --full` first. Manual edits must follow format and schema conventions, then run `cr edit format`.") (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ []
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
            defn chan-count-language! (lang)
              let
                  github-token js/process.env.GITHUB_API_TOKEN
                  the-lang $ js/encodeURIComponent lang
                ->
                  .!get axios (str |https://api.github.com/search/repositories?q=language: the-lang |&per_page=1)
                    js-object $ :headers
                      js-object $ :Authorization (str "|token " github-token)
                  .!then $ fn (x) (-> x .-data .-total_count)
                  .!catch $ fn (err) (js/console.log |Failed err) 0
          :examples $ []
        |count! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn count! () $ let
                all-langs $ take
                  to-calcit-data $ js/JSON.parse (fs/readFileSync |./data/languages.json |utf8)
                  , 5
                chunk-size 2
                task $ fn (dummy)
                  hint-fn $ {} (:async true)
                  let
                      chunks $ split-chunks all-langs chunk-size
                      js-promises $ js-array
                    each chunks $ fn (chunk)
                      .!push js-promises $ process-chunk! chunk
                    let
                        results $ js-await (js/Promise.all js-promises)
                        merged $ reduce (to-calcit-data results) ({}) merge
                      println |Saving...
                      fs/writeFileSync |data/result.cirru $ format-cirru-edn merged
                      println |Done!
              task nil
          :examples $ []
        |load-data! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn load-data! () $ let
                raw-data $ parse-cirru-edn (fs/readFileSync |data/result.cirru |utf8)
                entries $ to-calcit-data (js/Object.entries raw-data)
                sorted $ -> entries (.to-list)
                  .sort-by $ fn (entry)
                    - 0 $ last entry
                data $ -> sorted
                  map-indexed $ fn (idx entry)
                    let[] (lang size) entry $ str idx "|\t" size "|\t" lang
                  .join-s "|\n"
              println |size data
          :examples $ []
        |main! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn main! () (println |Started.) (count!)
          :examples $ []
        |process-chunk! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn process-chunk! (xs)
              let
                  run-loop $ fn (acc items)
                    hint-fn $ {} (:async true)
                    if (empty? items) acc $ let
                        lang $ first items
                        repos-count $ js-await (chan-count-language! lang)
                      println |Got (format-cirru-edn lang) repos-count
                      js-await $ wait-ms 4000
                      js-await $ run-loop (assoc acc lang repos-count) (rest items)
                run-loop ({}) xs
          :examples $ []
        |reload! $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn reload! () (println |Reloaded.) (count!)
          :examples $ []
        |split-chunks $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn split-chunks (xs size)
              if (empty? xs) ([])
                let
                    chunk $ take xs size
                    remains $ drop xs size
                  concat ([] chunk) (split-chunks remains size)
          :examples $ []
        |wait-ms $ %{} :CodeEntry (:doc |) (:schema :dynamic)
          :code $ quote
            defn wait-ms (ms)
              new js/Promise $ fn (resolve _reject) (js/setTimeout resolve ms)
          :examples $ []
      :ns $ %{} :NsEntry (:doc |)
        :code $ quote
          ns app.main $ :require (|axios :default axios) (|node:fs :as fs)
