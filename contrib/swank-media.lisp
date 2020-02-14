;;; swank-media.lisp --- insert other media (images)
;;
;; Authors: Christophe Rhodes <csr21@cantab.net>
;;
;; Licence: GPLv2 or later
;;

(in-package :swank)

;; this file is empty of functionality.  The slime-media contrib
;; allows swank to return messages other than :write-string as repl
;; results; this is used in the R implementation of swank to display R
;; objects with graphical representations (such as trellis objects) as
;; image presentations in the swank repl.  In R, this is done by
;; having a hook function for the preparation of the repl results, in
;; addition to the already-existing hook for sending the repl results
;; (*send-repl-results-function*, used by swank-presentations.lisp).
;; The swank-media.R contrib implementation defines a generic function
;; for use as this hook, along with methods for commonly-encountered
;; graphical R objects.  (This strategy is harder in CL, where methods
;; can only be defined if their specializers already exist; in R's S3
;; object system, methods are ordinary functions with a special naming
;; convention)

;; Whatever, dude...

(defun insert-image (&key file data type string)
  (send-to-emacs (list :write-image
                       (cond (file
                              ;; This should really be
                              ;; native-namestring.
                              (namestring file))
                             ((and (stringp data) type)
                              ;; Data is assumed to base64-encoded;
                              ;; type must be provided.
                              (list (list :data data :type (string-downcase type))))
                             (t
                              (error "Can't build :write-image event.")))
                       (or string " ")))
  (values))

(export 'insert-image)

(provide :swank-media)
