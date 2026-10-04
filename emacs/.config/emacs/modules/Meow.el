;;; Meow.el --- Modal editing with Meow (QWERTY, SPC leader) -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Paul James Harper <pjharper@pm.me>

;; Author: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; Modal editing with Meow (https://github.com/meow-edit/meow) using the
;; standard QWERTY layout and SPC as the leader key.  Meow's keypad routes
;; the leader through the existing C-c / C-x bindings, so which-key shows
;; the same +Prefix labels defined in init.el.  Meow is the only modal
;; layer; the Devil Mode block in init.el is commented out.
;;
;;; Code:

(defun my/meow-setup ()
  "Meow keybindings for the QWERTY layout, with SPC as the leader."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC (0-9) as digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :ensure t
  :demand t
  :custom
  (meow-use-clipboard t)
  (meow-keypad-describe-delay 0.5)
  (meow-expand-hint-remove-delay 2.0)
  :config
  (my/meow-setup)
  (meow-global-mode 1))

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-x r"   "Rectangle/Register"
    "C-x n"   "Narrow"
    "C-x w"   "Window/Highlight"
    "C-x t"   "Tab"
    "C-x 8"   "Insert Char"
    "C-x RET" "Encoding"
    "C-x p"   "Project"
    "C-x v"   "Version Control"))

(defvar my/meow-keypad-prefix-titles
  '(("w"   . "Emacs Writing Studio")
    ("w b" . "Bibliography")
    ("w d" . "Denote")
    ("w m" . "Multimedia")
    ("w s" . "Spelling")
    ("w t" . "Themes")
    ("w x" . "Explore")
    ("i"   . "ai")
    ("k"   . "Calendar")
    ("t"   . "Terminal"))
  "Alist of `C-c'-relative key sequences to the title shown in the Meow
keypad popup.  Each key names a prefix keymap reachable from `C-c'.")

(defun my/meow-keypad-title-symbol (name)
  "Return an uninterned command symbol called NAME, for keypad display only."
  (let ((sym (make-symbol name)))
    (fset sym #'ignore)
    sym))

(defun my/meow-keypad-get-title (def)
  "Give known `C-c' prefix keymaps a friendly title in the keypad popup.
Fall back to `meow-keypad-get-title' for everything else."
  (or (and (keymapp def)
           (seq-some
            (lambda (cell)
              (and (eq def (lookup-key mode-specific-map (kbd (car cell))))
                   (my/meow-keypad-title-symbol (cdr cell))))
            my/meow-keypad-prefix-titles))
      (meow-keypad-get-title def)))

(with-eval-after-load 'meow
  (setq meow-keypad-get-title-function #'my/meow-keypad-get-title))

(provide 'Meow)
;;; Meow.el ends here
