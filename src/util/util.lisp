#|
  This file is a part of mch2 package.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.util
  (:nicknames :mch2-util)
  (:use :cl))
(in-package :mch2.util)

(cl-syntax:use-syntax :annot)

@export
(defun read-binary-file (path)
  (with-open-file (in path :element-type '(unsigned-byte 8))
    (let ((bin (make-array (file-length in) :element-type '(unsigned-byte 8))))
      (read-sequence bin in)
      bin)))

@export
(defun take-list (list num)
  (labels ((take-n (list num acc)
             (if (or (<= num 0)
                     (null list))
                 (values (nreverse acc) list)
                 (take-n (cdr list) (1- num) (cons (car list) acc)))))
    (take-n list num '())))

@export
(defun split (list num)
  (labels ((split (list acc)
             (multiple-value-bind (item rest)
                 (take-list list num)
               (if (null rest)
                   (nreverse (cons item acc))
                   (split rest (cons item acc))))))
    (split list '())))

@export
(defun split-group (list num-list &key (rest-p nil))
  (labels ((split-n (list num-list acc)
             (cond ((or (and (not rest-p)
                             (or (null list)
                                 (null num-list)))
                        (and rest-p
                             (null list)))
                    (nreverse acc))
                   ((and rest-p
                         (null num-list))
                    (nreverse (cons list acc)))
                   (t
                    (multiple-value-bind (taken-list rest-list)
                        (take-list list (car num-list))
                      (split-n rest-list (cdr num-list) (cons taken-list acc)))))))
    (split-n list num-list '())))


@export
(defun little-endian-to-num (list)
  (loop for x in list
        for idx upfrom 0
        sum (ash x (* idx 8))))

@export
(defun string-starts-with (start str)
  (and (>= (length str) (length start))
       (string-equal start str :end2 (length start))))

@export
(defun string-ends-with (end str)
  (and (>= (length str) (length end))
       (string-equal end str :start2 (- (length str) (length end)))))


