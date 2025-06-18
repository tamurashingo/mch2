#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.server
  (:use :cl)
  (:import-from :ningle
                :route
                :next-route
                :*response*)
  (:import-from :clack
                :clackup
                :stop)
  (:import-from :lack.builder
                :builder)
  (:import-from :mch2.server.app
                :<app>)
  (:import-from :mch2.util
                :split)
  (:import-from :mch2.lib.mail
                :<mail>
                :<attach>))
(in-package :mch2.server)

(cl-syntax:use-syntax :annot)

(defparameter *static-path*
  (asdf:system-relative-pathname :mch2 "static/html/"))

(defparameter *template-path*
  (asdf:system-relative-pathname :mch2 "templates/"))

(defun template-path (filename)
  (merge-pathnames filename *template-path*))

(defun static-path (filename)
  (merge-pathnames filename *static-path*))


(defun build (app)
  (builder
   (:static
    :path (lambda (path)
            (when (ppcre:scan "^(?:/images/|/css/|/js/|/html/|/favicon.ico$)" path)
              path))
    :root (asdf:system-relative-pathname :mch2 "static/"))
   app))


(defvar *app* (make-instance '<app>))
(defvar *deploy-time* nil)

(setf (route *app* "*")
      #'(lambda (params)
          (declare (ignore params))
          (or (next-route)
              `(404
                (:content-type "text/html")
                ,(static-path "404.html")))))

(setf (route *app* "/")
      #'(lambda (params)
          (declare (ignore params))
          (emb:execute-emb
           (template-path "index.tmpl")
           :env `(:version ,(mch2:get-system-version)
                  :author ,(mch2:get-system-author)
                  :deploy-time ,*deploy-time*))))

(setf (route *app* "/rules.cgi")
      #'(lambda (params)
          (declare (ignore params))
          (format nil "~{~A~%~}" (loop for rule in mch2:*mch2-rules*
                                       collect (car rule)))))


(setf (route *app* "/logics.cgi")
      #'(lambda (params)
          (declare (ignore params))
          (format nil "~{~A~%~}" (loop for rule in mch2:*mch2-logics*
                                       collect (car rule)))))


(defun get-param (key params)
  (ppcre:split "," (getf params key)))
#|
  (let ((list))
    (labels ((get-loop (param-list)
               (cond ((null param-list)
                      (nreverse list))
                     ((eq (car param-list) key)
                      (push (cadr param-list) list)
                      (get-loop (cddr param-list)))
                     (t
                      (get-loop (cddr param-list))))))
      (get-loop params))))
|#

(defun create-attach (params)
  (let ((filenames (get-param :attach_filename params))
        (contents (get-param :attach_content params)))
    (loop for filename in filenames
          for content in contents
          collect (let ((inst (make-instance '<attach>)))
                    (setf (filename inst) filename)
                    (setf (contents inst) contents)
                    inst))))

(defun create-mail (params)
  (let ((mail (make-instance '<mail>))
        (params (split params 2)))
    (setf (mch2-mail::send-to mail) (get-param :addr_to params))
    (setf (mch2-mail::send-cc mail) (get-param :acdr_cc params))
    (setf (mch2-mail::send-bcc mail) (get-param :addr_bcc params))
    (setf (mch2-mail::subject mail) (car (get-param :subject params)))
    (setf (mch2-mail::content mail) (car (get-param :content params)))
    (setf (mch2-mail::attach mail) (create-attach params))
    mail))

(setf (route *app* "/check/:rule" :method :POST)
      #'(lambda (params)
          (let* ((mail (create-mail params))
                 (rule-name (format nil "~A" (getf params :rule)))
                 (logics (cdr (assoc rule-name mch2:*mch2-rules* :test #'string=)))
                 (result nil))

            ;; check mail
            (when logics
                (loop for logic-name in logics
                      for logic-fn = (cdr (assoc logic-name mch2:*mch2-logics* :test #'string=))

                      when logic-fn
                        do (multiple-value-bind (ret msg)
                               (funcall logic-fn mail)
                             (push
                              `(:logic-name ,logic-name
                                :result ,(if ret "ok" "ng")
                                :msg ,msg)
                              result)))
                (nreverse result))

            ;; parse result
            (emb:execute-emb
             (template-path "result.tmpl")
             :env `(:version ,(mch2:get-system-version)
                    :author ,(mch2:get-system-author)
                    :deploy-time ,*deploy-time*
                    :result ,result)))))


(let ((handler nil)
      (JST (local-time::make-timezone :name "JST"
                                      :path (asdf:system-relative-pathname :local-time #p"zoneinfo/Japan"))))

  @export
  (defun start-server ()
    (setf *deploy-time* (local-time:format-timestring nil
                                                      (local-time:now)
                                                      :timezone JST
                                                      :format '((:YEAR 4) #\/ (:MONTH 2) #\/ (:DAY 2)
                                                                #\Space
                                                                (:HOUR 2) #\: (:MIN 2) #\: (:SEC 2)
                                                                #\Space
                                                                :timezone)))
    (setf handler
          (clackup (build *app*)
                   :address "0.0.0.0")))
  
  @export
  (defun stop-server ()
    (stop handler)
    (setf handler nil)))

