#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.server.app
  (:use :cl))

(in-package :mch2.server.app)

(cl-syntax:use-syntax :annot)

@export
(defclass <app> (ningle:<app>)
  ((error-log :type (or null pathname)
              :initarg :error-log
              :initform nil
              :accessor error-log)))

