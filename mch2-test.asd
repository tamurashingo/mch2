#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2-test-asd
  (:use :cl :asdf))
(in-package :mch2-test-asd)

(defsystem mch2-test
  :author "tamura shingo"
  :license ""
  :depends-on (:mch2
               :cl-test-more)
  :components ((:module "t"
                :components
                ((:file "mch2"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
