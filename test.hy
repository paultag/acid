(require acid.language)


(trip
  (on :startup (run-in 5 seconds (emit :do-things nil)))
  (on :startup (print "Starting up"))

  (on :do-things (print "Doing things!"))
  (on :do-things (print (* 2 2)))

  (emit :startup nil))
