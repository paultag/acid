(require acid.language)
(import requests)


(let [[endpoints {:red-line "http://developer.mbta.com/lib/rthr/red.json"}]]
  (trip

    (on :update-feed
      (let [[endpoint (get endpoints event)]]
        (print (.json (.get requests endpoint)))))

    (every 1 minute (emit :update-feed :red-line))))
