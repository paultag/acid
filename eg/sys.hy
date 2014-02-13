(require acid.language)
(import telnetlib json)


(defn read-uwsgi-status [remote port]
  (.loads json (.decode
      (.read-all (.Telnet telnetlib remote port)) "utf-8")))

(def *servers* {"doorbell" ["localhost" 3030]})
(def *status* {})


(trip

  (on :poll-uwsgis
    (for [server *servers*]
      (emit :poll-uwsgi server)))

  (on :poll-uwsgi
    (assoc *status* event (apply read-uwsgi-status (get *servers* event)))
    (emit :uwsgi-updated {"node" event
                          "data" (get *status* event)}))

  (on :uwsgi-updated
    (print (get event "data")))

  (on :startup (every 2 seconds (emit :poll-uwsgis nil)))
  (emit :startup nil))
