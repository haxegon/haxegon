[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.10.0 (2017-08-26))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. 

Haxegon compiles natively to **HTML5** and **Desktop** (Win, Mac, Linux). **Flash** is also supported as a legacy/development platform.

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

0.10.0 (2017-08-26)
------------------
### New features
* This is mostly just a compatibility update for OpenFL 6.0. Haxegon now works with the latest versions of OpenFL and Lime.
* Added support for `Key.ANY`.  (Thanks to @nachoverdon for the suggestion!):
``` haxe
  if(Input.pressed(Key.ANY)) // True if ANY key is being pressed right now
  if(Input.justpressed(Key.ANY)) // True if ANY key has just been pressed
```
* Changed `Gfx.imagealpha` and `Gfx.imagecolor` to variables instead of functions. Also added three new shortcut functions to reset image drawing settings - `Gfx.resetalpha()`, `Gfx.resetcolor()` and `Gfx.reset()`:
``` haxe
  Gfx.imagealpha = 0.5;
  Gfx.imagecolor = Col.GREEN;
  Gfx.drawimage(x, y, "someimage");
  
  Gfx.resetalpha(); //Same as calling Gfx.imagealpha = 1
  Gfx.resetcolor(); //Same as calling Gfx.imagecolor = Col.WHITE
  Gfx.reset();      //Resets colour, alpha, rotation and scale
```
* Added an optional alpha parameter to `Text.display()`. (Thanks to @nachoverdon for the suggestion!)
``` haxe
  Text.display(x, y, "spooky see through text", Col.WHITE, 0.5);
```

### Bug fixes/Tweaks
* Removed deprecated `startfullscreen` setting from blankproject.zip.
* Documentation updates.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
