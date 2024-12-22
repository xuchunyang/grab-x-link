;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with <open> and enter text in its buffer.

(require 'cl-lib)

(declare-function org-make-link-string "org" (link &optional description))

(defun grab-x-link--shell-command-to-string (command)
  (with-temp-buffer
    (if (and (zerop (call-process-shell-command command nil t))
             (> (buffer-size) 0))
        (substring (buffer-string) 0 -1)
      nil)))

(defun grab-x-link--build (url-title &optional type)
  "Build plain or markdown or org link."
  (let ((url (car url-title))
        (title (cdr url-title)))
    (cl-case type
      ('org  (progn (require 'org)
                    (org-make-link-string url title)))
      ('markdown (format "[%s](%s)" title url))
      (t url))))

(defun grab-x-link--title-strip (string suffix)
  "Remove SUFFIX from STRING."
  (cond ((< (length string) (length suffix)) string)
        ((string= (substring string (- (length string) (length suffix))) suffix)
         (substring string 0 (- (length suffix))))
        (t string)))

(defun grab-x-link--get-clipboard ()
  (if (display-graphic-p)
      ;; NOTE: This function is obsolete since 25.1
      (x-get-clipboard)
    (cond ((executable-find "xsel") (grab-x-link--shell-command-to-string "xsel --clipboard"))
          ((executable-find "xclip") (grab-x-link--shell-command-to-string "xclip -selection clipboard -o"))
          (t (error "Can't get clipboard because xsel or xclip is not installed")))))

(defun grab-x-link-firefox ()
  (let ((emacs-window
         (grab-x-link--shell-command-to-string
          "xdotool getactivewindow"))
        (firefox-window
         (or (grab-x-link--shell-command-to-string
              "xdotool search --classname Navigator")
             (error "Can't detect Firfox Window -- is it running?"))))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" firefox-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (grab-x-link--get-clipboard)))
          (title (grab-x-link--title-strip
                  (grab-x-link--shell-command-to-string
                   (concat "xdotool getwindowname " firefox-window))
                  " - Mozilla Firefox")))
      (cons url title))))

(defun grab-x-link-chromium ()
  (let ((emacs-window
         (grab-x-link--shell-command-to-string
          "xdotool getactivewindow"))
        (chromium-window
         (or (grab-x-link--shell-command-to-string
              "xdotool search --name ' - Chromium' | tail -1")
             (error "Can't detect Chromium Window -- is it running?"))))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" chromium-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (grab-x-link--get-clipboard)))
          (title (grab-x-link--title-strip
                  (grab-x-link--shell-command-to-string
                   (concat "xdotool getwindowname " chromium-window))
                  " - Chromium")))
      (cons url title))))

(defun grab-x-link-chrome ()
  (let ((emacs-window
         (grab-x-link--shell-command-to-string
          "xdotool getactivewindow"))
        (chrome-window
         (or (grab-x-link--shell-command-to-string
              "xdotool search --name ' - Google Chrome' | tail -1")
             (error "Can't detect Chrome Window -- is it running?"))))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" chrome-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (grab-x-link--get-clipboard)))
          (title (grab-x-link--title-strip
                  (grab-x-link--shell-command-to-string
                   (concat "xdotool getwindowname " chrome-window))
                  " - Google Chrome")))
      (cons url title))))

(defun grab-x-link-vivaldi ()
  (let ((emacs-window
         (grab-x-link--shell-command-to-string
          "xdotool getactivewindow"))
        (vivaldi-window
         (or (grab-x-link--shell-command-to-string
              "xdotool search --name ' - Vivaldi' | tail -1")
             (error "Can't detect Chrome Window -- is it running?"))))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" vivaldi-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (grab-x-link--get-clipboard)))
          (title (grab-x-link--title-strip
                  (grab-x-link--shell-command-to-string
                   (concat "xdotool getwindowname " vivaldi-window))
                  " - Vivaldi")))
      (cons url title))))



(defun grab-x-link-brave ()
  (let ((emacs-window
         (grab-x-link--shell-command-to-string
          "xdotool getactivewindow"))
        (brave-window
         (or (grab-x-link--shell-command-to-string
              "xdotool search --name ' - brave' | tail -1")
             (error "Can't detect brave Window -- is it running?"))))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" brave-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (grab-x-link--get-clipboard)))
          (title (grab-x-link--title-strip
                  (grab-x-link--shell-command-to-string
                   (concat "xdotool getwindowname " brave-window))
                  " - brave")))
      (cons url title))))

;;;###autoload
(defun grab-x-link-firefox-insert-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-firefox))))

;;;###autoload
(defun grab-x-link-brave-insert-org-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-brave) 'org)))

;;;###autoload
(defun grab-x-link-firefox-insert-org-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-firefox) 'org)))

;;;###autoload
(defun grab-x-link-firefox-insert-markdown-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-firefox) 'markdown)))

;;;###autoload
(defun grab-x-link-chromium-insert-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chromium))))

;;;###autoload
(defun grab-x-link-chromium-insert-org-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chromium) 'org)))

;;;###autoload
(defun grab-x-link-chromium-insert-markdown-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chromium) 'markdown)))

;;;###autoload
(defun grab-x-link-chrome-insert-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chrome))))

;;;###autoload
(defun grab-x-link-chrome-insert-org-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chrome) 'org)))

;;;###autoload
(defun grab-x-link-chrome-insert-markdown-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-chrome) 'markdown)))

;;;###autoload
(defun grab-x-link-vivaldi-insert-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-vivaldi))))

;;;###autoload
(defun grab-x-link-vivaldi-insert-org-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-vivaldi) 'org)))

;;;###autoload
(defun grab-x-link-chrome-insert-markdown-link ()
  (interactive)
  (insert (grab-x-link--build (grab-x-link-vivaldi) 'markdown)))


;;;###autoload
(defun grab-x-link (app &optional link-type)
  "Prompt for an application to grab a link from.
When done, go gtab the link, and insert it at point.

If called from Lisp, grab link APP and return it (as a string) in
LINK-TYPE.  APP is a symbol and must be one of '(chromium
firefox), LINK-TYPE is also a symbol and must be one of '(plain
markdown org), if LINK-TYPE is omitted or nil, plain link will be used."
  (interactive
   (let ((apps
          '((?c . chromium)
            (?g . chrome)
            (?f . firefox)
            (?b . brave)
	    (?v . vivaldi)
            ))
         (link-types
          '((?p . plain)
            (?m . markdown)
            (?o . org)))
         (propertize-menu
          (lambda (string)
            "Propertize substring between [] in STRING."
            (with-temp-buffer
              (insert string)
              (goto-char 1)
              (while (re-search-forward "\\[\\(.+?\\)\\]" nil 'no-error)
                (replace-match (format "[%s]" (propertize (match-string 1) 'face 'bold))))
              (buffer-string))))
         input app link-type)

     (message (funcall propertize-menu
                       "Grab link from [c]hromium [g]chrome [f]irefox [v]vivaldi [b]brave:"))
     (setq input (read-char-exclusive))
     (setq app (cdr (assq input apps)))

     (message (funcall propertize-menu
                       (format "Grab link from %s as a [p]lain [m]arkdown [o]rg link:" app)))
     (setq input (read-char-exclusive))
     (setq link-type (cdr (assq input link-types)))
     (list app link-type)))

  (unless link-type
    (setq link-type 'plain))

  (unless (and (memq app '(chromium chrome firefox brave vivaldi))
               (memq link-type '(plain org markdown)))
    (error "Unknown app %s or link-type %s" app link-type))

  (let ((link (grab-x-link--build
               (funcall (intern (format "grab-x-link-%s" app)))
               link-type)))
    (and (called-interactively-p 'any) (insert link))
    link))

(provide 'grab-x-link)
;;; grab-x-link.el ends here



