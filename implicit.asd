;;;; implicit.asd
;;
;;;; Copyright (c) 2018 Jeremiah LaRocco <jeremiah_larocco@fastmail.com>


(asdf:defsystem #:implicit
  :description "Describe implicit here"
  :author "Jeremiah LaRocco <jeremiah_larocco@fastmail.com>"
  :license  "ISC"
  :version "0.0.1"
  :serial t
  :depends-on (#:alexandria #:simple-png #:work-queue #:j-utils)
  :components ((:file "package")
               (:file "implicit")))
