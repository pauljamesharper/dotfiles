;;; Inspiration.el --- Reading, listening and watching media -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025 Peter Prevos
;; Additions Copyright (C) 2025 Paul James Harper <pjharper@pm.me>

;; Original Author: Peter Prevos <peter@prevos.net>
;; Maintainer: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; This module configures Emacs as a media consumption and bibliography
;; management environment. It covers e-books (Nov), PDF and DjVu viewing
;; (Doc-View), audio/video (EMMS), RSS feeds (Elfeed), bibliography
;; management (BibTeX, Biblio, Citar), and web capture (org-web-tools).
;;
;;; Code:

;; Doc-View for PDF and other document formats

(use-package doc-view
  :custom
  (doc-view-resolution 300)
  ;; Not under /tmp: the LibreOffice Flatpak can't see the host's /tmp
  (doc-view-cache-directory (expand-file-name "doc-view" user-emacs-directory))
  (large-file-warning-threshold (* 50 (expt 2 20))))

;; Read ePub files with Nov.el

(use-package nov
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

;; Open files with external applications

(use-package openwith
  :config
  (openwith-mode t)
  :custom
  (openwith-associations nil))

;; BibTeX settings

(use-package bibtex
  :custom
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file"     "Relative or absolute path to attachments" "" )))
  (bibtex-align-at-equal-sign t)
  :config
  (ews-bibtex-register)
  :bind
  (("C-c w b r" . ews-bibtex-register)))

;; Biblio package for adding BibTeX records

(use-package biblio
  :bind
  (("C-c w b b" . ews-bibtex-biblio-lookup)))

;; Citar to access and open bibliography entries

(use-package citar
  :defer t
  :custom
  (citar-bibliography ews-bibtex-files)
  :bind
  (("C-c w b o" . citar-open)))

;; Read RSS feeds with Elfeed

(use-package elfeed
  :custom
  (elfeed-db-directory
   (expand-file-name "elfeed" user-emacs-directory))
  (elfeed-show-entry-switch 'display-buffer)
  :bind
  (("C-c w e" . elfeed)))

;; Configure Elfeed with an Org mode file

(use-package elfeed-org
  :config
  (elfeed-org)
  :custom
  (rmh-elfeed-org-files
   (list (concat (file-name-as-directory (getenv "HOME"))
		 "ProtonDrive/Documents/elfeed.org"))))

;; Easy insertion of web links

(use-package org-web-tools
  :bind
  (("C-c w w" . org-web-tools-insert-link-for-url)))

;; Emacs Multimedia System

(use-package emms
  :config
  (require 'emms-setup)
  (require 'emms-mpris)
  (emms-all)
  (emms-default-players)
  (emms-mpris-enable)
  :custom
  (emms-browser-covers #'emms-browser-cache-thumbnail-async)
  :bind
  (("C-c w m b" . emms-browser)
   ("C-c w m e" . emms)
   ("C-c w m p" . emms-play-playlist)
   ("<XF86AudioPrev>" . emms-previous)
   ("<XF86AudioNext>" . emms-next)
   ("<XF86AudioPlay>" . emms-pause)))

(provide 'Inspiration)
;;; Inspiration.el ends here
