;; Copyright (C) 2006 Free Software Foundation, Inc.
;; This file is (not yet) part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;; ======================================================================
;; pydb (Python extended debugger) functions

(require 'gud)

;;; History of argument lists passed to pydb.
(defvar gud-pydb-history nil)

(defun gud-pydb-massage-args (file args)
  args)

;; Last group is for return value, e.g. "> test.py(2)foo()->None"
;; Either file or function name may be omitted: "> <string>(0)?()"
(defvar gud-pydb-marker-regexp
  "^> \\([-a-zA-Z0-9_/.]*\\|<string>\\)(\\([0-9]+\\))\\([a-zA-Z0-9_]*\\|\\?\\)()\\(->[^\n]*\\)?\n")
(defvar gud-pydb-marker-regexp-file-group 1)
(defvar gud-pydb-marker-regexp-line-group 2)
(defvar gud-pydb-marker-regexp-fnname-group 3)

(defvar gud-pydb-marker-regexp-start "^> ")

;; There's no guarantee that Emacs will hand the filter the entire
;; marker at once; it could be broken up across several strings.  We
;; might even receive a big chunk with several markers in it.  If we
;; receive a chunk of text which looks like it might contain the
;; beginning of a marker, we save it here between calls to the
;; filter.
(defun gud-pydb-marker-filter (string)
  (setq gud-marker-acc (concat gud-marker-acc string))
  (let ((output ""))

    ;; Process all the complete markers in this chunk.
    (while (string-match gud-pydb-marker-regexp gud-marker-acc)
      (setq

       ;; Extract the frame position from the marker.
       gud-last-frame
       (let ((file (match-string gud-pydb-marker-regexp-file-group
				 gud-marker-acc))
	     (line (string-to-int
		    (match-string gud-pydb-marker-regexp-line-group
				  gud-marker-acc))))
	 (if (string-equal file "<string>")
	     gud-last-frame
	   (cons file line)))

       ;; Output everything instead of the below
       output (concat output (substring gud-marker-acc 0 (match-end 0)))
;;        ;; Append any text before the marker to the output we're going
;;        ;; to return - we don't include the marker in this text.
;;        output (concat output
;; 		      (substring gud-marker-acc 0 (match-beginning 0)))

       ;; Set the accumulator to the remaining text.
       gud-marker-acc (substring gud-marker-acc (match-end 0))))

    ;; Does the remaining text look like it might end with the
    ;; beginning of another marker?  If it does, then keep it in
    ;; gud-marker-acc until we receive the rest of it.  Since we
    ;; know the full marker regexp above failed, it's pretty simple to
    ;; test for marker starts.
    (if (string-match gud-pydb-marker-regexp-start gud-marker-acc)
	(progn
	  ;; Everything before the potential marker start can be output.
	  (setq output (concat output (substring gud-marker-acc
						 0 (match-beginning 0))))

	  ;; Everything after, we save, to combine with later input.
	  (setq gud-marker-acc
		(substring gud-marker-acc (match-beginning 0))))

      (setq output (concat output gud-marker-acc)
	    gud-marker-acc ""))

    output))

(defun gud-pydb-find-file (f)
  (find-file-noselect f))

(defcustom gud-pydb-command-name "pydb"
  "File name for executing the Python debugger.
This should be an executable on your path, or an absolute file name."
  :type 'string
  :group 'gud)

;;;###autoload
(defun pydb (command-line)
  "Run pydb on program FILE in buffer `*gud-FILE*'.
The directory containing FILE becomes the initial working directory
and source-file directory for your debugger."
  (interactive
   (list (gud-query-cmdline 'pydb)))

  (gud-common-init command-line 'gud-pydb-massage-args
		   'gud-pydb-marker-filter 'gud-pydb-find-file)
  (set (make-local-variable 'gud-minor-mode) 'pydb)

  (gud-def gud-break  "break %l"     "\C-b" "Set breakpoint at current line.")
  (gud-def gud-tbreak "tbreak %f:%l" "\C-t" "Set temporary breakpoint at current line.")
  (gud-def gud-remove "clear %f:%l"  "\C-d" "Remove breakpoint at current line")
  (gud-def gud-step   "step %p"      "\C-s" "Step one source line with display.")
  (gud-def gud-next   "next %p"      "\C-n" "Step one line (skip functions).")
  (gud-def gud-cont   "cont"         "\C-r" "Continue with display.")
  (gud-def gud-finish "finish"       "\C-f" "Finish executing current function.")
  (gud-def gud-up     "up %p"        "<" "Up N stack frames (numeric arg).")
  (gud-def gud-down   "down %p"      ">" "Down N stack frames (numeric arg).")
  (gud-def gud-print  "p %e"         "\C-p" "Evaluate Python expression at point.")
  ;; Is this right?
  (gud-def gud-statement "! %e"	     "\C-e" "Execute Python statement at point.")

  (local-set-key [menu-bar debug finish] '("Finish Function" . gud-finish))
  (local-set-key [menu-bar debug up] '("Up Stack" . gud-up))
  (local-set-key [menu-bar debug down] '("Down Stack" . gud-down))
  ;; (setq comint-prompt-regexp "^(.*pydb[+]?) *")
  (setq comint-prompt-regexp "^(Pydb) *")
  (setq paragraph-start comint-prompt-regexp)
  (run-hooks 'pydb-mode-hook))