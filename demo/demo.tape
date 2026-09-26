# Demo GIF for the README, made with VHS (https://github.com/charmbracelet/vhs)
# Run it from the repository root: vhs demo/demo.tape

Output demo/demo.gif

Require bash

Set Shell bash
Set FontSize 16
Set Width 1100
Set Height 860
Set Padding 20
Set Theme "Catppuccin Mocha"
Set TypingSpeed 80ms
Set WindowBar Colorful

# Create the fake data and prepare the shell without recording it
Hide
Type "source demo/setup.sh && clear"
Enter
Sleep 500ms
Show

Type "ccleaner"
Sleep 500ms
Enter
Sleep 2s

# Project: -home-demo-webapp
Type "3"
Sleep 400ms
Enter
Sleep 2.5s

# Session: the oldest one
Type "3"
Sleep 400ms
Enter
Sleep 3.5s

# Confirm the deletion
Type "y"
Sleep 400ms
Enter
Sleep 3s

# Quit
Type "4"
Sleep 400ms
Enter
Sleep 2s
