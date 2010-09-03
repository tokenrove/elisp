;;; quick hack to add include files without moving around
;;; TODO: useful universal argument
;;; TODO: better completion of file argument
;;; TODO: maintain sorted order of includes per style(9)

(defun cc-mode-hop-to-includes ()
  "Move point to the first block of #include lines, or where they
should be if there are none."
  (goto-char (point-min))
  (unless (search-forward "#include" nil t)
    (c-forward-comments))
  (beginning-of-line))

;; XXX XXX note that comment below is actually wrong.  we don't even
;; walk the directory yet, despite the immense utility of completing
;; X11/foo.h.
;; XXX note I only go through one depth of directory walking because
;; anything much more than that seems pretty unreasonable to me.
;; But feel free to hack it anyway if it floats your boat.
(flet ((cs (path) (mapcan (lambda (d) (directory-files d nil "^[^.]")) path)))
  (defun append-include-line (file &optional localp)
    "Append a #include <file> line to the top of the file without
moving around.  Uses ffap-c-path to figure out where to look for
includes.  If localp is set, it looks in default-directory and
uses quotes instead of angle brackets."
    (interactive
     (list (completing-read "Include: " (cs (if current-prefix-arg (list default-directory) ffap-c-path)))
	   current-prefix-arg))
    (save-excursion
      (cc-mode-hop-to-includes)
      (insert "#include " (if localp "\"" "<") file (if localp "\"" ">") "\n"))))

(add-hook 'c-mode-hook '(lambda () (define-key c-mode-map "\C-cI" 'append-include-line)))

(provide 'cc-mode-append-include)