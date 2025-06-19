#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#


(in-package :cl-user)
(defpackage mch2-asd
  (:use :cl :asdf))
(in-package :mch2-asd)

(defsystem mch2
  :version "0.1"
  :author "tamura shingo"
  :depends-on (:cl-annot

               ;; server
               :clack
               :ningle
               :cl-emb
               :cl-json
               :local-time)

  :components ((:file "mch2"
                :pathname "src/mch2")
               (:module "server"
                :pathname "src/server"
                :depends-on ("mch2" "lib" "util")
                :components
                ((:file "server" :depends-on ("app"))
                 (:file "app")))
               (:module "lib"
                :pathname "src/lib"
                :depends-on ("mch2" "util")
                :components
                ((:file "mail")
                 (:file "basic" :depends-on ("mail"))))
               (:module "util"
                :pathname "src/util"
                :components
                ((:file "util")
                 (:file "zip" :depends-on ("util")))))

  :description ""
  :long-description
  #.(with-open-file (stream (merge-pathnames
                             #p"README.markdown"
                             (or *load-pathname* *compile-file-pathname*))
                            :if-does-not-exist nil
                            :direction :input)
      (when stream
        (let ((seq (make-array (file-length stream)
                               :element-type 'character
                               :fill-pointer t)))
          (setf (fill-pointer seq) (read-sequence seq stream))
          seq)))
  :in-order-to ((test-op (load-op mch2-test))))
