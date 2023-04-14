;;; paper-planner.el --- Custom planner template with task work unit tracking -*- lexical-binding: t; -*-

;; Author: Daniel Liden <dliden@pm.me>
;; Version: 0.1.0
;; Package-Requires: ((emacs "28"))
;; URL: 
;; Keywords: org, planner, calendar

;;; Commentary:

;; This package provides a custom planner template based on 
;; See the README for more information.

(defgroup paper-planner nil
  "A group for the custom planner variables and functions."
  :prefix "paper-planner-"
  :group 'applications)

(defcustom paper-planner-file-format "weekly-planner-%s.org"
  "Format for the custom planner file. %s will be replaced with the last Sunday's date."
  :type 'string
  :group 'paper-planner)

(defcustom paper-planner-my-tasks
  '((read . 8)
    (exercise . 6)
    (work . 40)
    (study . 10))
  "A list of tasks for the custom planner, with their associated work units."
  :type '(alist :key-type symbol :value-type integer)
  :group 'paper-planner)

(defcustom paper-planner-directory "~/org/weekly-planners/"
  "Default directory for storing custom planner files."
  :type 'directory
  :group 'paper-planner)

(defcustom paper-planner-starting-day 'sunday
  "The starting day of the week for custom planner templates. Defaults to Sunday."
  :type '(choice (const :tag "Sunday" sunday)
                 (const :tag "Monday" monday)
                 (const :tag "Tuesday" tuesday)
                 (const :tag "Wednesday" wednesday)
                 (const :tag "Thursday" thursday)
                 (const :tag "Friday" friday)
                 (const :tag "Saturday" saturday))
  :group 'paper-planner)



(defun paper-planner-count-checkboxes ()
  (let ((total 0)
        (completed 0))
    (save-excursion
      (org-narrow-to-subtree)
      (goto-char (point-min))
      (while (re-search-forward "\\[[X ]]" nil t)
        (setq total (1+ total))
        (when (string= (match-string 0) "[X]")
          (setq completed (1+ completed))))
      (widen))
    (cons completed total)))

(defun paper-planner-update-checkbox-count ()
  (save-excursion
    (org-back-to-heading t)
    (let ((checkbox-stats (paper-planner-count-checkboxes)))
      (when (re-search-forward "\\[\\([0-9]+\\)/\\([0-9]+\\)\\]" (line-end-position) t)
        (replace-match (format "[%s/%s]" (car checkbox-stats) (cdr checkbox-stats)))))))

(defun paper-planner-mark-task ()
  (interactive)
  (save-excursion
    (org-back-to-heading t)
    (let ((task-heading (point)))
      (while (and (not (org-entry-get (point) "CustomPlanner"))
                  (org-up-heading-safe)))
      (if (and (org-entry-get (point) "CustomPlanner")
               (not (equal task-heading (point))))
          (progn
            (goto-char task-heading)
            (org-narrow-to-subtree)
            (when (re-search-forward "\\[ \\]" nil t)
              (replace-match "[X]")
              (paper-planner-update-checkbox-count))
            (widen))
        (user-error "Not inside a task entry")))))

(define-key org-mode-map (kbd "C-c C-x C-c") 'paper-planner-mark-task)

(defun paper-planner-last-starting-day ()
  (let* ((day-of-week (cdr (assoc paper-planner-starting-day '((sunday . 0) (monday . 1) (tuesday . 2) (wednesday . 3) (thursday . 4) (friday . 5) (saturday . 6)))))
         (current-day-of-week (string-to-number (format-time-string "%w")))
         (days-to-last-starting-day (- current-day-of-week day-of-week)))
    (org-read-date nil t (format "-%d" days-to-last-starting-day))))

(defun paper-planner-create-template (start-date tasks)
  (interactive (list (format-time-string "%Y-%m-%d" (paper-planner-last-starting-day))
                     paper-planner-my-tasks))  (let* ((header (format "#+TITLE: Week of %s\n" start-date))
         (tasks-header "* Tasks\n:PROPERTIES:\n:CustomPlanner: t\n:END:\n")
         (task-templates ""))
    (dolist (task tasks)
      (let* ((task-name (symbol-name (car task)))
             (work-units (cdr task))
             (task-header (format "** %s [0/%s]\n" task-name work-units))
             (checkboxes ""))
        (dotimes (i work-units)
          (setq checkboxes (concat checkboxes "[ ]"))
          (when (= (% (1+ i) 5) 0)
            (setq checkboxes (concat checkboxes "\n"))))
        (setq task-templates (concat task-templates task-header checkboxes "\n"))))
    (insert header tasks-header task-templates "\n* Schedule\n\n* Notes\n")))


(defun day-of-week-to-number (day)
  (pcase day
    ('sunday 0)
    ('monday 1)
    ('tuesday 2)
    ('wednesday 3)
    ('thursday 4)
    ('friday 5)
    ('saturday 6)))

(defun paper-planner-generate-file ()
  (interactive)
  (let* ((starting-day-offset (mod (- (string-to-number (format-time-string "%w")) (day-of-week-to-number paper-planner-starting-day))
                                     7))
         (start-date (format-time-string "%Y-%m-%d" (org-read-date nil t (format "-%s" starting-day-offset))))
         (file-name (expand-file-name (format paper-planner-file-format start-date) paper-planner-directory)))
    (find-file file-name)
    (when (equal (buffer-string) "")
      (paper-planner-create-template start-date paper-planner-my-tasks))))

(provide 'paper-planner)
