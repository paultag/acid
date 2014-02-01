;;;;
;;;;

(require acid.language)
(import [sh [adb ErrorReturnCode-255]])

(defn start-server [] (adb "start-server"))


(def *phones* {})
(def *phone-info* {})
(def *phone-battery* {})


;; events:
;;   poll-phones
;;      poll for new phones.

(defn get-attached-devices []
  (genexpr
    (.split x)
    [x (filter
         (lambda [x] (and (!= x "List of devices attached ")
                          (!= (.strip x) "")))
         (.split (adb "devices" "-l") "\n"))]))


(defn update-phone-listing []
  (for [(, serial _ connection product model device) (get-attached-devices)]
    (assoc *phone-info* serial {"serial" serial
                                "connection" connection
                                "product" product
                                "model" model
                                "device" device}))
  *phone-info*)

(defn get-device-battery-info [serial]
  (genexpr
    (.split (.strip x) ": ")
    [x (filter
      (lambda [x] (and (!= x "Current Battery Service state:")
                       (!= x "")))
      (.split (adb "-s" serial "shell" "dumpsys" "battery") "\r\n"))]))


(defn update-phone-battery [serial]
  (assoc *phone-battery* serial (dict (get-device-battery-info serial)))
  (get *phone-info* serial))

(defn read-value [x]
  (.replace (get (.split x ":") 1) "_" " "))

(defn get-display-name [serial]
  (let [[info (get *phone-info* serial)]]
    (.format "{0} ({1})" (read-value (get info "model"))
                         (read-value (get info "device")))))

(defn get-charge-percent [serial]
  (let [[info (get *phone-battery* serial)]
        [scale (int (get info "scale"))]
        [level (int (get info "level"))]]
    (int (* 100 (/ level scale)))))


(trip
  (on :poll-phones
    (for [serial (update-phone-listing)]
      (emit :poll-phone serial)))

  (on :poll-phone
    (emit
      :phone-battery-updated
      {"battery" (update-phone-battery event) "serial" event}))

  (on :phone-battery-updated
    (print (get-display-name (get event "serial"))
           "is at"
           (get-charge-percent (get event "serial"))
           "percent battery"))

  ; system triggers
  (every .5 minute (emit :poll-phones nil))
  (on :startup (start-server))
  (emit :startup nil))
