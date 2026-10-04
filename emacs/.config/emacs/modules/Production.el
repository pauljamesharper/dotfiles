;;; Production.el --- Writing and editing with Org mode -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025 Peter Prevos
;; Additions Copyright (C) 2025 Paul James Harper <pjharper@pm.me>

;; Original Author: Peter Prevos <peter@prevos.net>
;; Maintainer: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; This module configures Emacs as a writing environment. It covers
;; Org mode writing helpers (notes drawers, screenshots, word counts),
;; distraction-free writing (Olivetti), citation export, spell-checking
;; aids, prose quality tools (Writegood), titlecasing, abbreviations,
;; and alternative writing formats (Fountain, Markdown).
;;
;;; Code:

(use-package org
  :bind
  (:map org-mode-map
        ("C-c w n" . ews-org-insert-notes-drawer)
        ("C-c w p" . ews-org-insert-screenshot)
        ("C-c w c" . ews-org-count-words)))

(use-package olivetti
  :demand t
  :bind
  (("C-c w o" . ews-olivetti)))

(use-package vundo
  :bind
  (("C-M-/" . vundo)))

(require 'oc-natbib)
(require 'oc-csl)

(setq org-cite-global-bibliography ews-bibtex-files
      org-cite-insert-processor 'citar
      org-cite-follow-processor 'citar
      org-cite-activate-processor 'citar
      ;; CSL styles (e.g. apa6.csl) live alongside the .bib file
      org-cite-csl-styles-dir ews-bibtex-directory)

;; Online dictionary lookup

(use-package dictionary
  :custom
  (dictionary-server "dict.org")
  :bind
  (("C-c w s d" . dictionary-lookup-definition)))

;; Writegood-Mode: weasel words, passive voice, repeated words

(use-package writegood-mode
  :bind
  (("C-c w s r" . writegood-reading-ease))
  :hook
  (text-mode . writegood-mode))

;; Title case conversion

(use-package titlecase
  :bind
  (("C-c w s t" . titlecase-dwim)
   ("C-c w s c" . ews-org-headings-titlecase)))

;; Abbreviation mode

(add-hook 'text-mode-hook 'abbrev-mode)

;; Lorem Ipsum placeholder text

(use-package lorem-ipsum
  :custom
  (lorem-ipsum-list-bullet "- ")
  :init
  (setq lorem-ipsum-sentence-separator
        (if sentence-end-double-space "  " " "))
  :bind
  (("C-c w s i" . lorem-ipsum-insert-paragraphs)))

(use-package ediff
  :ensure nil
  :custom
  (ediff-keep-variants nil)
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-window-setup-function 'ediff-setup-windows-plain))

;; Fountain mode for screenwriting

(use-package fountain-mode)

;; Markdown mode

(use-package markdown-mode)

(provide 'Production)
;;; Production.el ends here
