#|
  This file is a part of mch2 project.
  Copyright (c) 2013 tamura shingo
|#

(in-package :cl-user)
(defpackage mch2.lib.basic
  (:use :cl)
  (:import-from :mch2.lib.mail
                :def-logic
                :<mail>
                :<attach>
                :send-p
                :send-contains-p
                :ok
                :ng)
  (:import-from :mch2.util
                :string-starts-with
                :string-ends-with)
  (:import-from :mch2.util.zip
                :parse-zip
                :zip-encrypted-p))
(in-package :mch2.lib.basic)


;;
;; あて先に社外アドレスが存在しないことをチェックする。
;;
(def-logic domain-internal-only-p (mail)
  (loop for address in (append (mch2-mail::send-to mail)
                               (mch2-mail::send-cc mail)
                               (mch2-mail::send-bcc mail))
        when (not (mch2-util:string-ends-with "@mydomain" address))
          return (ng (format nil "あて先に社外アドレスがあります。:~A" address))
        finally
          (return (ok "あて先は問題ありません。"))))

;;
;; 添付ファイルの暗号化有無をチェックする。
;;
(def-logic attach-encrypted-p (mail)
  (loop for attach-file in (mch2-mail::attach mail)
        when (not (mch2-zip:zip-encrypted-p (coerce (mch2-mail::content attach-file) 'list)))
          return (ng (format nil "添付ファイルが暗号化されていません。:~A" (mch2-mail::filename attach-file)))
        finally
          (return (ok "添付ファイルは暗号化されています。"))))


