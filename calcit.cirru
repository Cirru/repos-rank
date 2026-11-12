
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :node)
      :feature-policy $ {}
      :modules $ [] |js-ffi/
      :type-slots $ {}
  :files $ {}
    'app.config $ %{} 'FileEntry
      :defs $ {} $ 'dev?
        %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $
              get-env |mode
              , .unwrap-or |release
          :examples $ []
          :schema $ quote Bool
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        'chan-count-language! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn chan-count-language! (lang cb)
            hint-fn $ Fn String
              Fn Number (-> Unit) (:features :js-ffi)
              -> Unit
              :features :js-ffi
              :async
            let
                github-token $
                  get-env |GITHUB_API_TOKEN
                  , .unwrap-or |
                url $ str |https://api.github.com/search/repositories?q=language: (.replace lang "| " |+) | |&per_page=1
                headers $ headers-create
              headers-set! headers |Authorization $ str "|token " github-token
              headers-set! headers |User-Agent |calcit-repos-rank
              match
                js-await $ fetch-request url (HttpMethod :get) headers
                (:ok response)
                  match
                    js-await $ response-text response
                    (:ok text)
                      cb $ read-search-count text
                    (:err error)
                      do
                        println "|Failed request:" $ :message error
                        cb 0
                (:err error)
                  do
                    println "|Failed request:" $ :message error
                    cb 0
          :examples $ []
          :schema $ quote $ Fn String
            Fn Number (-> Unit) (:features :js-ffi)
            -> Unit
            :features :io :js-ffi
        'count! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn count! ()
            let
                all-langs $ take
                  decode-map-as
                    match
                        read-text! |./data/languages.json
                        , .parse-json
                      (:ok raw) raw
                      (:err error) (raise error)
                    List String
                  , 2
                chunk-size 815
                language-chunks $ split-chunks all-langs chunk-size
              process-chunk! ({})
                (first language-chunks) .unwrap
                fn (merged)
                  hint-fn $ Fn (Map String Number) (-> Unit) (:features :js-ffi)
                  println |Saving...
                  write-text! |data/result.cirru $ format-cirru-edn merged
                  println |Done!
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi)
        'delay! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn delay! (ms cb) (set-timeout! cb ms) &unit
          :examples $ []
          :schema $ quote $ Fn Number
            Fn (-> Unit) (:features :js-ffi)
            -> Unit
            :features :js-ffi
        'load-data! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn load-data! ()
            let
                raw-data $ match
                  try-parse-cirru-edn-as (read-text! |data/result.cirru) (Map String Number)
                  (:ok data) data
                  (:err error) (raise error)
                entries $ to-pairs raw-data
                sorted $ .sort-by (.to-list entries)
                  fn (entry)
                    hint-fn $ Fn (Tuple String Number) (-> Number)
                    let[] (_lang size) entry $ - 0 size
                lines $ map-indexed sorted $ fn (idx entry)
                  hint-fn $ Fn Number (Tuple String Number) (-> String)
                  let[] (lang size) entry $ str idx "|\t" size "|\t" lang
                data $ lines.join-string "|\n"
              println |size data
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (println |Started.) (count!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi)
        'process-chunk! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn process-chunk! (acc items cb)
            if (empty? items) (cb acc)
              let
                  lang $
                    first items
                    , .unwrap
                chan-count-language! lang $ fn (repos-count)
                  hint-fn $ Fn Number (-> Unit) (:features :js-ffi)
                  println |Got (format-cirru-edn lang) repos-count
                  delay! 4500 $ fn ()
                    hint-fn $ Fn (-> Unit) (:features :js-ffi)
                    process-chunk! (assoc acc lang repos-count) (rest items) cb
                , &unit
          :examples $ []
          :schema $ quote $ Fn (Map String Number) (List String)
            Fn (Map String Number) (-> Unit) (:features :js-ffi)
            -> Unit
            :features :io :js-ffi
        'read-search-count $ %{} 'CodeEntry
          :doc "|Validate the count field without decoding unused GitHub response fields."
          :code $ quote $ defn read-search-count (text)
            let
                response $ contract/expect-object |GitHub.search $ js/JSON.parse text
              when (js/Array.isArray response) (raise "|GitHub search response must be an object")
              match
                js-nullish->option $ contract/object-field |GitHub.search response |total_count
                (:none) 0
                (:some value)
                  if (bool? value)
                    if (contract/expect-bool |total_count value) (raise "|total_count must be a Number") 0
                    contract/expect-number |total_count value
          :examples $ []
          :schema $ quote $ Fn String (-> Number) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! () (println |Reloaded.) (count!)
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :io :js-ffi)
        'split-chunks $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn split-chunks (xs size)
            if (empty? xs) ([])
              if
                <= (.len xs) size
                [] xs
                let
                    chunk $ take xs size
                    remains $ drop xs size
                  concat ([] chunk) (split-chunks remains size)
          :examples $ []
          :schema $ quote $ Fn (List T) Number
            -> $ List $ List T
            :generics T
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require
            js-ffi.shared :refer $ fetch-request HttpMethod headers-create headers-set! response-text
            js-ffi.contract :as contract
            js-ffi.node :refer $ read-text! write-text! set-timeout!
