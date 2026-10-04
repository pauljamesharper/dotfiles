;;; Terminals.el --- Terminal emulation with Ghostel -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Paul James Harper <pjharper@pm.me>

;; Author: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; A single in-Emacs terminal, Ghostel (https://github.com/dakra/ghostel),
;; on Ghostty's libghostty-vt engine via a pre-built native module. Chosen
;; over vterm (needs a CMake toolchain to build on Fedora Atomic) and eat
;; (pure Elisp, slower under load). Separate from Programming.el on purpose:
;; the terminal serves Git, pandoc, and publishing as much as code.
;;
;;; Code:

(use-package ghostel
  :ensure t
  :bind (("C-c t t" . ghostel)
         ("C-c t p" . ghostel-project)
         ("C-c t b" . ghostel-list-buffers)
         :map project-prefix-map
         ("t" . ghostel-project))
  :custom
  ;; The default 5 MiB of scrollback fills fast with build/test output.
  (ghostel-max-scrollback (* 10 1024 1024))
  ;; Inject bash/zsh/fish integration — OSC 7 working-directory tracking
  ;; (kept in sync with `default-directory') and OSC 133 prompt markers —
  ;; both locally and on TRAMP hosts.  Remote integration also installs the
  ;; xterm-ghostty terminfo entry on the host on first connection.
  (ghostel-shell-integration t)
  (ghostel-tramp-shell-integration t)
  ;; `C-x C-q' drops into a frozen, read-only buffer for stable selection.
  (ghostel-readonly-default-mode 'copy))

(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(ghostel-mode . insert)))

(add-to-list 'display-buffer-alist
             '("\\`\\*ghostel"
               (display-buffer-reuse-mode-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.33)
               (dedicated . t)))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements "C-c t" "Terminal"))

(provide 'Terminals)
;;; Terminals.el ends here
