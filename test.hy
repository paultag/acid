(require acid.language)


(trip
  (run (defns [x]
         (print (% "Hello, %s" (str x)))
         (rerun (+ x 1)))
       0))
