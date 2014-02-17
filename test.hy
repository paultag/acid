(require acid.language)

(import [snitch.informants [pingable httpable]] random)


(let [[*min-ping-length* (-acid-time 1 minute)]
      [*max-ping-length* (-acid-time 10 minutes)]
      [*sites* {"pault.ag" [pingable httpable]
                "whube.com" [pingable httpable]
                "lucifer.pault.ag" [pingable httpable]}]]
  (trip

    (on :startup
      (for [(, site checks) (.items *sites*)]
        (for [check checks]
          (emit :start-checking {:site site :check check}))))

    (on :start-checking
      (.call-later loop (.randint random 0 30)
        (defns [wait]
          (let [[(, is-up info) ((:check event) (:site event))]
                [time (if is-up (* wait 2) (/ wait 2))]
                [retry-time (cond [(< time *min-ping-length*) *min-ping-length*]
                                  [(> time *max-ping-length*) *max-ping-length*]
                                  [true time])]]

            (emit :update {:site (:site event)
                           :check (:check event)
                           :is-up is-up
                           :retry-delay retry-time
                           :info info})

            (.call-later loop retry-time self retry-time))) 0))

    (on :update  ;; store the event in memory
      )

    (on :update  ;; This is debug information
      (print (:site event) (:is-up event) (:info event)
        "next check is in" (:retry-delay event) "seconds"))

    (emit :startup nil)))
