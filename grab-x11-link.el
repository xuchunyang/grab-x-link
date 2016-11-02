;;; grab-x11-link.el --- Grab links from apps running in X11  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Chunyang Xu

;; Author: Chunyang Xu <mail@xuchunyang.me>
;; URL: https://github.com/xuchunyang/grab-x11-link
;; Package-Requires: ((emacs "24.4"))
;; Keywords: hyperlink
;; Version: 0.0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; xdotool(1) is required before using this package.

;; By using package, your most recent clipboard will be changed.

;;; Code:

(require 'subr-x)

(declare-function org-make-link-string "org" (link &optional description))

(defun grab-x11-link--shell-command-to-string (command)
  (string-trim
   (shell-command-to-string command)))

(defun grab-x11-link-firefox ()
  (let ((emacs-window
         (grab-x11-link--shell-command-to-string
          "xdotool getactivewindow"))
        (firefox-window
         (grab-x11-link--shell-command-to-string
          "xdotool search --classname Navigator")))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" firefox-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (x-get-clipboard)))
          (title (grab-x11-link--shell-command-to-string
                  (concat "xdotool getwindowname " firefox-window))))
      (cons url title))))

(defun grab-x11-link-chromium ()
  (let ((emacs-window
         (grab-x11-link--shell-command-to-string
          "xdotool getactivewindow"))
        (chromium-window
         (grab-x11-link--shell-command-to-string
          "xdotool search --class chromium-browser | tail -1")))
    (shell-command (format "xdotool windowactivate --sync %s key ctrl+l ctrl+c" chromium-window))
    (shell-command (format "xdotool windowactivate %s" emacs-window))
    (sit-for 0.2)
    (let ((url (substring-no-properties (x-get-clipboard)))
          (title (grab-x11-link--shell-command-to-string
                  (concat "xdotool getwindowname " chromium-window))))
      (cons url title))))

(defun grab-x11-link--build (url-title &optional type)
  "Build plain or markdown or org link."
  (let ((url (car url-title))
        (title (cdr url-title)))
    (cl-case type
      ('org  (progn (require 'org)
                    (org-make-link-string url title)))
      ('markdown (format "[%s](%s)" title url))
      (t url))))
;;;###autoload
(defun grab-x11-link-firefox-insert-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-firefox))))

;;;###autoload
(defun grab-x11-link-firefox-insert-org-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-firefox) 'org)))

;;;###autoload
(defun grab-x11-link-firefox-insert-markdown-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-firefox) 'markdown)))

;;;###autoload
(defun grab-x11-link-chromium-insert-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-chromium))))

;;;###autoload
(defun grab-x11-link-chromium-insert-org-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-chromium) 'org)))

;;;###autoload
(defun grab-x11-link-chromium-insert-markdown-link ()
  (interactive)
  (insert (grab-x11-link--build (grab-x11-link-chromium) 'markdown)))

(provide 'grab-x11-link)
;;; grab-x11-link.el ends here
