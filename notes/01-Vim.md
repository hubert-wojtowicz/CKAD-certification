# vim

- `<n>h`, `<n>j`, `<n>k`, `<n>l` - left, down, up, right, where `<n>` is repeat number
- `G` - end of file
- `g` - beginning of file
- `<n>{`, `<n>}` - skip blok of code up and down, where `<n>` is repeat number
- `<n>dd`, `u` - delete and undo delete of line
- `yy` - copy line to clipboard
- `p` - paste clipboard
- `V` - visual mode 
- `o` (or `O`) - put you in the INSERT mode line below (above)
- `w`, `b` - go next word up and backward 
- `W`, `B` - go next whitespace up and backward 
- `:30` go to line 30
- `0` - move cursor to beginning of line
- `^` - move cursor to beginning of line (skipping spaces)
- `$` - move to end of line
- `t<c>` - set cursor one character before c in line (`f<c>` on the character)
- `cw` - change word (forward) that starts on prompt
- `dw` - delete wort
- `D` - delete rest of the line
- `C` - delete rest of the line and go to insert mode 
- `ct<c>` change line until you will find `<c>` character for example `ct}`. `;` allows to jump to next found occurrence
- `*` move to next occurrence of prompted word
- `z` move prompted element to center of screen
- `a` - set insert mode on next character
- `A` - set insert mode at the end of the line
- `<n>x` - delete (forward) `<n>` characters prompt is over
- `<n>~` - for `<n>` chars (forward) capitalize if lowercase, lowercase if capital
- `.` - repeat last command for example `3xj.` remove 3 characters go line down and repeat the same operation
- `<n>r` - replace `<n>` letters
- `R` - override letters starting from cursor
- `<n>>`, `<n><` - move block right or left `<n>` times

continue learning vim: https://youtu.be/IiwGbcd8S7I?t=2414

# less navigation
From: https://www.thegeekstuff.com/2010/02/unix-less-command-10-tips-for-effective-navigation/

/ – search for a pattern which will take you to the next occurrence.
n – for next match in forward
N – for previous match in backward
? – search for a pattern which will take you to the previous occurrence.
n – for next match in backward direction
N – for previous match in forward direction
j – navigate forward by one line
k – navigate backward by one line
G – go to the end of file
g – go to the start of file
q or ZZ – exit the less pager
:n – go to the next file.
:p – go to the previous file.

CTRL+F – forward one window
CTRL+B – backward one window
CTRL+D – forward half window
CTRL+U – backward half window