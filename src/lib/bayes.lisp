#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.lib.bayes
  (:use :cl)
  (:import-from :mch2-bayes
                :init))

(in-package :mch2.lib.bayes)

(cl-syntax:use-syntax :annot)


