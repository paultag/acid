;;;;;
;;;;;
;;;;;


(defmacro/g! trip [&rest body]
  `(do
    (import collections asyncio)
    (let [[loop (.get-event-loop asyncio)]
          [handlers (.defaultdict collections list)]]
      ~@body
      (.run-forever loop))))


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
  `(.append (get handlers ~event)
    (fn [event] ~@body)))


(defmacro/g! emit [event e]
  `(for [~g!handler (get handlers ~event)]
    (apply loop.call-soon [~g!handler ~e])))
