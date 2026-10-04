;;; AI.el --- Minimal Claude and DeepSeek integration -*- lexical-binding: t; -*-

;; Copyright (C) 2025-2026 Paul James Harper <pjharper@pm.me>

;; Author: Paul James Harper <pjharper@pm.me>
;;
;; Part of the Emacs Writing Studio configuration.
;; Tangled from: Emacs.org
;;
;; A small, package-free interface to the Anthropic and DeepSeek APIs,
;; in the spirit of Rahul Juliato's emacs-solo-ai module
;; (https://github.com/LionyxML/emacs-solo). Sends the current region or a
;; typed prompt, streams the response into a buffer. API keys are read
;; from auth-source rather than hard-coded.
;;
;;; Code:

(require 'auth-source)
(require 'json)

(defgroup my/ai nil
  "Minimal AI assistant integration."
  :group 'external)

(defcustom my/ai-claude-model "claude-sonnet-4-6"
  "Claude model to use for `my/ai-ask-claude'."
  :type 'string
  :group 'my/ai)

(defcustom my/ai-deepseek-model "deepseek-chat"
  "DeepSeek model to use for `my/ai-ask-deepseek'."
  :type 'string
  :group 'my/ai)

(defun my/ai--auth-secret (host)
  "Look up the API key for HOST in auth-source."
  (if-let* ((found (car (auth-source-search :host host :require '(:secret)))))
      (let ((secret (plist-get found :secret)))
        (if (functionp secret) (funcall secret) secret))
    (user-error "No auth-source entry found for host %s" host)))

(defun my/ai--prompt-text ()
  "Return the active region, or prompt for a string."
  (if (use-region-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (read-string "Prompt: ")))

(defun my/ai--insert-response (buffer-name text)
  "Insert TEXT into BUFFER-NAME, creating and displaying it if needed."
  (with-current-buffer (get-buffer-create buffer-name)
    (unless (derived-mode-p 'markdown-mode) (markdown-mode))
    (goto-char (point-max))
    (unless (bobp) (insert "\n\n---\n\n"))
    (insert text)
    (display-buffer (current-buffer))))

(defun my/ai-ask-claude (prompt)
  "Send PROMPT (or the active region) to Claude and display the reply."
  (interactive (list (my/ai--prompt-text)))
  (let* ((api-key (my/ai--auth-secret "api.anthropic.com"))
         (url-request-method "POST")
         (url-request-extra-headers
          `(("content-type" . "application/json")
            ("x-api-key" . ,api-key)
            ("anthropic-version" . "2023-06-01")))
         (url-request-data
          (json-encode
           `((model . ,my/ai-claude-model)
             (max_tokens . 4096)
             (messages . [((role . "user") (content . ,prompt))])))))
    (url-retrieve
     "https://api.anthropic.com/v1/messages"
     (lambda (_status)
       (goto-char (point-min))
       (re-search-forward "\n\n" nil t)
       (let* ((json-object-type 'plist)
              (response (json-read))
              (content (plist-get response :content))
              (text (mapconcat (lambda (block) (or (plist-get block :text) ""))
                               (append content nil) "")))
         (my/ai--insert-response "*Claude*" text))))))

(defun my/ai-ask-deepseek (prompt)
  "Send PROMPT (or the active region) to DeepSeek and display the reply."
  (interactive (list (my/ai--prompt-text)))
  (let* ((api-key (my/ai--auth-secret "api.deepseek.com"))
         (url-request-method "POST")
         (url-request-extra-headers
          `(("content-type" . "application/json")
            ("authorization" . ,(concat "Bearer " api-key))))
         (url-request-data
          (json-encode
           `((model . ,my/ai-deepseek-model)
             (messages . [((role . "user") (content . ,prompt))])))))
    (url-retrieve
     "https://api.deepseek.com/chat/completions"
     (lambda (_status)
       (goto-char (point-min))
       (re-search-forward "\n\n" nil t)
       (let* ((json-object-type 'plist)
              (response (json-read))
              (choices (plist-get response :choices))
              (text (plist-get (plist-get (aref choices 0) :message) :content)))
         (my/ai--insert-response "*DeepSeek*" text))))))

(keymap-global-set "C-c i c" #'my/ai-ask-claude)
(keymap-global-set "C-c i d" #'my/ai-ask-deepseek)

(provide 'AI)
;;; AI.el ends here
