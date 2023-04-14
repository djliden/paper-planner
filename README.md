# Paper Planner

An Emacs package that replicates a weekly paper planner with habit tracking in org-mode.

## Installation

To install the Paper Planner package using `use-package` with `straight.el`, add the following to your Emacs configuration:

```emacs-lisp
(use-package paper-planner
  :straight (paper-planner :type git :host github :repo "djliden/paper-planner")
  :config
  ;; Configure your settings here
  (setq paper-planner-file-format "weekly-planner-%s.org")
  (setq paper-planner-starting-day "Sunday")
  (setq paper-planner-my-tasks
        '((read . 8)
          (exercise . 6)
          (work . 40)
          (study . 10)))
  ;; Optional: Set the default directory for your planner files
  (setq paper-planner-default-directory "~/your/directory/"))
```

Replace "your/directory/" with the desired directory path.

## Configuration

You can customize the paper planner by setting the following variables:

    paper-planner-file-format: Set the format for planner filenames (default: "weekly-planner-%s.org").
    paper-planner-my-tasks: Define your tasks as a list of cons cells with symbols and associated work units.
    paper-planner-default-directory: (Optional) Set the default directory for your planner files.

## Usage

Once you have the package installed and configured, you can use the following interactive functions:

    paper-planner-generate-file: Generates a new file with the planner template.
    paper-planner-mark-task: Mark the next checkbox in the current task (default keybinding: C-c C-x C-c).
    paper-planner-create-template: Create a planner template with the given start date and tasks (used internally).

The generated planner will include task sections with checkboxes, a schedule section, and a notes section. Use the paper-planner-mark-task function to mark a checkbox as completed.
