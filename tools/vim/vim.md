Here are some very basic Vim commands to edit a file:
1. Delete a Line

    dd: Deletes the current line.

2. Duplicate a Line

    yy: Yank (copy) the current line.
    p: Paste the line below.

3. Copy and Paste Text

    To copy:
        Move the cursor to the start of the text you want to copy.
        Press v to enter visual mode.
        Use arrow keys (or h, j, k, l) to highlight the text.
        Press y to yank (copy).
    To paste:
        Move the cursor to the desired location.
        Press p to paste after the cursor or P to paste before the cursor.

4. Cut and Paste Text

    To cut:
        Highlight the text in visual mode using v or V (line visual mode).
        Press d to delete (cut).
    To paste:
        Move the cursor to the desired location.
        Press p to paste after the cursor or P to paste before the cursor.

5. Undo and Redo

    u: Undo the last action.
    Ctrl + r: Redo the last undone action.

6. Save and Quit

    :w: Save the file.
    :q: Quit Vim.
    :wq or ZZ: Save and quit.

Let me know if you'd like more detailed explanations or additional commands!
