;;; Programming.el --- Programming, LSP, and tree-sitter support -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026 Paul James Harper <pjharper@pm.me>

;; Author: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; This module configures Emacs as a programming environment, built on
;; Eglot (LSP client), Flymake (diagnostics), and tree-sitter major modes.
;; Several conventions are adapted from Rahul Juliato's Emacs Solo
;; configuration (https://github.com/LionyxML/emacs-solo), in particular
;; the Eglot/Flymake setup and overall module structure. Python support is
;; original to this module, targeting Debian 13 (Trixie) with Python 3.13.
;;
;;; Code:

(use-package treesit
  :ensure nil
  :custom
  (treesit-font-lock-level 4)
  (treesit-auto-install-grammar 'always))

(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref t)
  :init
  (defun my/eglot-setup ()
    "Enable Eglot for `prog-mode' buffers, except Emacs Lisp and Lisp."
    (unless (memq major-mode '(emacs-lisp-mode lisp-mode))
      (eglot-ensure)))

  (add-hook 'prog-mode-hook #'my/eglot-setup)
  :bind (:map eglot-mode-map
              ("C-c e a" . eglot-code-actions)
              ("C-c e o" . eglot-code-action-organize-imports)
              ("C-c e r" . eglot-rename)
              ("C-c e i" . eglot-inlay-hints-mode)
              ("C-c e f" . eglot-format)))

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-margin-indicators-string
   '((error "!" compilation-error)
     (warning "?" compilation-warning)
     (note "i" compilation-info)))
  :bind (:map flymake-mode-map
              ("C-c ! n" . flymake-goto-next-error)
              ("C-c ! p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))

(use-package elec-pair
  :ensure nil
  :hook (prog-mode . electric-pair-local-mode))

(use-package paren
  :ensure nil
  :hook (after-init . show-paren-mode)
  :custom
  (show-paren-delay 0)
  (show-paren-style 'mixed)
  (show-paren-context-when-offscreen t))

(use-package compile
  :ensure nil
  :custom
  (compilation-always-kill t)
  (compilation-scroll-output t)
  (ansi-color-for-compilation-mode t)
  :config
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

(use-package project
  :ensure nil
  :custom
  (project-vc-extra-root-markers
   '("pyproject.toml" "setup.py" "requirements.txt" "Cargo.toml"
     "go.mod" "*.tf" "ansible.cfg")))

(when (executable-find "rg")
  (setq xref-search-program 'ripgrep)
  (setq grep-command "rg -nS --no-heading ")
  (setq grep-find-template "rg <C> --null -nH -e <R> <D>"))

(use-package vc
  :ensure nil
  :custom
  (vc-git-diff-switches '("--patch-with-stat" "--histogram"))
  (vc-git-log-switches '("--stat"))
  :config
  (defun my/vc-browse-remote (&optional current-line)
    "Open the repository's remote URL in the browser.
With prefix arg CURRENT-LINE, point to the current file and line."
    (interactive "P")
    (let* ((remote-url (string-trim (vc-git--run-command-string nil "config" "--get" "remote.origin.url")))
           (branch (string-trim (vc-git--run-command-string nil "rev-parse" "--abbrev-ref" "HEAD")))
           (file (string-trim (file-relative-name (buffer-file-name) (vc-root-dir))))
           (line (line-number-at-pos)))
      (if (and remote-url
               (string-match "\\(?:git@\\|https://\\)\\([^:/]+\\)[:/]\\(.+?\\)\\(?:\\.git\\)?$" remote-url))
          (let ((host (replace-regexp-in-string "^git@" "" (match-string 1 remote-url)))
                (path (match-string 2 remote-url)))
            (browse-url
             (if current-line
                 (format "https://%s/%s/blob/%s/%s#L%d" host path branch file line)
               (format "https://%s/%s" host path))))
        (message "Could not determine repository remote URL"))))
  (define-key vc-prefix-map (kbd "B") #'my/vc-browse-remote))

(use-package bash-ts-mode
  :ensure nil
  :mode "\\.\\(sh\\|bash\\)\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(bash "https://github.com/tree-sitter/tree-sitter-bash" "master" "src")))

(use-package yaml-ts-mode
  :ensure nil
  :mode "\\.ya?ml\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml" "master" "src")))

(use-package toml-ts-mode
  :ensure nil
  :mode "\\.toml\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(toml "https://github.com/ikatyang/tree-sitter-toml" "master" "src")))

(use-package json-ts-mode
  :ensure nil
  :mode "\\.json\\'")

(use-package dockerfile-ts-mode
  :ensure nil
  :mode "\\Dockerfile.*\\'"
  :config
  (add-to-list 'treesit-language-source-alist
               '(dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile" "main" "src")))

(use-package python
  :ensure nil
  :mode ("\\.py\\'" . python-ts-mode)
  :custom
  (python-indent-offset 4)
  (python-shell-interpreter "python3")
  :config
  (add-to-list 'treesit-language-source-alist
               '(python "https://github.com/tree-sitter/tree-sitter-python" "master" "src"))

  ;; Locate a project-local virtual environment (./.venv or ./venv) and
  ;; point Eglot/Eshell/M-x compile at its interpreter, falling back to
  ;; whatever python3 is on PATH.
  (defun my/python-find-venv-executable (name)
    "Find executable NAME, preferring a project-local virtualenv."
    (or (when-let* ((root (or (locate-dominating-file default-directory ".venv")
                               (locate-dominating-file default-directory "venv"))))
          (let ((candidate (expand-file-name
                             (concat (if (file-directory-p (expand-file-name ".venv" root))
                                         ".venv/bin/" "venv/bin/")
                                     name)
                             root)))
            (when (file-executable-p candidate) candidate)))
        (executable-find name)))

  (defun my/python-setup ()
    "Use a project-local virtualenv's interpreter when one exists."
    (when-let* ((python (my/python-find-venv-executable "python")))
      (setq-local python-shell-interpreter python)))

  (add-hook 'python-ts-mode-hook #'my/python-setup))

;; Eglot: pyright for Python, falling back gracefully if not installed
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) "pyright-langserver" "--stdio")))

;; Flymake: add ruff as a second backend alongside Eglot's diagnostics,
;; so linting works even before/without a language server connection.
(use-package flymake-ruff
  :hook (python-ts-mode . (lambda ()
                            (when (executable-find "ruff")
                              (flymake-ruff-load)))))

(provide 'Programming)
;;; Programming.el ends here
