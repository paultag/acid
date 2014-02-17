(require acid.language)
(import [snitch.informants [pingable httpable]]
        random
        [datetime :as dt])


(trip
  (let [[*min-ping-length* (acid-time 1 minute)]
        [*max-ping-length* (acid-time 10 minutes)]
        [*sites* {"pault.ag" [pingable httpable]
                  "whube.com" [pingable httpable]
                  "lucifer.pault.ag" [pingable httpable]}]]

    (on :startup  ;; start site checking
      (for [(, site checks) (.items *sites*)]
        (for [check checks]
          (emit :start-checking {:site site :check check}))))

    (on :start-checking
      (schedule-in-seconds (.randint random 0 60)
        (defns [wait]
          (let [[start (.utcnow dt.datetime)]
                [(, is-up info) ((:check event) (:site event))]
                [end (.utcnow dt.datetime)]
                [response-time (- end start)]
                [time (if is-up (* wait 2) (/ wait 2))]
                [retry-time (cond [(< time *min-ping-length*) *min-ping-length*]
                                  [(> time *max-ping-length*) *max-ping-length*]
                                  [true time])]]

            (emit :update {:site (:site event)
                           :check (:check event)
                           :runtime (- end start)
                           :is-up is-up
                           :retry-delay retry-time
                           :info info})

            (reschedule-in-seconds retry-time retry-time))) 0))

    (on :update  ;; store the event in memory
      )

    (on :update  ;; This is debug information
      (print (:site event) (:is-up event) (:info event)
        "(done in" (:runtime event) "seconds)"
        "next check is in" (:retry-delay event) "seconds"))

    (emit :startup nil)))
