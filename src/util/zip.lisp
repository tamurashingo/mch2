#|
  This file is a part of mch2 package.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.util.zip
  (:nicknames :mch2-zip)
  (:use :cl)
  (:import-from :mch2.util
                :take-list
                :split-group
                :little-endian-to-num))
                
(in-package :mch2.util.zip)

(cl-syntax:use-syntax :annot)

@export
(defclass <zip-header-base> ()
  ((base-data :accessor base-data)))

@export
(defclass <zip-header> (<zip-header-base>)
  ((version-extract :accessor version-extract)
   (flag :accessor flag)
   (compression :accessor compression)
   (mod-time :accessor mod-time)
   (mod-date :accessor mod-date)
   (crc32 :accessor crc32)
   (compressed-size :accessor compressed-size)
   (uncompressed-size :accessor uncompressed-size)
   (filename-length :accessor filename-length)
   (extrafield-length :accessor extrafield-length)
   (filename :accessor filename)
   (extrafield :accessor extrafield)
   (data :accessor data)))

@export
(defclass <zip-central-header> (<zip-header-base>)
  ((version-made-by :accessor version-made-by)
   (version-extract :accessor version-extract)
   (flag :accessor flag)
   (compression :accessor compression)
   (mod-time :accessor mod-time)
   (mod-date :accessor mod-date)
   (crc32 :accessor crc32)
   (compressed-size :accessor compressed-size)
   (uncompressed-size :accessor uncompressed-size)
   (filename-length :accessor filename-length)
   (extrafield-length :accessor extrafield-length)
   (filecomment-length :accessor filecomment-length)
   (disknumber-start :accessor disknumber-start)
   (internal-attributes :accessor internal-attributes)
   (external-attributes :accessor external-attributes)
   (offset :accessor offset)
   (filename :accessor filename)
   (extrafield :accessor extrafield)
   (filecomment :accessor filecomment)))

@export
(defclass <zip-end-header> (<zip-header-base>)
  ((disk-number :accessor disk-number)
   (first-disk :accessor first-disk)
   (disk-entries :accessor disk-entries)
   (zip-entries :accessor zip-entries)
   (total-size :accessor total-size)
   (offset :accessor offset)
   (comment-size :accessor comment-size)
   (comment :accessor comment)))


@export
(defun read-zip-header (data)
  (let ((items (split-group data '(4 ; signature
                                   2 ; version needed to extract
                                   2 ; general purpose bit flag
                                   2 ; compression method
                                   2 ; last mod file time
                                   2 ; last mod file date
                                   4 ; crc-32
                                   4 ; compressed size
                                   4 ; uncompressed size
                                   2 ; file name length
                                   2 ; extra field length
                                   )
                            :rest-p t ; file name, extra field, data
                                   ))
        (inst (make-instance '<zip-header>)))
    (setf (slot-value inst 'version-extract) (little-endian-to-num (nth 1 items)))
    (setf (slot-value inst 'flag) (little-endian-to-num (nth 2 items)))
    (setf (slot-value inst 'compression) (little-endian-to-num (nth 3 items)))
    (setf (slot-value inst 'mod-time) (little-endian-to-num (nth 4 items)))
    (setf (slot-value inst 'mod-date) (little-endian-to-num (nth 5 items)))
    (setf (slot-value inst 'crc32) (little-endian-to-num (nth 6 items)))
    (setf (slot-value inst 'compressed-size) (little-endian-to-num (nth 7 items)))
    (setf (slot-value inst 'uncompressed-size) (little-endian-to-num (nth 8 items)))
    (setf (slot-value inst 'filename-length) (little-endian-to-num (nth 9 items)))
    (setf (slot-value inst 'extrafield-length) (little-endian-to-num (nth 10 items)))

    (let ((rest-items (split-group (nth 11 items) `(,(slot-value inst 'filename-length)
                                                     ,(slot-value inst 'extrafield-length)
                                                     ,(slot-value inst 'compressed-size))
                                   :rest-p t)))
      (setf (slot-value inst 'filename) (nth 0 rest-items))
      (setf (slot-value inst 'extrafield) (nth 1 rest-items))
      (setf (slot-value inst 'data) (nth 2 rest-items))

      (values inst (nth 3 rest-items)))))


@export
(defun read-zip-central-header (data)
  (let ((items (split-group data '(4 ; signature
                                   2 ; version made by
                                   2 ; version needed to extract
                                   2 ; general purpose bit flag
                                   2 ; compression method
                                   2 ; last mod file time
                                   2 ; last mod file date
                                   4 ; crc-32
                                   4 ; compressed size
                                   4 ; uncompressed size
                                   2 ; file name length
                                   2 ; extra field length
                                   2 ; file comment length
                                   2 ; disk number start
                                   2 ; internal file attributes
                                   4 ; external file attributes
                                   4 ; relative offset of local header
                                   )
                            :rest-p t  ; file name, extra field, file comment
                            ))
        (inst (make-instance '<zip-central-header>)))
    (setf (slot-value inst 'version-made-by) (little-endian-to-num (nth 1 items)))
    (setf (slot-value inst 'version-extract) (little-endian-to-num (nth 2 items)))
    (setf (slot-value inst 'flag) (little-endian-to-num (nth 3 items)))
    (setf (slot-value inst 'compression) (little-endian-to-num (nth 4 items)))
    (setf (slot-value inst 'mod-time) (little-endian-to-num (nth 5 items)))
    (setf (slot-value inst 'mod-date) (little-endian-to-num (nth 6 items)))
    (setf (slot-value inst 'crc32) (little-endian-to-num (nth 7 items)))
    (setf (slot-value inst 'compressed-size) (little-endian-to-num (nth 8 items)))
    (setf (slot-value inst 'uncompressed-size) (little-endian-to-num (nth 9 items)))
    (setf (slot-value inst 'filename-length) (little-endian-to-num (nth 10 items)))
    (setf (slot-value inst 'extrafield-length) (little-endian-to-num (nth 11 items)))
    (setf (slot-value inst 'filecomment-length) (little-endian-to-num (nth 12 items)))
    (setf (slot-value inst 'disknumber-start) (little-endian-to-num (nth 13 items)))
    (setf (slot-value inst 'internal-attributes) (little-endian-to-num (nth 14 items)))
    (setf (slot-value inst 'external-attributes) (little-endian-to-num (nth 15 items)))
    (setf (slot-value inst 'offset) (little-endian-to-num (nth 16 items)))

    (let ((rest-items (split-group (nth 17 items) `(,(slot-value inst 'filename-length)
                                                     ,(slot-value inst 'extrafield-length)
                                                     ,(slot-value inst 'filecomment-length))
                                   :rest-p t)))
      (setf (slot-value inst 'filename) (nth 0 rest-items))
      (setf (slot-value inst 'extrafield) (nth 1 rest-items))
      (setf (slot-value inst 'filecomment) (nth 2 rest-items))

      (values inst (nth 3 rest-items)))))



@export
(defun read-zip-end-header (data)
  (let ((items (split-group data '(4 ; signature
                                   2 ; number of this disk
                                   2 ; number of the disk with the start of the central directory
                                   2 ; number of the entries in the central directory on this disk
                                   2 ; total number of entries in the central directory
                                   4 ; size of the central directory
                                   4 ; offset of start of central directory with respect to the starting disk number
                                   2 ; zip file comment length
                                   )
                            :rest-p t  ; zip file comment
                            ))
        (inst (make-instance '<zip-end-header>)))
    (setf (slot-value inst 'disk-number) (little-endian-to-num (nth 1 items)))
    (setf (slot-value inst 'first-disk) (little-endian-to-num (nth 2 items)))
    (setf (slot-value inst 'disk-entries) (little-endian-to-num (nth 3 items)))
    (setf (slot-value inst 'zip-entries) (little-endian-to-num (nth 4 items)))
    (setf (slot-value inst 'total-size) (little-endian-to-num (nth 5 items)))
    (setf (slot-value inst 'offset) (little-endian-to-num (nth 6 items)))
    (setf (slot-value inst 'comment-size) (little-endian-to-num (nth 7 items)))
    
    (let ((rest-items (split-group (nth 8 items) `(,(slot-value inst 'comment-size)))))
      (setf (slot-value inst 'comment) (nth 1 rest-items))
      
      (values inst '()))))

(defun zip-header-p (data)
  (let ((signature (subseq data 0 4)))
    (equal signature '(#x50 #x4B #x03 #x04))))

(defun zip-central-header-p (data)
  (let ((signature (subseq data 0 4)))
    (equal signature '(#x50 #x4B #x01 #x02))))

(defun zip-end-header-p (data)
  (let ((signature (subseq data 0 4)))
    (equal signature '(#x50 #x4B #x05 #x06))))

(defun zip-data-descriptor-p (data)
  (let ((signature (subseq data 0 4)))
    (equal signature '(#x50 #x4B #x07 #x08))))


(defun seek-next-header (data)
  "seek next header (starts with `PK') to parse data descriptor for simpicity.
some data descriptors have signature, others data descriptor don't have signature.
when no next header, returns input"
  (labels ((begin-seek (d)
             (cond ((null d)
                    data)
                   ((= (car d) #x50)
                    (in-p d))
                   (t
                    (begin-seek (cdr d)))))
           (in-p (d)
             (cond ((null d)
                    data)
                   ((= (cadr d) #x4B)
                    d)
                   (t
                    (begin-seek (cdr d))))))
    (begin-seek data)))


@export
(defun parse-zip (data &key (header-fn nil) (central-header-fn nil) (end-header-fn nil))
  (labels ((parse-main (data inst-list)
             (cond ((null data)
                    (nreverse inst-list))
                   ((zip-header-p data)
                    (multiple-value-bind (inst rest)
                        (read-zip-header data)
                      (when header-fn
                        (funcall header-fn inst))
                      (parse-main (seek-next-header rest) (cons inst inst-list))))
                   ((zip-data-descriptor-p data)
                    (parse-main (seek-next-header (subseq data 16)) inst-list))
                   ((zip-central-header-p data)
                    (multiple-value-bind (inst rest)
                        (read-zip-central-header data)
                      (when central-header-fn
                        (funcall central-header-fn inst))
                      (parse-main (seek-next-header rest) (cons inst inst-list))))
                   ((zip-end-header-p data)
                    (multiple-value-bind (inst rest)
                        (read-zip-end-header data)
                      (when end-header-fn
                        (funcall end-header-fn inst))
                      (parse-main nil (cons inst inst-list))))
                   (t
                    (error (format nil "unknown header:~{ ~A~}"
                                   (subseq data 0 (min 4 (length data)))))))))
    (parse-main data '())))

(defgeneric encrypted-p (x))

(defmethod encrypted-p ((x <zip-header>))
  (= #x01 (logand #x01 (flag x))))

(defmethod encrypted-p (x)
  t)

@export
(defun zip-encrypted-p (data)
  (reduce #'(lambda (x y)
              (and x y))
          (mapcar #'encrypted-p (parse-zip data))))

