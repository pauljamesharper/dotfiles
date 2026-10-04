;;; init.el --- Emacs Writing Studio init -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025 Peter Prevos
;; Additions Copyright (C) 2025 Paul James Harper <pjharper@pm.me>

;; Original Author: Peter Prevos <peter@prevos.net>
;; Maintainer: Paul James Harper <pjharper@pm.me>
;; URL: https://github.com/pprevos/emacs-writing-studio/
;;
;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;
;; Tangled from: Emacs.org
;; See: https://lucidmanager.org/tags/emacs
;;
;;; Code:

(when (< emacs-major-version 29)
  (error "Emacs Writing Studio requires version 29 or later"))

;; Set package archives

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

(use-package use-package
  :custom
  (use-package-always-ensure t)
  (package-native-compile t)
  (warning-minimum-level :emergency))

(use-package exec-path-from-shell
  :if (daemonp)
  :custom
  (exec-path-from-shell-arguments '("-l" "-i"))
  (exec-path-from-shell-warn-duration-millis 2000)
  :config
  (exec-path-from-shell-initialize))

(defvar my/denote-keywords
  '(("project"  . "Project")
    ("area"     . "Area")
    ("resource" . "Resource")
    ("archive"  . "Archive"))
  "Alist of Denote filetags to descriptions, following the PARA method
(Projects, Areas, Resources, Archive).")

(defvar my/denote-agenda-keywords
  '("project")
  "Denote filetags whose files are added to `org-agenda-files'.")

(defvar my/notes-directory
  (concat (file-name-as-directory (getenv "HOME"))
          "ProtonDrive/Documents/notes/")
  "Root directory for Org notes, the Denote silo, and agenda files.")

(setq org-directory my/notes-directory
      org-default-notes-file (expand-file-name "inbox.org" my/notes-directory)
      org-agenda-files (list my/notes-directory))

;; Load EWS helper functions

(load-file (concat (file-name-as-directory user-emacs-directory)
		   "ews.el"))

;; Load EWS modules

(let ((modules-dir (expand-file-name "modules" user-emacs-directory)))
  (if (file-directory-p modules-dir)
      (dolist (module '("Inspiration"
                        "Ideation"
                        "Production"
                        "Publication"
                        "Administration"
                        "Programming"
                        "AI"
                        "Terminals"
                        "Meow"))
        (let ((module-path (expand-file-name module modules-dir)))
          (if (file-exists-p (concat module-path ".el"))
              (load module-path nil 'nomessage)
            (message "EWS: module not found: %s.el" module-path))))
    (message "EWS: modules directory not found: %s" modules-dir)))

(ews-missing-executables
 '(("gs" "mutool")
   "pdftotext"
   "soffice"
   "zip"
   ;; "ddjvu" — DjVuLibre isn't packaged for Fedora Atomic and DjVu is unused
   "curl"
   ("mpg321" "ogg123" "mplayer" "mpv" "vlc")
   ("grep" "ripgrep")
   ("convert" "gm")
   "dvipng"
   "latex"
   "hunspell"
   "git"
   ;; Programming module: Eglot/Flymake/tree-sitter toolchain
   "python3"
   "pyright"
   "ruff"
   "shellcheck"
   "shfmt"))

(setq inhibit-splash-screen t)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)

  ; Transparency (Emacs 30.1)
(set-frame-parameter nil 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))


  ;; Short answers only please

  (setq-default use-short-answers t)

  ;; Scratch buffer settings

  (setq initial-major-mode 'org-mode
        initial-scratch-message (concat "#+title: Emacs Writing Studio\n"
  				      "#+subtitle: Scratch Buffer\n\n"
  				      "The text in this buffer is not saved "
  				      "when exiting Emacs!\n\n"))

(use-package spacious-padding
  :custom
  (line-spacing 3)
  (spacious-padding-widths
   '(:internal-border-width 15
     :header-line-width 4
     :mode-line-width 4
     :tab-width 4
     :right-divider-width 1
     :scroll-bar-width 0
     :fringe-width 8))
  :config
  (spacious-padding-mode 1))

(defun my/kill-line-spacing ()
  "Zero buffer-local `line-spacing' in the current buffer.
Set to 0, not nil: a nil buffer value falls back to the frame's
`line-spacing' parameter, so nil would not reliably remove the leading."
  (setq-local line-spacing 0))

(defun my/tighten-popup-line-spacing ()
  "Zero `line-spacing' in the minibuffer and echo-area buffers.
\" *Minibuf-0*\" is included deliberately: multi-line echo output — a long
`message', the Meow keypad prompt — is shown there rather than in the
echo-area buffers, and that is the row whose descenders were being clipped."
  (dolist (buffer (list (get-buffer-create " *Echo Area 0*")
                        (get-buffer-create " *Echo Area 1*")
                        (get-buffer-create " *Minibuf-0*")
                        (and (minibufferp) (current-buffer))))
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (my/kill-line-spacing)))))

(add-hook 'minibuffer-setup-hook #'my/tighten-popup-line-spacing)
(add-hook 'emacs-startup-hook #'my/tighten-popup-line-spacing)

;; which-key builds its popup in a dedicated buffer and fits the side window
;; to it in whole rows; strip the leading there too.  This also covers the
;; Meow keypad popup, which renders through which-key.
(with-eval-after-load 'which-key
  (add-hook 'which-key-init-buffer-hook #'my/kill-line-spacing)
  (when-let ((buffer (get-buffer which-key-buffer-name)))
    (with-current-buffer buffer (my/kill-line-spacing))))

(use-package modus-themes
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  (modus-themes-to-toggle '(modus-operandi-tinted
                            modus-vivendi-tinted))
  :bind
  (("C-c w t t" . modus-themes-toggle)
   ("C-c w t m" . modus-themes-select)
   ("C-c w t s" . consult-theme)))

(load-theme 'modus-vivendi-tinted :no-confirm)

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package mixed-pitch
  :hook
  (org-mode . mixed-pitch-mode))

(setq split-width-threshold 120
      split-height-threshold nil)

(use-package balanced-windows
  :config
  (balanced-windows-mode))

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-sort-function 'vertico-sort-history-alpha))

(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package which-key
  :config
  (which-key-mode)
  :custom
  (which-key-max-description-length 40)
  (which-key-lighter nil)
  (which-key-sort-order 'which-key-description-order)
  ;; Size the popup with `fit-window-to-buffer' (real pixels) instead of the
  ;; imprecise line-count fit.  With the global 3px `line-spacing', the
  ;; line-count path makes the side window a row too short and clips the bottom
  ;; line — most visibly the Meow keypad's "Keypad:" prompt, which which-key
  ;; draws as the popup's prefix-title.
  (which-key-allow-imprecise-window-fit nil)
  :init
  (which-key-add-key-based-replacements
    "C-c w"   "Emacs Writing Studio"
    "C-c w b" "Bibliographic"
    "C-c w d" "Denote"
    "C-c w m" "Multimedia"
    "C-c w s" "Spelling and Grammar"
    "C-c w t" "Themes"
    "C-c w x" "Explore"
    "C-c e"   "Eglot"
    "C-c i"   "ai"
    "C-c k"   "Calendar"
    "C-c !"   "Flymake"
    "C-c TAB" "Python Imports"
    "C-c C-v" "Org Babel"
    "C-c \""  "Org Plot"))

;; (use-package devil
;;   :ensure t
;;   :demand t
;;   :vc (:url "https://github.com/fbrosda/devil"
;;        :branch "dev"
;;        :rev :newest)
;;   :custom
;;   (devil-exit-key ".")
;;   (devil-all-keys-repeatable t)
;;   (devil-highlight-repeatable t)
;;   (devil-repeatable-keys '(("%k p" "%k n" "%k b" "%k f" "%k a" "%k e")
;;                            ("%k m n" "%k m p")
;;                            ("%k m b" "%k m f" "%k m a" "%k m e")
;;                            ("%k m m f" "%k m m b" "%k m m a" "%k m m e"
;;                             "%k m m n" "%k m m p" "%k m m u" "%k m m d")))
;;   :bind
;;   ([remap describe-key] . devil-describe-key)
;;   :config
;;   (global-devil-mode))

(when (display-graphic-p)
  (context-menu-mode))

(use-package helpful
  :bind
  (("C-h f" . helpful-function)
   ("C-h x" . helpful-command)
   ("C-h k" . helpful-key)
   ("C-h v" . helpful-variable)))

(use-package text-mode
  :ensure nil
  :hook
  (text-mode . visual-line-mode)
  :init
  (delete-selection-mode t)
  :custom
  (sentence-end-double-space nil)
  (scroll-error-top-bottom t)
  (save-interprogram-paste-before-kill t))

(use-package flyspell
  :custom
  (ispell-program-name "hunspell")
  (ispell-dictionary ews-hunspell-dictionaries)
  (flyspell-mark-duplications-flag nil)
  (org-fold-core-style 'overlays)
  :config
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic ews-hunspell-dictionaries)
  :hook
  (text-mode . flyspell-mode)
  :bind
  (("C-c w s s" . ispell)
   ("C-;"       . flyspell-auto-correct-previous-word)))

(use-package org
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(450))
  (org-pretty-entities t)
  (org-use-sub-superscripts "{}")
  (org-id-link-to-org-use-id t)
  (org-fold-catch-invisible-edits 'show))

(use-package org-appear
  :hook
  (org-mode . org-appear-mode))

(use-package org-fragtog
  :after org
  :hook
  (org-mode . org-fragtog-mode)
  :custom
  (org-startup-with-latex-preview nil)
  (org-format-latex-options
   (plist-put org-format-latex-options :scale 2)
   (plist-put org-format-latex-options :foreground 'auto)
   (plist-put org-format-latex-options :background 'auto)))

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  :custom
  (org-modern-table nil)
  (org-modern-keyword nil)
  (org-modern-timestamp nil)
  (org-modern-priority nil)
  (org-modern-checkbox nil)
  (org-modern-tag nil)
  (org-modern-block-name nil)
  (org-modern-footnote nil)
  (org-modern-internal-target nil)
  (org-modern-radio-target nil)
  (org-modern-statistics nil)
  (org-modern-progress nil))

(defun my/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

- When the region is active, disable it.
- When a minibuffer is open but not focused, close it.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'my/keyboard-quit-dwim)

(setq custom-file null-device)

;;; init.el ends here
