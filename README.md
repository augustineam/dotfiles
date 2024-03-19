## My Dotfiles

- New dot files should be copied to `dotfiles/` folder manually, after that `backup.sh` script backs them up.
- Files we no longer wish to back up have to be removed from `dotfiles/` folder manually
- `backup.sh` takes care of creating `pkgs/{native,foreign}` (Arch packages installed explicitly)
