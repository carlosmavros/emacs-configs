;; Cleanup
(setq delete-old-versions -1 )		
(setq version-control t )	
(setq vc-make-backup-files t )		
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")) ) 
(setq vc-follow-symlinks t )				      
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)) )
(setq inhibit-startup-screen t )	
(setq ring-bell-function 'ignore )	
(setq coding-system-for-read 'utf-8 )	
(setq coding-system-for-write 'utf-8 )
(setq sentence-end-double-space nil)	
(setq default-fill-column 85)		

;; UI tweaks
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(setq visible-bell t)       ; Set up the visible bell

;; Font and theme
(set-face-attribute 'default nil :font "Fira Code Retina" :height 130)

;; Extra Stuff 
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) ; Make ESC quit prompts
(global-display-line-numbers-mode t)                    ; Line numbering
(column-number-mode)                                    ; Column numbering
(dolist (mode '(org-mode-hook           ;Disable line numbers for some modes
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Package sources 
(require 'package)
(setq package-enable-at-startup nil)       
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Setting up use-package
(unless (package-installed-p 'use-package) 
  (package-refresh-contents) 
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Evil setup
(use-package evil
  :ensure t
  :defer .1
  :init
  (setq evil-want-integration nil) ;; required by evil-collection
  (setq evil-want-keybinding nil)  ;; also required by evil-collection
  (setq evil-search-module 'evil-search)
  (setq evil-ex-complete-emacs-commands nil)
  (setq evil-vsplit-window-right t) ;; like vim's 'splitright'
  (setq evil-split-window-below t) ;; like vim's 'splitbelow'
  (setq evil-shift-round nil)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (message "Loading evil-mode...done"))

;; Rainbow delimeters 
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Which-key
(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay .3))

;; Doom themes
(use-package doom-themes
  :init (load-theme 'doom-dracula t))

;; Necessary for doom-modeline 
(use-package all-the-icons)

;; Doom modeline
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; Managing recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(run-at-time nil (* 5 60) 'recentf-save-list)


;; General (keybindings)
(use-package general
  :ensure t
  :init
  (general-override-mode 1)
  :config
  (general-create-definer tyrant-def
    :keymaps 'override
    :states '(normal visual insert motion emacs hybrid operator)
    :prefix "SPC"
    :non-normal-prefix "C-SPC")
  (tyrant-def
   "!" 'shell-comand
   ":" 'eval-expression

   ; undo-tree
   "u" '(:ignore t :which-key "undo-tree-menu")
   "u u" 'undo-tree-undo
   "u r" 'undo-tree-redo
   "u v" 'undo-tree-visualize

   ; buffers
   "b" '(:ignore t :which-key "buffer") 
   "b n" 'next-buffer
   "b s" 'save-buffer
   "b p" 'previous-buffer
   "b k" 'kill-this-buffer
   "b b" 'switch-to-buffer
   "b e" '(eval-buffer :which-key "buffer")

   ;latex
   "L" 'TeX-command-master
   ; files
   "f" '(:igonre t :which-key "file")
   "f f" 'find-file
   "f r" 'counsel-recentf
   "f s" 'save-buffer      ; same as "SPC b s" but sometimes more intuitive

   ; windows 
   "w" '(:ignore t :which-key "window")
   "w d" '(delete-window :which-key "delete")
   "w w" '(other-window :which-key "next")
   "w s" '(:ignore t :which-key "split")
   "w s v" '(split-window-vertically :which-key "vertically")
   "w s h" '(split-window-horizontally :which-key "horizontally")

   ; workflow
   "SPC" '(counsel-buffer-or-recentf :which-key "recents + buffers")
   "r" '(counsel-M-x :which-key "run (M-x)")
   "t" '(eshell :which-key "terminal (zsh)")

   ; python stuf
   "p" '(:igonre t :which-key "python")
   "p i" '(run-python :which-key "interpreter")
   "p e" '(python-shell-send-region :which-key "execute-region")
   "p f" '(python-shell-send-file :which-key "execute-file")

   ;lsp stuff
   "l" '(:ignore t :which-key "lsp")
   "l r" 'lsp-rename  ; let's test it out

   ;org stuff
   "o" '(:ignore t :which-key "org")
   "o a" 'org-agenda
   "o s" 'org-schedule ;shift-arrowkeys to navigate
   "o l" 'org-insert-link
   "o t c" 'org-toggle-checkbox
   )) 

;; Ivy
(use-package ivy
  :diminish
  :config
  (ivy-mode 1))

;; Counsel
(use-package counsel
  :config
  (counsel-mode 1))

;; Eshell
(defun configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

;; Eshell git prompt
(use-package eshell-git-prompt)


(use-package eshell
  :hook (eshell-first-time-mode . configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))


;; Lsp-mode
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)


; Python stuff
(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred)
  :custom
  (python-shell-interpreter "python3"))



;; Projectile
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit auctex jedi company-jedi lsp-ivy lsp-treemacs lsp-ui lsp-mode which-key visual-fill-column use-package rainbow-delimiters python-mode org-bullets general evil eshell-git-prompt doom-themes doom-modeline counsel-projectile))
 '(safe-local-variable-values '((TeX-engine . xetex))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Jedi
(use-package jedi
  :hook (python-mode . jedi:setup)) 



;; Latex (auctex)
(use-package auctex
  :defer t
  :ensure t
  :config
  (setq TeX-auto-save t))

;; Undo-tree
(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode))


;; Org setup
(use-package org
  :config
  (setq org-ellipsis " ▼"))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●"))) 


;; org exporting
(require 'ox-latex)
(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))
(add-to-list 'org-latex-classes
             '("orgNotes"
               "\\documentclass[12pt,a4paper]{article}
                [NO-DEFAULT-PACKAGES]
                \\usepackage[utf8]{inputenc}
                \\usepackage[greek,english]{babel}
                \\usepackage{caption}
                \\usepackage{mathtools}
                \\usepackage{amsmath}    %math
                \\usepackage{amsfonts}   %math fonts
                \\usepackage{amssymb}
                \\usepackage{amsthm}
                \\usepackage{enumitem}
                \\usepackage{geometry}   %page dimensions
                \\usepackage[table,xcdraw]{xcolor}
                \\usepackage{euscript}[mathscr]
                \\usepackage[table,xcdraw]{xcolor}
                \\newtheorem{theorem}{Theorem}[section]
                \\newtheorem{lemma}[theorem]{Lemma}
                \\theoremstyle{definition}
                \\numberwithin{equation}{section}
                \\setlist[itemize,1]{label=$\\diamond$}
                \\usepackage{hyperref}
                \\hypersetup{colorlinks,citecolor=black,filecolor=black,linkcolor=black,urlcolor=black}
                \\newtheorem{exercise}{Άσκηση}
                \\newtheorem{paradeigma}{Παράδειγμα}
                \\newtheorem{protasi}{Πρόταση}
                \\newtheorem{orismos}{Ορισμός}
                \\newtheorem{theorima}{Θεώρημα}
                \\selectlanguage{greek}"
                ("\\section{%s}" . "\\section{%s}")
                ("\\subsection{%s}" . "\\subsection{%s}")
                ("\\subsubsection{%s}" . "\\subsubsection{%s}")
                ("\\paragraph{%s}" . "\\paragraph{%s}")
                ("\\subparagraph{%s}" . "\\subparagraph{%s}")))
