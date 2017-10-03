(eval-and-compile
  (require 'slime))

(define-slime-contrib slime-media
  "Display things other than text in SLIME buffers"
  (:authors "Christophe Rhodes <csr21@cantab.net>")
  (:license "GPL")
  (:slime-dependencies slime-repl)
  (:swank-dependencies swank-media)
  (:on-load
   (add-hook 'slime-event-hooks 'slime-dispatch-media-event)))

(defun slime-media-decode-image (specs)
  (mapcar (lambda (image)
            (let ((data (plist-get image :data)))
              (when data
                (setq image (plist-put image :data (base64-decode-string data)))))
            (let ((type (plist-get image :type)))
              (when (stringp type)
                (setq image (plist-put image :type (intern type)))))
	    image)
	  specs))

(defun slime-dispatch-media-event (event)
  (slime-dcase event
    ((:write-image image string)
     (let ((img (or (find-image (slime-media-decode-image image))
                    (create-image image))))
       (slime-media-insert-image img string))
     t)
    ((:popup-buffer bufname string mode)
     (slime-with-popup-buffer (bufname :connection t :package t)
       (when mode (funcall mode))
       (princ string)
       (goto-char (point-min)))
     t)
    (t nil)))

(defun slime-media-insert-image (image string &optional bol)
  (with-current-buffer (slime-output-buffer)
    (let ((marker (slime-repl-output-target-marker :repl-result)))
      (goto-char marker)
      (slime-propertize-region `(face slime-repl-result-face
                                      rear-nonsticky (face))
        (insert-image image string))
      ;; Move the input-start marker after the REPL result.
      (set-marker marker (point)))
    (slime-repl-show-maximum-output)))

(provide 'slime-media)
