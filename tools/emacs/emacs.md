


**Emacs as a Powerful IDE - User Guide**
This guide provides an overview of how to efficiently use Emacs for working on large, multi-file C/C++ projects using the provided `init.el` configuration.

# Basic
- `C-x C-f`  Open files
- `M-p`      Previous command (like ↑ in Bash)
- `M-n`      Next command (like ↓ in Bash)
- `C-x 2`    Split the window horizontally.
- `C-x 3`    Split the window vertically.
- `C-x o`    Move to the other window.
- `C-x 0`    Close the current window.
- `C-x 1`    Delete all other windows and keep the current one. `C-c arrow` undo
- `M-up`     Move the line up
- `M-down`   Move the line down
- `M-;`      Comment a Line or Region
- `C-x t v`  Open Vterm
- `C-u 10`   prefix argument for 10.   In M-x commands, usually provide arguments before running the command.

# Treemacs
- Toggle Treemacs file tree           `M-x treemacs`                               `C-x t t`
- Go to Treemacs from file            `M-x treemacs-select-window`                 `C-c t`
- Add a project to treemacs.          `M-x treemacs-add-project-to-workspace`      `C-c C-p a`
- Purge a project from treemacs.      `M-x treemacs-remove-project-from-workspace` `C-c C-p p`

# Commonly Used Projectile Commands C-c p
- Add a new project                  `M-x projectile-add-known-project` 
- Remove a project                   `M-x projectile-remove-known-project`
- Switch projects                    `M-x projectile-switch-project`
- Find a file in the project         `M-x projectile-find-file`                   `C-c p f`
- Find a file in a known project     `M-x projectile-find-file-in-known-projects`
- Search in project using grep       `M-x projectile-grep`
- Replace text in project            `M-x projectile-replace`
- Compile the project                `M-x projectile-compile-project`
- Open project in a dired buffer     `M-x projectile-dired`
- Find a buffer in the project       `M-x projectile-switch-to-buffer`
- Find all project buffers           `M-x projectile-kill-buffers`
- Kill all buffers                   `M-x project-kill-buffers`                   `C-x p k`

# Search Command
- `C-s`                   Search  -> History:  `M-p`, `M-n`
- `M-C-s`                 Regex Search
- `M-s-o`                 Occur Search in new buffer. -> Move:  `p`, `n`
- `M-x projectile-grep`

# Buffer
- `C-x b`  Switch between open buffers
- `C-x k`  Close the current buffer
- `C-x ->` Move between buffers


# Code Editing & Auto-Completion
- `M-.` → Jump to definition
- `C-x 4 .` → jump in the other window
- `M-,` → Jump back
- `M-?` → Find references
- `M-x lsp-execute-code-action` → Perform code actions (like quick fixes)
- `M-x lsp-ui-doc-show` → Show documentation for the symbol at point

# Window resize
- `M-x shrink-window-horizontally`
- `M-x enlarge-window-horizontally`
- `M-x enlarge-window`
- `M-x shrink-window`


## The red !! markers in your screenshot next to the #include lines
- sudo dnf install bear
- bear -- make clean all
- ompile_commands.json
