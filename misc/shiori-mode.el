;;; Shiori-mode.el --- Shiori code highlighting for Emacs

;; Copyright (C) 2008 Haeleth

;; Author: Peter Jolly
;; Maintainer: Peter Jolly <haeleth@haeleth.net>
;; Keywords: languages, Shiori, ONScripter, NScripter

;; Bugs:
;;
;;   ~~i~ means literal "~i" followed by an open tag block, but is
;;   here parsed as unmatched ~ followed by tag block ~i~.
;;
;;   ~i~~~ means tag block ~i~ followed by literal "~", but is here
;;   parsed as tag block ~i~ followed by two unmatched ~s.

(defvar shiori-mode-hook nil)
(defvar shiori-mode-map
  (let ((shiori-mode-map (make-sparse-keymap)))
    shiori-mode-map)
  "Keymap for Shiori major mode")

(defvar shiori-font-lock-keywords
  (list
   '("\\^.*?\\^"          . font-lock-string-face)        ; ^strings^
   '("~[^~]+~"            . font-lock-constant-face)      ; ~tags~
   '("~~"                 . font-lock-keyword-face)       ; literal ~
   '("~"                  . font-lock-warning-face)       ; unpaired ~
   '("[$%?]\\w+"          . font-lock-variable-name-face) ; variables
   '("[*]\\w+"            . font-lock-constant-face)      ; labels
   '("#[@/\\_^`!#]"       . font-lock-keyword-face)       ; #@, #\, etc
   '("![swd][0-9]+"       . font-lock-constant-face)      ; !s, !w, !d
   '("!sd"                . font-lock-constant-face)      ; !sd
   '("#[0-9a-f]\\{6\\}"   . font-lock-constant-face)      ; #nnnnnn
   '("^[ \t]*\\([`^]\\)"  1 font-lock-builtin-face)       ; ^text
   '("[\\@_]"             . font-lock-builtin-face)       ; \, @, _
   '("/$"                 . font-lock-builtin-face)       ; / at eol
   ))

(defvar shiori-syntactic-keywords
  (list '("^\\(?:[^^\"]\\|\\^.*?\\^\\|\".*?\"\\)*?\\(;\\)"
          1 "<"))) ; semicolon only begins comment outside text

(defvar shiori-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?_  "w" table)
    (modify-syntax-entry ?\n ">" table)
    table))

(defun shiori-mode ()
  "Major mode for editing Shiori files.
Also has some (imperfect) support for ONScripter-En and NScripter
proper."
  (interactive)
  (kill-all-local-variables)
  (set-syntax-table shiori-mode-syntax-table)
  (use-local-map shiori-mode-map)
  (set (make-local-variable 'font-lock-defaults)
       '(shiori-font-lock-keywords nil t nil nil
	    (font-lock-syntactic-keywords . shiori-syntactic-keywords)))
  (setq major-mode 'shiori-mode)
  (setq mode-name "Shiori")
  (run-hooks 'shiori-mode-hook))

(provide 'shiori-mode)

(defun ispell-shiori-text ()
  "Check Shiori text in the current buffer for spelling errors.
Checks all strings and single-byte display text, with the
exception of single-word strings containing numbers or
backslashes (as these are probably filenames)."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((working t)
	  (ispell-silently-savep t))
      (while 
	  (and working
	       (posix-search-forward "\\([\"^]\\).+?\\1\\|^[ \t]*\\^.*$\\|;.*$"
				     nil t))
	(unless (or
	    (string-match "^\\([\"^]\\)[^ ]*[0-9\\][^ ]*\\1$" (match-string 0))
	    (string-match "^;;?[a-z0-9_]+ " (match-string 0)))
	  (setq working (ispell-region (match-beginning 0) (match-end 0))))))))
