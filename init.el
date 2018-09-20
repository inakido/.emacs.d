(package-initialize)

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
	     '("marmalade" . "https://marmalade-repo.org/packages/") t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/") t
(add-to-list 'load-path "~/.emacs.d/lisp/" t)

(unless package-archive-contents (package-refresh-contents))

(defvar prelude-packages
  '(async counsel dracula-theme evil evil-magit fill-column-indicator ghc
	  git-commit go-mode goto-chg haskell-mode ivy less-css-mode magit
	  magit-popup pkg-info s swiper undo-tree use-package use-package-chords
	  web-mode with-editor)
  "A list of packages to ensure are installed at launch.")

(dolist (pkg prelude-packages)
  (unless (package-installed-p pkg) (package-install pkg)))

(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(when (fboundp 'windmove-default-keybindings) (windmove-default-keybindings))

(add-to-list 'default-frame-alist '(font . "Iosevka Term 10"))
(set-frame-font "Iosevka Term 10")

(setq frame-title-format
      '(buffer-file-name "%f" (dired-directory dired-directory "%b"))
      custom-file                       "~/.emacs.d/custom.el"
      auth-source-save-behavior         nil
      enable-local-variables            nil
      inhibit-startup-screen            t
      vc-follow-symlinks                t
      inhibit-compacting-font-caches    1
      mouse-wheel-scroll-amount         '(1 ((shift) . 1))
      mouse-wheel-progressive-speed     nil
      mouse-wheel-follow-mouse          't
      scroll-step                       1
      scroll-conservatively             10000
      backup-by-copying                 t
      backup-directory-alist            '(("." . "~/.saves"))
      undo-tree-history-directory-alist '(("." . "~/.undo-tree"))
      delete-old-versions               t
      kept-new-versions                 6
      kept-old-versions                 2
      version-control                   t
      backup-directory-alist            `((".*" . ,temporary-file-directory))
      auto-save-file-name-transforms    `((".*" ,temporary-file-directory t))
      undo-tree-auto-save-history       t
      vc-mode                           1)

(global-auto-revert-mode 1)
(electric-pair-mode 1)
(show-paren-mode t)
(fringe-mode '(0 . 0))
(global-hl-line-mode 1)
(blink-cursor-mode 0)
(display-time-mode 1)

(load "~/.emacs.d/lisp/plsql.el")
(load "~/.emacs.d/lisp/dockerfile-mode.el")
(add-to-list 'auto-mode-alist
	     '("\\.\\(p\\(?:k[bg]\\|ls\\)\\|sql\\)\\'" . plsql-mode))
;;(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

(setq-default indent-tabs-mode t)
(setq-default tab-width 8)

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
	 (column (c-langelem-2nd-pos c-syntactic-element))
	 (offset (- (1+ column) anchor))
	 (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
	  (lambda ()
	    (c-add-style "libvirt"
			 '((indent-tabs-mode . nil)
			   (c-basic-offset . 4)
			   (c-indent-level . 4)
			   (c-offsets-alist
			    (label . 1))))
	    ;; Add kernel style
	    (c-add-style "linux-tabs-only"
			 '("linux"
			   (c-offsets-alist
			    (arglist-cont-nonempty
			     c-lineup-gcc-asm-reg
			     c-lineup-arglist-tabs-only))))))

(defun my-c-mode-hooks ()
  (let ((bname (buffer-file-name)))
    (cond
     ((string-match "libvirt/" bname) (c-set-style "libvirt"))
     ((string-match "datastructures/" bname) (c-set-style "linux"))
     ((string-match "linux/" bname) (c-set-style "linux-tabs-only"))
     ((string-match ".*" bname) (c-set-style "linux"))
     )))

(add-hook 'sh-mode-hook
	  (lambda () (setq indent-tabs-mode nil)))

(defun remove-elc-on-save ()
  "If you're saving an elisp file, likely the .elc is no longer valid."
  (add-hook 'after-save-hook
	    (lambda ()
	      (if (file-exists-p (concat buffer-file-name "c"))
		  (delete-file (concat buffer-file-name "c"))))
	    nil
	    t))

(add-hook 'emacs-lisp-mode-hook 'remove-elc-on-save)
(add-hook 'c-mode-hook 'my-c-mode-hooks)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(defun gcm-scroll-down ()
  (interactive)
  (scroll-up 1))

(defun gcm-scroll-up ()
  (interactive)
  (scroll-down 1))

(global-set-key [(control down)] 'gcm-scroll-down)
(global-set-key [(control up)]   'gcm-scroll-up)

(global-set-key [(control next)] 'gcm-scroll-down)
(global-set-key [(control prior)]   'gcm-scroll-up)

(require 'use-package)

(use-package ivy
  :init
  (setq ivy-use-virtual-buffers t
	ivy-count-format ""
	ivy-display-style nil)
  :config
  (ivy-mode 1))

(use-package swiper
  :bind (("C-s" . swiper)))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)))

;;(use-package projectile)

;;(use-package cl)

(use-package evil
  :init
  (setq evil-want-fine-undo t)
  ;;  (add-to-list 'evil-insert-state-modes 'lisp-interaction-mode)
  :config
  (evil-mode 1))

;;(use-package magit)
(use-package evil-magit
  :init
  (setq evil-magit-state 'normal))

(use-package fill-column-indicator
  :init
  (setq fci-rule-column 80))

(use-package haskell-mode
  :mode ("\\.hs\\'" . haskell-mode)
  :interpreter ("haskell" . haskell-mode))

(use-package go-mode
  :mode ("\\.go\\'" . go-mode))

(use-package web-mode
  :mode ("\\.html\\'" . web-mode)
  :mode ("\\.css\\'" . web-mode)
  :mode ("\\.tpl\\.php\\'" . web-mode)
  :mode ("\\.[agj]sp\\'" . web-mode)
  :mode ("\\.as[cp]x\\'" . web-mode)
  :mode ("\\.erb\\'" . web-mode)
  :mode ("\\.mustache\\'" . web-mode)
  :mode ("\\.djhtml\\'" . web-mode)
  :mode ("\\.html?\\'" . web-mode)
  :init
  (setq web-mode-markup-indent-offset 2
	web-mode-code-indent-offset 2
	web-mode-css-indent-offset 2))

(use-package less-css-mode
  :mode ("\\.less\\'" . less-css-mode))

(use-package yaml-mode
  :mode ("\\.yml\\'" . yaml-mode)
  :mode ("\\.yaml\\'" . yaml-mode))

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python" . python-mode))

;;(use-package sql)

(defvar linum-current-line 1 "Current line number.")
(defvar linum-format-fmt   "" " ")
(defvar linum-format "" " ")

(defface linum-current-line
  `((t :inherit linum
       :foreground "chocolate"
       ;; :weight bold
       ))
  "Face for displaying the current line number."
  :group 'linum)

(defadvice linum-update (before advice-linum-update activate)
  "Set the current line."
  (setq linum-current-line (line-number-at-pos)))

(unless window-system
  (add-hook 'linum-before-numbering-hook
	    (lambda ()
	      (setq-local linum-format-fmt
			  (let ((w (length (number-to-string
					    (count-lines
					     (point-min)
					     (point-max))))))
			    (concat " %" (number-to-string w) "d "))))))


(defun linum-format-func (line)
  (let ((face
	 (if (= line linum-current-line)
	     'linum-current-line
	   'linum)))
    (propertize (format linum-format-fmt line) 'face face)))

(unless window-system
  (setq linum-format 'linum-format-func))

(add-hook 'find-file-hook (lambda ()
			    (linum-mode 1)))
(add-hook 'eshell-mode-hook (lambda ()
			      (linum-mode -1)))
