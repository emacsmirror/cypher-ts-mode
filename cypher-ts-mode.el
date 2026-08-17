;;; cypher-ts-mode.el --- Cypher editing mode -*- lexical-binding: t; -*-

;;; Copyright © 2026 Julian Flake <flake@uni-koblenz.de>

;; Author: Julian Flake <flake@uni-koblenz.de>
;; Maintainer: Julian Flake <flake@uni-koblenz.de>
;; Version: 0.0.2
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages files cypher graph database treesitter
;; URL: https://codeberg.org/nutcase/cypher-ts-mode

;; This file is *NOT* part of GNU Emacs.

;; This package is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this package.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A major mode for editing cypher files, powered by a tree-sitter parser
;; provided by https://github.com/taekwombo/tree-sitter-cypher
;;
;; Install the needed tree-sitter grammar by running
;; @code{cypher-ts-mode-install-grammar}.  Grammar downloader inspired by and
;; adopted from https://github.com/leon-barrett/just-ts-mode.el

;;; Code:

(require 'prog-mode)
(require 'treesit)

;; Keywords taken from Cypher Query Language Reference, Version 9:
;; https://github.com/opencypher/openCypher/blob/main/cip/0.baseline/openCypher9.pdf

(defconst cypher-ts-mode--keywords-clauses
  '("create" "delete" "detach" "exists" "match" "merge" "optional"
    "remove" "return" "set" "union" "unwind" "with"))

(defconst cypher-ts-mode--keywords-subclauses
  '("limit" "order" "skip" "where"))

(defconst cypher-ts-mode--keywords-modifiers
  '("asc" "ascending" "by" "desc" "descending" "on"))

(defconst cypher-ts-mode--keywords-expressions
  '("all" "case" "else" "end" "then" "when"))

(defconst cypher-ts-mode--keywords-literals
  '("false" "null" "true"))

(defconst cypher-ts-mode--keywords-operators
  '("and" "as" "contains" "distinct" "ends"
    "in" "is" "not" "or" "starts" "xor"))

(defconst cypher-ts-mode--keywords-reserved
  '("add" "constraint" "do" "drop" "for" "mandatory"
    "of" "require" "scalar" "unique"))

(defun cypher-ts-mode-setup ()
  "Set up treesit for \"cypher-ts-mode\"."
  (setq-local comment-start "//")
  (setq-local comment-end "")
  (setq-local treesit-font-lock-feature-list
	      '((comment)
		(keyword literal function)
		(type variable property string)))
  (setq-local
   treesit-font-lock-settings
   (treesit-font-lock-rules
    :default-language 'cypher
    :feature 'comment
    '((comment) @font-lock-comment-face)
    :feature 'keyword
    `([,@cypher-ts-mode--keywords-clauses] @font-lock-keyword-face
      [,@cypher-ts-mode--keywords-subclauses] @font-lock-keyword-face
      [,@cypher-ts-mode--keywords-modifiers] @font-lock-keyword-face
      [,@cypher-ts-mode--keywords-expressions] @font-lock-keyword-face
      [,@cypher-ts-mode--keywords-operators] @font-lock-keyword-face
      ;; TODO Including any of the reserved keywords lets font lock fail
      ;; [,@cypher-ts-mode--keywords-reserved] @font-lock-keyword-face
      )
    :feature 'type
    :override t
    `((label_name) @font-lock-type-face
      (rel_type_name) @font-lock-type-face)
    :feature 'variable
    '((variable) @font-lock-variable-name-face)
    :feature 'property
    '((property_key_name) @font-lock-builtin-face)
    :feature 'function
    '((function_name) @font-lock-function-name-face)
    :feature 'literal
    `([,@cypher-ts-mode--keywords-literals] @font-lock-constant-face)
    :feature 'string
    `((string_literal) @font-lock-string-face)))
  (setq-local
   treesit-simple-indent-rules
   '((cypher
      ((parent-is "cypher") column-0 0)
      ((parent-is "pattern") parent 0)
      ((parent-is "expression") parent 0)
      ((parent-is "projection_items") parent 0)
      (catch-all column-0 0))))
  (treesit-major-mode-setup))

;;;###autoload
(define-derived-mode cypher-ts-mode prog-mode "Cypher[ts]"
  "Major mode for editing Cypher files using treesitter."

  (unless (treesit-ready-p 'cypher)
    (error "Tree-Sitter for `cypher' isn't available"))
  (treesit-parser-create 'cypher)
  (cypher-ts-mode-setup))

;; Language grammar installation

(defconst cypher-ts-mode-treesit-language-source
  '(cypher "https://github.com/taekwombo/tree-sitter-cypher" "master" "src")
  "The language source entry for the associated Cypher language parser.")

(defun cypher-ts-mode-install-grammar ()
  "Install the language grammar for `cypher-ts-mode'.

The function removes existing entries for the Cypher language in
`treesit-language-source-alist' and adds the entry stored in
`cypher-ts-mode-treesit-language-source'."
  (interactive)
  ;; Remove existing entries
  (setq treesit-language-source-alist
        (assq-delete-all 'cypher treesit-language-source-alist))
  ;; Add the correct entry
  (add-to-list 'treesit-language-source-alist
               cypher-ts-mode-treesit-language-source)
  ;; Install the grammar
  (treesit-install-language-grammar 'cypher))


(provide 'cypher-ts-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.cypher\\'" . cypher-ts-mode))

;;; cypher-ts-mode.el ends here
