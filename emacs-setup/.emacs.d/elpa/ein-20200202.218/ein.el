;;; ein.el --- jupyter notebook client

;; Copyright (C) 2012-2019 The Authors of the Emacs IPython Notebook (EIN)

;; Authors:  dickmao <github id: dickmao>
;;           John Miller <millejoh at millejoh.com>
;;           Takafumi Arakaki <aka.tkf at gmail.com>
;; URL: https://github.com/dickmao/emacs-ipython-notebook
;; Keywords: jupyter, literate programming, reproducible research

;; This file is NOT part of GNU Emacs.

;; ein.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs IPython Notebook (EIN) lets you run Jupyter (formerly IPython)
;; notebooks within Emacs.  It channels all the power of Emacs without the
;; idiosyncrasies of in-browser editing.
;;
;; EIN is not tested on Doom or Spacemacs.  There are known issues with both.
;;
;; Org_ users please find ob-ein_, a jupyter Babel_ backend.
;;
;; EIN was originally written by `[tkf]`_.  A jupyter Babel_ backend was first
;; introduced by `[gregsexton]`_.
;;

;;; Code:

(eval-when-compile (require 'cl))
(when (boundp 'mouse-buffer-menu-mode-groups)
  (add-to-list 'mouse-buffer-menu-mode-groups
               '("^ein:" . "ein")))

(provide 'ein)

;;; ein.el ends here
