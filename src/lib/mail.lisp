#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.lib.mail
  (:nicknames :mch2-mail)
  (:use :cl)
  (:import-from :mch2
                :set-logic))
(in-package :mch2.lib.mail)

(cl-syntax:use-syntax :annot)

@export
(defclass <mail> ()
  ((send-to :accessor send-to
            :initform nil)
   (send-cc :accessor send-cc
            :initform nil)
   (send-bcc :accessor send-bcc
             :initform nil)
   (subject :accessor subject
            :initform nil)
   (content :accessor content
            :initform nil)
   (attach :accessor attach
           :initform nil)))

@export
(defclass <attach> ()
  ((filename :accessor filename
             :initform nil)
   (content :accessor content
            :initform nil)))

@export
(defun send-p (dest send-list)
  "check if number of send-to address items is one and address is correct."
  (and (= 1 (length send-list))
       (string= dest (car send-list))))

@export
(defun send-contains-p (dest send-list)
  "check if one of send-to address is correct."
  (loop for address in send-list
        when (string= dest address)
          return t
        finally
          (return nil)))

@export
(defmacro def-logic (logic-name args &rest body)
  `(set-logic ,(format nil "~A" logic-name)
              #'(lambda ,args
                  (progn ,@body))))

@export
(defun ok (message)
  (values t message))

@export
(defun ng (message)
  (values nil message))

