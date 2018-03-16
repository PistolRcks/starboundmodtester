## 0.5
### What's New?
+ Update from Github with the new `--update` argument!
+ Added the `--version` argument which (you guessed it) returns the version.
+ Nicer text with escape codes on errors
+ Added CHANGELOG.md for tracking changes
+ Added VERSION for the new `--update` argument

### What's Changed?
- The argument `--literal` has been deprecated. The process is now automatic (i.e. `/path/to/mod` will package `mod` in the parent folder `/path/to`). Just typing in the folder name still works as well.
- The variable `NO_CLEANUP` has been deprecated. (it was kinda dumb anyway)
* If statements now use the more modern styling. Also, in the process...
* Optimized code by removing whitespace

## 0.4.3
### What's New?
+ Added `--force-steam` and `--force-starbound` arguments per request from @biggles5107

## 0.4.2
### What's New?
+ Added the argument `--no-cleanup`, which disables autocleanup after closing Starbound
+ Added dedicated server mode with the argument `--server`

### What's Changed?
* Changed `--skip-build` to `--no-build`

### What's Fixed?
* Fixed a bug where workshop mods with names other than `contents.pak` wouldn't load

## 0.4.1
### What's New?
+ Added the `STEAM_DIR` variable

### What's Fixed?
* Fixed bug #2; target folders can have whitespace now

## 0.4
### What's New?
+ Added Steam Workshop support with the `--enable-workshop-mods` argument
+ Added support for skipping the build phase with the `--skip-build` argument

### What's Fixed?
* Fixed bug #1 where SMT wouldn't autocleanup after closing Starbound

## 0.3
### What's New?
+ Did an almost complete rewrite of code, with multiple folder support and argument support being highlights

## Before 0.3
### What's New?
I can't remember what changed between 0.2 and 0.2.1, or what happened before that. It's not well documented at all.
