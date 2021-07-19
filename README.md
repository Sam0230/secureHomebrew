# secureHomebrew
```
Users should never be granted sudo privileges to execute files that are writable by the user or that
reside in a directory that is writable by the user.  If the user can modify or replace the command
there is no way to limit what additional commands they can run.

-- sudo manual
```
Homebrew does nothing to prevent command spoofing, so a malicious software can replace those common used command with fake ones and get root permission when you use commands like `sudo ls` or `sudo bash`.

This is a script to install homebrew with precautions against command spoofing.
