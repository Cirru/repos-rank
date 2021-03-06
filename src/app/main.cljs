
(ns app.main
  (:require ["axios" :as axios]
            ["fs" :as fs]
            [cljs.core.async :refer [go go-loop <! >! chan timeout]]
            [cljs.core.async.interop :refer [<p!]]
            [cljs.reader :refer [read-string]]
            [clojure.string :as string])
  (:require-macros [clojure.core.strint :refer [<<]]))

(defn chan-count-language! [lang]
  (let [github-token js/process.env.GITHUB_TOKEN, the-lang (js/encodeURIComponent lang)]
    (go
     (try
      (<p!
       (-> (axios/get
            (<<
             "https://api.github.com/search/repositories?q=language:~{the-lang}&per_page=1")
            (clj->js {:headers {:Authorization (str "token " github-token)}}))
           (.then (fn [^js x] (.-total_count (.-data x))))))
      (catch js/Error err (js/console.log "Failed" err))))))

(defn count! []
  (let [langs (js->clj
               (js/Object.keys
                (js/JSON.parse (fs/readFileSync "./data/languages.json" "utf8"))))]
    (comment println langs)
    (go
     (loop [acc {}, xs (drop 0 langs)]
       (if (empty? xs)
         (do (println (pr-str acc)) (fs/writeFileSync "result.edn" (pr-str acc)))
         (let [lang (first xs), repos-count (<! (chan-count-language! lang))]
           (fs/writeFileSync "result.edn" (pr-str acc))
           (println "Got" (pr-str lang) repos-count (count acc) "remaining:" (count xs))
           (<! (timeout 2111))
           (recur (assoc acc lang repos-count) (rest xs))))))))

(defn load-data! []
  (let [files ["result.edn"]
        data (->> files
                  (map (fn [file] (read-string (fs/readFileSync file "utf8"))))
                  (apply merge)
                  (sort-by (fn [pair] (- 0 (last pair))))
                  (map-indexed (fn [idx [lang size]] (str idx "\t" size "\t" lang)))
                  (string/join "\n"))]
    (println "size" data)))

(defn main! [] (println "Started.") (comment count!) (load-data!))

(defn ^:dev/after-load
  reload!
  []
  (.clear js/console)
  (println "Reloaded.")
  (comment count!))
