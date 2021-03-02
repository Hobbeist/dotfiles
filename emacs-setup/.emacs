;;============================================================================================================================
;; EMACS config file
;; This is taken from here: https://github.com/TimoLassmann/dot-files/blob/616d07fc321be1968837030819353f116341cc7b/config.org
;;============================================================================================================================

;;;;To Speed things up
(setq gc-cons-threshold 16777216)
(setq gc-cons-percentage 0.6)
(setq  message-log-max 16384)

;;;; Package Manager
(require 'package)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(setq package-archives '(("org" . "https://orgmode.org/elpa/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa"     . "https://melpa.org/packages/")))
(package-initialize)

;;;; Making sure that use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq use-package-always-ensure t)
(setq use-package-verbose t)

;;;; Init file support
(require 'cl-lib)

(require 'cl)
(use-package cl-lib
:ensure t
)
     (use-package dash
       
       :config (eval-after-load "dash" '(dash-enable-font-lock)))

     (use-package s
:ensure t
       )

     (use-package f
:ensure t
)

;;;; Trace for obsolete packages
(defun debug-on-load-obsolete (filename)
  (when (equal (car (last (split-string filename "[/\\]") 2))
               "obsolete")
    (debug)))
(add-to-list 'after-load-functions #'debug-on-load-obsolete)

;;;; Whoami
(setq user-full-name "Sebastian Rauschert"
      user-mail-address "sebastian.rauschert@telethonkids.org.au")

;;;; Emacs directory
(defconst sr/emacs-directory (concat (getenv "HOME") "/.emacs.d/"))
(defun sr/emacs-subdirectory (d) (expand-file-name d sr/emacs-directory))

(message "%s" (sr/emacs-subdirectory "elisp"))
(add-to-list 'load-path (sr/emacs-subdirectory "elisp"))


;;;; Set autosave directory
(setq backup-directory-alist '(("." . "~/.emacs.d/tmp/emacs_backups")))



;; Basic looks
;;;; Remove startup screen
(setq inhibit-startup-message t)

;;;; Remove bars etc
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(mouse-wheel-mode -1)

;;;; Disable bell
(setq ring-bell-function 'ignore)

;;;; UTF-8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;;; Diminish
(use-package diminish 
   
  :demand t)

;;;; Turn off auto-fill mode
(setq auto-fill-mode -1)
(setq-default fill-column 99999)
(setq fill-column 99999)

;;;; Undo/redo
(use-package undo-tree
  
  :diminish
  :init
  (global-undo-tree-mode 1)
  :config
  (defalias 'redo 'undo-tree-redo)
  :bind (("C-z" . undo)     ; Zap to character isn't helpful
         ("C-S-z" . redo)))

;;;; Killing the current buffer
(defun sr/kill-current-buffer ()
  "Kill the current buffer without prompting."
  (interactive)
  (kill-buffer (current-buffer)))
(global-set-key (kbd "C-x k") 'sr/kill-current-buffer)


;;;; Follow windows split
(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 2") 'split-and-follow-horizontally)

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))
(global-set-key (kbd "C-x 3") 'split-and-follow-vertically)


;;;; Tabs
(setq-default indent-tabs-mode nil)
(setq tab-width 4)

;;;; Location of mactex
(setenv "PATH" (concat "/Library/TeX/texbin" ":" (getenv "PATH")))


;;;; Dired setting
(put 'dired-find-alternate-file 'disabled nil)
(setq-default dired-listing-switches "-alh")

;;;; Path
(setq temporary-file-directory "/tmp")


;;;; Modernizing emacs
(setq gnutls-min-prime-bits 4096)


;; eshell
(use-package eshell
  :init
  (setq ;; eshell-buffer-shorthand t ...  Can't see Bug#19391
   eshell-scroll-to-bottom-on-input 'all
   eshell-error-if-no-glob t
   eshell-hist-ignoredups t
   eshell-save-history-on-exit t
   eshell-prefer-lisp-functions nil
   eshell-destroy-buffer-when-process-dies t))

(use-package eshell
  :init
  (add-hook 'eshell-mode-hook
            (lambda ()
              (add-to-list 'eshell-visual-commands "ssh")
              (add-to-list 'eshell-visual-commands "tail")
              (add-to-list 'eshell-visual-commands "top"))))

;;;; Recentf

(use-package recentf
  :custom
  (recentf-save-file "~/.emacs.d/recentf")
  (recentf-max-menu-items 10)
  (recentf-max-saved-items 200)
  (recentf-show-file-shortcuts-flag nil)
  :config
  (recentf-mode 1)
  (add-to-list 'recentf-exclude
               (expand-file-name "~/.emacs.d/company-statistics-cache.el"))
  ;; rename entries in recentf when moving files in dired
  (defun rjs/recentf-rename-directory (oldname newname)
    ;; oldname, newname and all entries of recentf-list should already
    ;; be absolute and normalised so I think this can just test whether
    ;; oldname is a prefix of the element.
    (setq recentf-list
          (mapcar (lambda (name)
                    (if (string-prefix-p oldname name)
                        (concat newname (substring name (length oldname)))
                      name))
                  recentf-list))
    (recentf-cleanup))

  (defun rjs/recentf-rename-file (oldname newname)
    (setq recentf-list
          (mapcar (lambda (name)
                    (if (string-equal name oldname)
                        newname
                      oldname))
                  recentf-list))
    (recentf-cleanup))

  (defun rjs/recentf-rename-notify (oldname newname &rest args)
    (if (file-directory-p newname)
        (rjs/recentf-rename-directory oldname newname)
      (rjs/recentf-rename-file oldname newname)))

  (advice-add 'dired-rename-file :after #'rjs/recentf-rename-notify)

  (defun contrib/recentf-add-dired-directory ()
    "Include Dired buffers in the list.  Particularly useful when
     combined with a completion framework's ability to display virtual
     buffers."
    (when (and (stringp dired-directory)
               (equal "" (file-name-nondirectory dired-directory)))
      (recentf-add-file dired-directory))))

;;;; Insert date
(defun insert-date (prefix)
  "Insert the current date. With prefix-argument, use ISO format. With
   two prefix arguments, write out the day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%d.%m.%Y")
                 ((equal prefix '(4)) "%Y-%m-%d")
                 ((equal prefix '(16)) "%A, %d. %B %Y")))
        (system-time-locale "en_US.UTF-8"))
    (insert (format-time-string format))))

(global-set-key (kbd "C-c d") 'insert-date)


;; Terminal
;;;; Defaul shell should be zsh

;;(defvar my-term-shell "/usr/bin/zsh")
;;(defadvice ansi-term (before force-bash)
;;  (interactive (list my-term-shell)))
;;(ad-activate 'ansi-term)


;; Scrolling with emacs
(setq scroll-conservatively 100)



;; Theme
;;(load-theme 'gotham 1)
(load-theme 'nord t)

(set-face-background 'vertical-border "gray")
(set-face-foreground 'vertical-border (face-background 'vertical-border))


;;(use-package gotham-theme
;;  :ensure t
;;  :init (load-theme 'gotham t)
;;  )

(defun sr/mod_background ()
  "Colors the block headers and footers to make them stand out more for dark themes"
  (interactive)
  (custom-set-faces
   '(org-block-begin-line ((t (:foreground "#008ED1" :background "#002E41" :extend t))))
   '(org-block-background ((t (:background "#000000" :extend t))))
   '(org-block            ((t (:background "#122022" :extend t))))
   '(org-block-end-line   ((t (:foreground "#008ED1" :background "#002E41" :extend t))))
   '(org-level-1 ((t (:bold t :height 1.3  :foreground "#cb4b16" ))))
   '(org-level-2 ((t (:bold t :height 1.2  :foreground "#b58900" ))))
   '(org-level-3 ((t (:bold nil :height 1.1  :foreground "#2aa198"  ))))
   '(org-level-4 ((t (:bold nil :height 1.0  :foreground "#00bdfa" ))))
   )
  )

(deftheme sr/mod_gotham  "Sub-theme to beautify spacemacs")

(defun sr/change-theme (theme back)
  "Changes the color scheme and reset the mode line."
  (load-theme theme t)
  (funcall back))

;;(sr/change-theme 'gotham 'sr/mod_background)
(sr/change-theme 'nord 'sr/mod_background)

(provide 'init-client)


;;Org
(setq org-hide-emphasis-markers t) ;; this hides '/.../' and '*...*'
(setq org-confirm-babel-evaluate nil) ;; do not ask for confirmation when executing code in babel


(define-skeleton org-skeleton
  "Header info for a emacs-org file."
  "Title: "
  "#+TITLE:" str " \n"
  "#+AUTHOR: Sebastian Rauschert, PhD\n"
  "#+email: Sebastian.Rauschert@telethonkids.org.au\n"
  "#+INFOJS_OPT: \n"
  "#+BABEL: :session *R* :cache yes :results output graphics :exports both :tangle yes \n"
  "-----"
 )
(global-set-key (kbd "C-x 8") 'org-skeleton)





;;;;Font stuff
(let* ((variable-tuple
        (cond ((x-list-fonts "Gotham")         '(:font "Gotham"))
              ((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
              ((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
              ((x-list-fonts "Verdana")         '(:font "Verdana"))
              ((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
              (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
       (base-font-color     (face-foreground 'default nil 'default))
       (headline           `(:inherit default :weight bold :foreground ,base-font-color)))

  (custom-theme-set-faces
   'user
   `(org-level-8 ((t (,@headline ,@variable-tuple))))
   `(org-level-7 ((t (,@headline ,@variable-tuple))))
   `(org-level-6 ((t (,@headline ,@variable-tuple))))
   `(org-level-5 ((t (,@headline ,@variable-tuple))))
   `(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
   `(org-level-3 ((t (,@headline ,@variable-tuple :height 1.25))))
   `(org-level-2 ((t (,@headline ,@variable-tuple :height 1.5))))
   `(org-level-1 ((t (,@headline ,@variable-tuple :height 1.75))))
   `(org-document-title ((t (,@headline ,@variable-tuple :height 2.0 :underline nil))))))


;;(custom-theme-set-faces
;; 'user
;; '(variable-pitch ((t (:family "Monospace" :height 180 :weight thin))))
;; '(fixed-pitch ((t ( :family "Fira Code Retina" :height 160)))))

;;(add-hook 'org-mode-hook 'variable-pitch-mode)
(add-hook 'org-mode-hook 'visual-line-mode) ;;adjust the text to the buffer

;; Company
;;;;Change color scheme
(defun sr-company-color-setup ()
  "Sets up the color sheme for `company-mode'."

  (custom-set-faces
   ;; '(company-echo ((t (:background "#002E41" :foreground "#008ED1" :underline t))))
   '(company-preview ((t (:background "#002E41" :foreground "#008ED1" :underline t))))
   '(company-preview-common ((t (:inherit company-preview))))
   '(company-preview-search ((t (:inherit company-preview))))

   '(company-tooltip ((t (:background "#001E21" :foreground "#008ED1"))))
   ;; Formatting of autocompleted text 
   '(company-tooltip-selection ((t (:background "#002E41" :foreground "#00AEF1"))))
   ;; formatting of function arguments etc.. 
   '(company-tooltip-annotation ((t (:background "#001E21" :foreground "#C35214"))))
   ;; formatting of selected function arguments etc.. 
   '(company-tooltip-annotation-selection ((t (:background "#002E41" :foreground "#FF4500"))))
   '(company-tooltip-common
     ((((type x)) (:inherit company-tooltip :weight bold))
      (t (:background "#002E41" :foreground "#008ED1"))))
   ;; Formatting of types characted 
   '(company-tooltip-common-selection  ((t (:background "#002E41" :foreground "#c70000"))))

   '(company-template-field ((t (:background "#002E41" :foreground "#FF4500"))))

                                        ;    '(Company-tooltip-common-selection
                                        ;         ((((type x)) (:inherit company-tooltip-selection :weight bold))
                                        ;         (t (:background "#002E41" :foreground "orange"))))
   '(company-scrollbar-fg ((t (:background "#008ED1"))))
   '(company-scrollbar-bg ((t (:background "#122028"))))))
(sr-company-color-setup)


;; Avy
(defun sr-avy-color-setup ()
  "Sets up the color sheme for `avy-mode'."
  (custom-set-faces
   '(avy-lead-face   ((t (:background "#99d1ce" :foreground "#c70000"))))
   '(avy-lead-face-0 ((t (:background "#99d1ce" :foreground "#FF4500"))))
   '(avy-lead-face-1 ((t (:background "#99d1ce" :foreground "#C35214"))))
   '(avy-lead-face-2 ((t (:background "#99d1ce" :foreground "white"))))
   ))

(sr-avy-color-setup)


;; More style
(use-package rainbow-mode
  :ensure t
  :init
    (add-hook 'prog-mode-hook 'rainbow-mode))


(use-package fancy-battery
  :ensure t
  :config
    (setq fancy-battery-show-percentage t)
    (setq battery-update-interval 15)
    (if window-system
      (fancy-battery-mode)
      (display-battery-mode)))


(use-package spaceline
  :ensure t
  :config
  (require 'spaceline-config)
    (setq spaceline-buffer-encoding-abbrev-p nil)
    (setq spaceline-line-column-p nil)
    (setq spaceline-line-p nil)
    (setq powerline-default-separator (quote arrow))
    (spaceline-spacemacs-theme))

;;;; no seperator
(setq powerline-default-separator nil)

(use-package nyan-mode
  :ensure t
  :config
  (progn
    (nyan-mode)
    (nyan-stop-animation))
  )


;; Cursor position
(setq line-number-mode t)
(setq column-number-mode t)

;; Clock (24 hours)
(setq display-time-24hr-format t)
(setq display-time-format "%H:%M - %d %B %Y")

;;;; turn on the clock
(display-time-mode 1)


;; Cursor visibility
(use-package beacon
  :custom
  (beacon-push-mark 10)
  (beacon-color "#c70000")
  (beacon-blink-delay 0.3)
  (beacon-blink-duration 0.3)
  :config
  (beacon-mode)
  (global-hl-line-mode 1))



;; Easy switch between windows
(use-package switch-window

  :config
  (setq switch-window-input-style 'minibuffer)
  (setq switch-window-increase 4)
  (setq switch-window-threshold 2)
  (setq switch-window-shortcut-style 'qwerty)
  (setq switch-window-qwerty-shortcuts
        '("a" "s" "d" "f" "j" "k" "l" "i" "o"))
  :bind
  ([remap other-window] . switch-window))


;; More completion: ivy
(use-package ivy
  :ensure t
  :delight
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-height-alist '((t lambda (_caller) (/ (window-height) 4))))
  (ivy-use-virtual-buffers t)
  (ivy-wrap nil)
  (ivy-re-builders-alist
   '((counsel-M-x . ivy--regex-fuzzy)
     (ivy-switch-buffer . ivy--regex-fuzzy)
     (ivy-switch-buffer-other-window . ivy--regex-fuzzy)
     (counsel-rg . ivy--regex-or-literal)
     (t . ivy--regex-plus)))
  (ivy-display-style 'fancy)
  (ivy-use-selectable-prompt t)
  (ivy-fixed-height-minibuffer nil)
  (ivy-initial-inputs-alist
   '((counsel-M-x . "^")
     (ivy-switch-buffer . "^")
     (ivy-switch-bpuffer-other-window . "^")
     (counsel-describe-function . "^")
     (counsel-describe-variable . "^")
     (t . "")))
  :config
  (ivy-set-occur 'counsel-fzf 'counsel-fzf-occur)
  (ivy-set-occur 'counsel-rg 'counsel-ag-occur)
  (ivy-set-occur 'ivy-switch-buffer 'ivy-switch-buffer-occur)
  (ivy-set-occur 'swiper 'swiper-occur)
  (ivy-set-occur 'swiper-isearch 'swiper-occur)
  (ivy-set-occur 'swiper-multi 'counsel-ag-occur)
  (ivy-mode 1)
  :hook
  (ivy-occur-mode . hl-line-mode)
  :bind (("<s-up>" . ivy-push-view)
         ("<s-down>" . ivy-switch-view)
         ("C-S-r" . ivy-resume)
         :map ivy-occur-mode-map
         ("f" . forward-char)
         ("b" . backward-char)
         ("n" . ivy-occur-next-line)
         ("p" . ivy-occur-previous-line)
         ("<C-return>" . ivy-occur-press)))


;;;; Swiper
(use-package swiper
  :ensure t
  :after ivy
  :custom
  (swiper-action-recenter t)
  (swiper-goto-start-of-match t)
  (swiper-include-line-number-in-search t)
  :bind (("C-s" . swiper)
         ("M-s s" . swiper-multi)
         ("M-s w" . swiper-thing-at-point)))


;;;; Avy
(use-package avy
  :config
  (global-set-key (kbd "M-SPC") 'avy-goto-char-timer)
  (global-set-key (kbd "C-:") 'avy-goto-char)
  (global-set-key (kbd "C-'") 'avy-goto-char-2)
  (global-set-key (kbd "M-g f") 'avy-goto-line)
  (global-set-key (kbd "M-g w") 'avy-goto-word-1)
  (global-set-key (kbd "M-g e") 'avy-goto-word-0))

;;;; Ivy Posframe
(require 'posframe)
(require 'ivy-posframe)
(setq ivy-posframe-parameters
   '((left-fringe . 2)
     (right-fringe . 2)
     (internal-border-width . 2)
     ))
  (setq ivy-posframe-height-alist
   '((swiper . 15)
     (swiper-isearch . 15)
     (t . 10)))
  (setq ivy-posframe-display-functions-alist
   '((complete-symbol . ivy-posframe-display-at-point)
     (swiper . nil)
     (swiper-isearch . nil)
     (t . ivy-posframe-display-at-frame-center)))
  (ivy-posframe-mode 1)

;;;; Prescient


;;Magit stuff
(use-package magit

  :commands magit-status magit-blame
  :init
  (defadvice magit-status (around magit-fullscreen activate)
    (window-configuration-to-register :magit-fullscreen)
    ad-do-it
    (delete-other-windows))
  :config
  (setq magit-branch-arguments nil
        ;; use ido to look for branches
        magit-completing-read-function 'magit-ido-completing-read
        ;; don't put "origin-" in front of new branch names by default
        magit-default-tracking-name-function 'magit-default-tracking-name-branch-only
        magit-push-always-verify nil
        ;; Get rid of the previous advice to go into fullscreen
        magit-restnore-window-configuration t)

  :bind ("C-x g" . magit-status))

;;;; Counsel

(use-package counsel
  :ensure t
  :after ivy
  :custom
  (counsel-yank-pop-preselect-last t)
  (counsel-yank-pop-separator "\n—————————\n")
  (counsel-rg-base-command
   "rg -SHn --no-heading --color never --no-follow --hidden %s")
  (counsel-find-file-occur-cmd          ; TODO Simplify this
   "ls -a | grep -i -E '%s' | tr '\\n' '\\0' | xargs -0 ls -d --group-directories-first")
  :config
  (defun prot/counsel-fzf-rg-files (&optional input dir)
    "Run `fzf' in tandem with `ripgrep' to find files in the
present directory.  If invoked from inside a version-controlled
repository, then the corresponding root is used instead."
    (interactive)
    (let* ((process-environment
            (cons (concat "FZF_DEFAULT_COMMAND=rg -Sn --color never --files --no-follow --hidden")
                  process-environment))
           (vc (vc-root-dir)))
      (if dir
          (counsel-fzf input dir)
        (if (eq vc nil)
            (counsel-fzf input default-directory)
          (counsel-fzf input vc)))))

  (defun prot/counsel-fzf-dir (arg)
    "Specify root directory for `counsel-fzf'."
    (prot/counsel-fzf-rg-files ivy-text
                               (read-directory-name
                                (concat (car (split-string counsel-fzf-cmd))
                                        " in directory: "))))

  (defun prot/counsel-rg-dir (arg)
    "Specify root directory for `counsel-rg'."
    (let ((current-prefix-arg '(4)))
      (counsel-rg ivy-text nil "")))

  ;; TODO generalise for all relevant file/buffer counsel-*?
  (defun prot/counsel-fzf-ace-window (arg)
    "Use `ace-window' on `prot/counsel-fzf-rg-files' candidate."
    (ace-window t)
    (let ((default-directory (if (eq (vc-root-dir) nil)
                                 counsel--fzf-dir
                               (vc-root-dir))))
      (if (> (length (aw-window-list)) 1)
          (find-file arg)
        (find-file-other-window arg))
      (balance-windows (current-buffer))))

  ;; Pass functions as appropriate Ivy actions (accessed via M-o)
  (ivy-add-actions
   'counsel-fzf
   '(("r" prot/counsel-fzf-dir "change root directory")
     ("g" prot/counsel-rg-dir "use ripgrep in root directory")
     ("a" prot/counsel-fzf-ace-window "ace-window switch")))

  (ivy-add-actions
   'counsel-rg
   '(("r" prot/counsel-rg-dir "change root directory")
     ("z" prot/counsel-fzf-dir "find file with fzf in root directory")))

  (ivy-add-actions
   'counsel-find-file
   '(("g" prot/counsel-rg-dir "use ripgrep in root directory")
     ("z" prot/counsel-fzf-dir "find file with fzf in root directory")))

  ;; Remove commands that only work with key bindings
  (put 'counsel-find-symbol 'no-counsel-M-x t)
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ;;("s-f" . counsel-find-file)
         ;;("s-F" . find-file-other-window)
         ("C-x b" . ivy-switch-buffer)
         ;;("s-b" . ivy-switch-buffer)
         ("C-x B" . counsel-switch-buffer-other-window)
         ;;("s-B" . counsel-switch-buffer-other-window)
         ("C-x d" . counsel-dired)
         ;;("s-d" . counsel-dired)
         ;;("s-D" . dired-other-window)
         ("C-x C-r" . counsel-recentf)
         ;;("s-r" . counsel-recentf)
         ;;("s-y" . counsel-yank-pop)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable)
         ("M-s r" . counsel-rg)
         ("M-s g" . counsel-git-grep)
         ("M-s l" . counsel-find-library)
         ("M-s z" . prot/counsel-fzf-rg-files)
         :map ivy-minibuffer-map
         ("C-r" . counsel-minibuffer-history)
         ("s-y" . ivy-next-line)        ; Avoid 2× `counsel-yank-pop'
         ("C-SPC" . ivy-restrict-to-matches)))


;; Tramp
(use-package tramp

  :config
  (with-eval-after-load 'tramp-cache
    (setq tramp-persistency-file-name "~/.emacs.d/tramp"))
  (setq tramp-default-method "ssh")
  (setq tramp-use-ssh-controlmaster-options nil)

  ;; This solved the issue, it was simply a recognition error, as I use zsh as the default shell on both my cloud and my
  ;; server. appending the shell-prompt-pattern as per here: https://www.emacswiki.org/emacs/TrampMode
  (setq tramp-shell-prompt-pattern "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>].* *\\(^[\\[[0-9;]*[a-zA-Z] *\\)*")
  (message "tramp-loaded"))

(eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(use-package ssh
:ensure t
  )

;; Counsel
(use-package counsel-tramp)



;; Bullet points
;;; The .el file is taken from here: https://github.com/integral-dw/org-superstar-mode
(require 'org-superstar)
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))



;; Babel

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)
   (R . t)
   (python . t)
   (dot . t)
   (emacs-lisp . t)
   (shell . t) 
   (awk . t)
   (makefile . t)
   (latex . t)
   (java . t)
   (clojure . t)
   ))



;;;;; Jupyter notebook and python in emacs
;;(use-package company-anaconda
;;  :config (add-to-list 'company-backends #'company-anaconda))




;; ESS and R
(use-package ess
  :init (require 'ess-site))
(add-to-list 'auto-mode-alist '("\\.R\\'" . r-mode))

(use-package smartparens

  :config
  (sp-pair "'" nil :actions :rem)
  (sp-pair "`" nil :actions :rem)
  :init (add-hook 'ess-R-post-run-hook 'smartparens-mode))


;; Image in emacs
(setq org-latex-create-formula-image-program 'imagemagick)

(add-to-list 'org-latex-packages-alist
             '("" "tikz" t))

(eval-after-load "preview"
  '(add-to-list 'preview-default-preamble "\\PreviewEnvironment{tikzpicture}" t))
(setq org-latex-create-formula-image-program 'imagemagick)


(setq org-confirm-babel-evaluate nil)
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images)   
(add-hook 'org-mode-hook 'org-display-inline-images)

;; PDF in emacs
;;;;this does not work with my mac, as I need hombrew packages for it...


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(beacon-blink-delay 0.3)
 '(beacon-blink-duration 0.3)
 '(beacon-color "#c70000")
 '(beacon-push-mark 10)
 '(counsel-find-file-occur-cmd
   "ls -a | grep -i -E '%s' | tr '\\n' '\\0' | xargs -0 ls -d --group-directories-first" t)
 '(counsel-mode t)
 '(counsel-rg-base-command
   "rg -SHn --no-heading --color never --no-follow --hidden %s")
 '(counsel-yank-pop-preselect-last t)
 '(counsel-yank-pop-separator "
—————————
")
 '(ivy-count-format "(%d/%d) ")
 '(ivy-display-style (quote fancy))
 '(ivy-fixed-height-minibuffer nil)
 '(ivy-height-alist (quote ((t lambda (_caller) (/ (window-height) 4)))))
 '(ivy-initial-inputs-alist
   (quote
    ((counsel-M-x . "^")
     (ivy-switch-buffer . "^")
     (ivy-switch-bpuffer-other-window . "^")
     (counsel-describe-function . "^")
     (counsel-describe-variable . "^")
     (t . ""))))
 '(ivy-re-builders-alist
   (quote
    ((counsel-M-x . ivy--regex-fuzzy)
     (ivy-switch-buffer . ivy--regex-fuzzy)
     (ivy-switch-buffer-other-window . ivy--regex-fuzzy)
     (counsel-rg . ivy--regex-or-literal)
     (t . ivy--regex-plus))) t)
 '(ivy-use-selectable-prompt t)
 '(ivy-use-virtual-buffers t)
 '(ivy-wrap nil)
 '(package-selected-packages
   (quote
    (polymode org-pdftools posframe nord-theme ivy-posframe switch-window vdiff-magit org-superstar ivy-prescient prescient beacon which-key zenburn-theme use-package undo-tree spaceline solarized-theme rainbow-mode py-autopep8 pandoc-mode org-preview-html org-bullets nyan-mode neotree jupyter htmlize gotham-theme golden-ratio flycheck fancy-battery f ess elpy ein doom-themes diminish darkburn-theme counsel-tramp blacken auto-complete all-the-icons)))
 '(prescient-filter-method (quote (literal regexp)) t)
 '(prescient-history-length 200 t)
 '(prescient-save-file "~/.emacs.d/prescient-items" t)
 '(recentf-max-menu-items 10)
 '(recentf-max-saved-items 200)
 '(recentf-save-file "~/.emacs.d/recentf")
 '(recentf-show-file-shortcuts-flag nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-lead-face ((t (:background "#99d1ce" :foreground "#c70000"))))
 '(avy-lead-face-0 ((t (:background "#99d1ce" :foreground "#FF4500"))))
 '(avy-lead-face-1 ((t (:background "#99d1ce" :foreground "#C35214"))))
 '(avy-lead-face-2 ((t (:background "#99d1ce" :foreground "white"))))
 '(company-preview ((t (:background "#002E41" :foreground "#008ED1" :underline t))))
 '(company-preview-common ((t (:inherit company-preview))))
 '(company-preview-search ((t (:inherit company-preview))))
 '(company-scrollbar-bg ((t (:background "#122028"))))
 '(company-scrollbar-fg ((t (:background "#008ED1"))))
 '(company-template-field ((t (:background "#002E41" :foreground "#FF4500"))))
 '(company-tooltip ((t (:background "#001E21" :foreground "#008ED1"))))
 '(company-tooltip-annotation ((t (:background "#001E21" :foreground "#C35214"))))
 '(company-tooltip-annotation-selection ((t (:background "#002E41" :foreground "#FF4500"))))
 '(company-tooltip-common ((((type x)) (:inherit company-tooltip :weight bold)) (t (:background "#002E41" :foreground "#008ED1"))))
 '(company-tooltip-common-selection ((t (:background "#002E41" :foreground "#c70000"))))
 '(company-tooltip-selection ((t (:background "#002E41" :foreground "#00AEF1"))))
 '(org-block ((t (:background "#122022" :extend t))))
 '(org-block-background ((t (:background "#000000" :extend t))))
 '(org-block-begin-line ((t (:foreground "#008ED1" :background "#002E41" :extend t))))
 '(org-block-end-line ((t (:foreground "#008ED1" :background "#002E41" :extend t))))
 '(org-document-title ((t (:inherit default :weight bold :foreground "#D8DEE9" :font "Lucida Grande" :height 2.0 :underline nil))))
 '(org-level-1 ((t (:bold t :height 1.3 :foreground "#cb4b16"))))
 '(org-level-2 ((t (:bold t :height 1.2 :foreground "#b58900"))))
 '(org-level-3 ((t (:bold nil :height 1.1 :foreground "#2aa198"))))
 '(org-level-4 ((t (:bold nil :height 1.0 :foreground "#00bdfa"))))
 '(org-level-5 ((t (:inherit default :weight bold :foreground "#D8DEE9" :font "Lucida Grande"))))
 '(org-level-6 ((t (:inherit default :weight bold :foreground "#D8DEE9" :font "Lucida Grande"))))
 '(org-level-7 ((t (:inherit default :weight bold :foreground "#D8DEE9" :font "Lucida Grande"))))
 '(org-level-8 ((t (:inherit default :weight bold :foreground "#D8DEE9" :font "Lucida Grande")))))
