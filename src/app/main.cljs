
(ns app.main
  (:require ["axios" :as axios]
            ["fs" :as fs]
            [cljs.core.async :refer [go go-loop <! >! chan timeout]]
            [cljs.reader :refer [read-string]]
            [clojure.string :as string])
  (:require-macros [clojure.core.strint :refer [<<]]))

(defn chan-count-language! [lang]
  (let [ret (chan)
        github-token js/process.env.GITHUB_TOKEN
        the-lang (js/encodeURIComponent lang)]
    (-> (axios/get
         (<< "https://api.github.com/search/repositories?q=language:~{the-lang}&per_page=1")
         (clj->js {:headers {:Authorization (str "token " github-token)}}))
        (.then (fn [x] (go (>! ret (.-total_count (.-data x))))))
        (.catch (fn [err] (js/console.log "Failed" err))))
    ret))

(defn count! []
  (let [langs (js->clj
               (js/Object.keys
                (js/JSON.parse (fs/readFileSync "./data/languages.json" "utf8"))))]
    (comment println langs)
    (go-loop
     [acc {} xs (drop 380 langs)]
     (if (empty? xs)
       (do (println (pr-str acc)) (fs/writeFileSync "result.edn" (pr-str acc)))
       (let [lang (first xs), repos-count (<! (chan-count-language! lang))]
         (fs/writeFileSync "result.edn" (pr-str acc))
         (println "Got" (pr-str lang) repos-count (count acc) "remaining:" (count xs))
         (<! (timeout 1111))
         (recur (assoc acc lang repos-count) (rest xs)))))))

(defn load-data! []
  (let [files ["result-1-88.edn"
               "result-130-150.edn"
               "result-150-200.edn"
               "result-200-225.edn"
               "result-225-275.edn"
               "result-275-300.edn"
               "result-300-325.edn"
               "result-325-350.edn"
               "result-350-380.edn"
               "result-88-130.edn"
               "result.edn"]
        data (->> files
                  (map (fn [file] (read-string (fs/readFileSync file "utf8"))))
                  (apply merge)
                  (sort-by (fn [pair] (- 0 (last pair))))
                  (map-indexed (fn [idx [lang size]] (str idx "-----" lang "-----" size)))
                  (string/join "\n"))]
    (println "size" data)))

(defn main! [] (println "Started.") (comment count!) (load-data!))

(defn reload! [] (.clear js/console) (println "Reloaded.") (comment count!))
