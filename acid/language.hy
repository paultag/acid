;;;;;
;;;;;
;;;;;


(defmacro/g! trip [&rest body]
  `(do
    (import collections asyncio)
    (let [[loop (.get-event-loop asyncio)]]
      (setattr loop "handlers" (.defaultdict collections list))
      ~@body
      (emit :startup loop)
      (.run-forever loop))))

(defmacro stream [client remote port]
  `(.run-until-complete loop
    (.create-connection loop ~client ~remote ~port)))

(defmacro every [time order &rest body]
  (with-gensyms [fnn]
    (let [[s-time
           (cond [(= order 'seconds) `(* ~time 1)]
                 [(= order 'second)  `(* ~time 1)]
                 [(= order 'minutes) `(* ~time 60)]
                 [(= order 'minute)  `(* ~time 60)]
                 [(= order 'hours)   `(* ~time 3600)]
                 [(= order 'hour)    `(* ~time 3600)]
                 [true (macro-error order "Unknown magnitude")])]]
      `(do
        (defn ~fnn []
          (let [[self ~fnn]]
            ~@body
            (echo ~s-time)))
        (.call-soon loop ~fnn)))))


(defmacro echo [time &rest args]
  `(.call-later loop ~time self ~@args))


(defmacro on [event &rest body]
  `(.append (get loop.handlers ~event)
    (fn [event] ~@body)))


(defmacro run [&rest body]
  `(.call-later loop (fn [] ~@body)))


(defmacro/g! emit [event e]
  `(for [~g!handler (get loop.handlers ~event)]
    (apply loop.call-soon [~g!handler ~e])))
