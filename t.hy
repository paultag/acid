(require acid.language)
(import requests)


(defn get-endpoint-url [line]
  (.format "http://developer.mbta.com/lib/rthr/{0}.json"
    (get {:red-line  "red"
          :blue-line "blue"} line)))

(trip
  (on :update-feed (print (.json (.get requests (get-endpoint-url event)))))
  (every 1 minute (emit :update-feed :red-line)))
