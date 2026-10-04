;;; Administration.el --- File and project management -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025 Peter Prevos
;; Additions Copyright (C) 2025 Paul James Harper <pjharper@pm.me>

;; Original Author: Peter Prevos <peter@prevos.net>
;; Maintainer: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; This module configures the administrative aspects of the Emacs Writing
;; Studio environment: task management with Org agenda, file management
;; with Dired, backup and recent-file tracking, bookmarks, and image
;; viewing.
;;
;;; Code:

(use-package org
  :custom
  (org-agenda-custom-commands
   '(("e" "Agenda, next actions and waiting"
      ((agenda "" ((org-agenda-overriding-header "Next three days:")
                   (org-agenda-span 3)
                   (org-agenda-start-on-weekday nil)))
       (todo "NEXT" ((org-agenda-overriding-header "Next Actions:")))
       (todo "WAIT" ((org-agenda-overriding-header "Waiting:")))))))
  :bind
  (("C-c a" . org-agenda)))

(use-package khalel
  :ensure t
  :after org
  :custom
  (khalel-khal-command (or (executable-find "khal") "khal"))
  (khalel-vdirsyncer-command (or (executable-find "vdirsyncer") "vdirsyncer"))
  (khalel-capture-key "e")
  (khalel-import-org-file (expand-file-name "calendar.org" org-directory))
  (khalel-import-org-file-confirm-overwrite nil)
  ;; Passed through `org-read-date'. Import today..+60d so the current
  ;; month is populated in the agenda.
  (khalel-import-start-date "today")
  (khalel-import-end-date "+60d")
  :config
  (khalel-add-capture-template)

  (defun my/khalel-capture-event ()
    "Capture a new calendar event via khalel's `org-capture' template."
    (interactive)
    (org-capture nil khalel-capture-key))

  ;; Belt and braces if `org-agenda-files' is later narrowed to a list.
  (add-to-list 'org-agenda-files khalel-import-org-file)
  :bind
  (("C-c k i" . khalel-import-events)
   ("C-c k n" . my/khalel-capture-event)
   ("C-c k e" . khalel-edit-calendar-event)
   ("C-c k x" . khalel-export-org-subtree-to-calendar)
   ("C-c k v" . khalel-run-vdirsyncer)))

(use-package dired
  :ensure nil
  :commands
  (dired dired-jump)
  :hook
  (dired-mode . dired-omit-mode)
  :custom
  (dired-listing-switches
   "-goah --group-directories-first --time-style=long-iso")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-omit-files "^\\.[a-zA-Z0-9]+")
  :init
  (put 'dired-find-alternate-file 'disabled nil)
  :bind
  (:map dired-mode-map
        ("." . dired-omit-mode)))

;; Expand/collapse subdirectories inline with TAB

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  (:map dired-mode-map
        ("<tab>"     . dired-subtree-toggle)
        ("TAB"       . dired-subtree-toggle)
        ("<backtab>" . dired-subtree-remove)
        ("S-TAB"     . dired-subtree-remove))
  :custom
  (dired-subtree-use-backgrounds nil))

;; Dired-like interface for the system trash

(use-package trashed
  :ensure t
  :commands (trashed)
  :custom
  (trashed-action-confirmer 'y-or-n-p)
  (trashed-use-header-line t)
  (trashed-sort-key '("Date deleted" . t))
  (trashed-date-format "%Y-%m-%d %H:%M:%S"))

(setq-default backup-directory-alist
              `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
              version-control t
              delete-old-versions t
              create-lockfiles nil)

(use-package recentf
  :config
  (recentf-mode t)
  :custom
  (recentf-max-saved-items 50)
  :bind
  (("C-c w r" . recentf-open)))

(use-package bookmark
  :custom
  (bookmark-save-flag 1)
  :bind
  (("C-x r d" . bookmark-delete)))

(use-package emacs
  :custom
  (image-dired-external-viewer "gimp")
  :bind
  ((:map image-mode-map
         ("k" . image-kill-buffer)
         ("<right>" . image-next-file)
         ("<left>"  . image-previous-file))
   (:map dired-mode-map
         ("C-<return>" . image-dired-dired-display-external))))

(use-package image-dired
  :bind
  (("C-c w I" . image-dired))
  (:map image-dired-thumbnail-mode-map
        ("C-<right>" . image-dired-display-next)
        ("C-<left>"  . image-dired-display-previous)))

(keymap-global-set "C-c w v" 'customize-variable)

;;------------------------------------------------------------
;; Agenda integration functions
;;------------------------------------------------------------

(defun my/denote-file-matches-agenda-keywords-p (file)
  "Return t if FILE has a filetag starting with any prefix in
`my/denote-agenda-keywords'."
  (when (featurep 'denote)
    (let ((tags (denote-extract-keywords-from-path file)))
      (seq-some (lambda (prefix)
                  (seq-some (lambda (tag)
                              (string-prefix-p prefix tag))
                            tags))
                my/denote-agenda-keywords))))

(defun my/denote-list-category-files (category)
  "Return list of Denote files whose #+category: header equals CATEGORY."
  (when (featurep 'denote)
    (remove nil
            (mapcar (lambda (file)
                      (with-temp-buffer
                        (insert-file-contents file)
                        (let ((cat (cadr (assoc "CATEGORY"
                                                (org-collect-keywords
                                                 '("CATEGORY"))))))
                          (when (and cat (string= category cat))
                            file))))
                    (denote-directory-files)))))

(defun my/prime-org-agenda-files-denote ()
  "Add relevant Denote files to `org-agenda-files'.

Selects by two criteria:
  1. Tag-based  — any file tagged with a prefix in
     `my/denote-agenda-keywords' (projects, clients, surveys,
     planning, admin).
  2. Category-based — files in active service-line categories.

Safe to call multiple times; `add-to-list' prevents duplicates."
  (interactive)
  (when (featurep 'denote)
    (let* ((tag-files
            (seq-filter #'my/denote-file-matches-agenda-keywords-p
                        (denote-directory-files)))
           (category-files
            (flatten-list
             (mapcar #'my/denote-list-category-files
                     '("Service: Cyber-Physical Survey"
                       "Service: Risk Assessment (Digital)"
                       "Service: Risk Assessment (Physical)"
                       "Service: Incident Response"
                       "Admin: Operations"
                       "Admin: Finance"))))
           (all-files (seq-uniq (append tag-files category-files))))
      (dolist (file all-files)
        (add-to-list 'org-agenda-files file :append))
      (message "Denote agenda: %d files added." (length all-files))
      org-agenda-files)))

;; Re-prime after saving any Denote note so tag/category changes
;; take effect immediately without restarting Emacs.
(with-eval-after-load 'denote
  (add-hook 'after-save-hook
            (lambda ()
              (when (and (eq major-mode 'org-mode)
                         (buffer-file-name)
                         (denote-file-is-note-p (buffer-file-name)))
                (my/prime-org-agenda-files-denote))))
  ;; Prime on startup
  (my/prime-org-agenda-files-denote))

(provide 'Administration)
;;; Administration.el ends here
