(require acid.language)
(import requests)


(defn get-endpoint-url [line]
  (.format "http://developer.mbta.com/lib/rthr/{0}.json"
    (get {:red-line  "red"
          :blue-line "blue"} line)))


(trip
  ;; OK. Let's do some work with MBTA feeds.

  (on :update-feed
      ;; let's just update feeds on a cron.
      (print (.json (.get requests (get-endpoint-url event))))
      (emit :feed-updated event))

  (every 1 minute
         (emit :update-feed :red-line)))
