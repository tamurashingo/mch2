#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2
  (:use :cl))
(in-package :mch2)

(cl-syntax:use-syntax :annot)

@export
(defvar *mch2-rules* nil
  "this is an assoc list contains rule-name(string) and list of logic-names(string).")

@export
(defvar *mch2-logics* nil
  "this is an assoc list contains logic-name(string) and its closure.")

@export
(defvar *mch2-users* nil
  "list of user address to check if the user has permission to use the mch2 service.")

@export
(defun set-rule (rule-name logic-name-list)
  (if (assoc rule-name *mch2-rules* :test #'string=)
      (rplacd (assoc rule-name *mch2-rules* :test #'string=) logic-name-list)
      (setf *mch2-rules* (acons rule-name logic-name-list *mch2-rules*))))

@export
(defun del-rule (rule-name)
  (setf *mch2-rules* (remove-if #'(lambda (x)
                                    (string= (car x)
                                             rule-name))
                                *mch2-rules*)))

@export
(defun set-logic (logic-name logic-body)
  (if (assoc logic-name *mch2-logics* :test #'string=)
      (rplacd (assoc logic-name *mch2-logics* :test #'string=) logic-body)
      (setf *mch2-logics* (acons logic-name logic-body *mch2-logics*))))

@export
(defun show-all-rules ()
  (dolist (rule *mch2-rules*)
    (format t "rule name:~5T~A~%" (car rule))))

@export
(defun show-all-logics ()
  (dolist (logic *mch2-logics*)
    (format t "logic name:~5T~A~%" (car logic))))

@export
(defun show-rule (rule-name)
  (let ((rule (assoc rule-name *mch2-rules* :test #'string=)))
    (format t "rule name :~5T~A~%" (car rule))
    (dolist (logic (cdr rule))
      (format t "logic name:~5T~A~%" (car logic)))))

@export
(defun show-logic (logic-name)
  (let ((logic (assoc logic-name *mch2-logics* :test #'string=)))
    (format t "logic name:~5T~A~%" (car logic))
    (format t "logic body:~A~%" (cdr logic))))

@export
(defun show-user ()
  (dolist (user *mch2-users*)
    (format t "user address:~5T~A~%" user)))

@export
(defun add-user (user)
  (unless (member user *mch2-users* :test #'string=)
    (push user *mch2-users*)))

@export
(defun del-user (user)
  (delete-if #'(lambda (x)
                 (string= x user))
             *mch2-users*))

@export
(defun check (rule-name mail)
  (loop for logic-name in (cdr (assoc rule-name *mch2-rules* :test #'string=))
        do (let ((logic-fn (cdr (assoc logic-name *mch2-logics* :test #'string=))))
             (multiple-value-bind (result message)
                 (funcall logic-fn mail)
               (format t "CHECK:~A~%MESSAGE:~A~%" logic-name message)))))

@export
(defun get-system-author ()
  (asdf:system-author (asdf:find-system :mch2)))

@export
(defun get-system-version ()
  (slot-value (asdf:find-system :mch2) 'asdf:version))

