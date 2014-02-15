;;;;;
;;;;;
;;;;;


(defmacro/g! trip [&rest body]
  `(progn ;; XXX: Uh, this is horseshit. (progn) is going away.
    ;;            this needs to be a recursive-replace for sub-do
    ;;            or something.
    (import collections asyncio)
    (let [[loop (.get-event-loop asyncio)]]
      (setattr loop "handlers" (.defaultdict collections list))
      ~@body
      (.run-forever loop))))

(defmacro -acid-time [time order]
  (cond [(= order 'seconds) (* time 1)]
        [(= order 'second)  (* time 1)]
        [(= order 'minutes) (* time 60)]
        [(= order 'minute)  (* time 60)]
        [(= order 'hours)   (* time 3600)]
        [(= order 'hour)    (* time 3600)]))

(defmacro run [func &rest args]
  "Run a function async-like"
  `(.call-soon loop ~func ~@args))

(defmacro run-in [time order func &rest args]
  "Run a function in a few time"
  `(.call-later loop (-acid-time ~time ~order) ~func ~@args))

(defmacro defns [sig &rest body]
  (with-gensyms [fnn]
    `(defn ~fnn ~sig
      (let [[self ~fnn]] ~@body))))

(defmacro rerun [&rest args]
  `(run self ~@args))

(defmacro rerun-in [time order &rest args]
  `(run-in ~time ~order self ~@args))

(defmacro do [&rest body]
  `(run (defns [] ~@body)))

(defmacro do-in [time order &rest body]
  `(run-in ~time ~order (defns [] ~@body)))

(defmacro do-every [time order &rest body]
  `(do ~@body (rerun-in ~time ~order)))
