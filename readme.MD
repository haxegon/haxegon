[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.2.0-alpha (2016-11-26))

Haxegon is a tiny haxe programming library for beginners. It's a work in progress, and proper documentation and examples are coming soon!

## Trying it out

Interested in trying it out? You can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/blob/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

Haxegon is currently in **alpha**, because it doesn't currenty work on all it's target platforms. Once it's stable enough to do that, I'll drop the -alpha tag from the version number!

0.2.0-alpha (2016-11-26)
------------------
### New features
* The library is now fully documented at <a href="http://www.haxegon.com">http://www.haxegon.com</a>.
* Added three new examples to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Moving Hexagon**, **Simple Mouse Game**, and **Unlicensed Ball and Paddle game**.
* `Text.setfont()` and `Text.changesize()` are deprecated. To replace them, there are two new variables in *Text.hx*.

  ``` haxe
  Text.font = "pixel";  // Set the font to "pixel"
  Text.size = 5;  // Set the font's size to 5
  ```
* Added support for changing framerate at runtime:

  ``` haxe
  Core.fps = 30;  // Set the framerate to 30fps
  ```
* Added `Core.time`, a variable that gives you a counter in seconds since the start of the game:

  ``` haxe
  Text.display(0, 0, Core.time + " seconds since game started");
  ```
* Added some new functions to `Mouse.hx`:

  ``` haxe
  //These functions now match the ones in Input.hx
  Mouse.leftheldpresstime(); //Returns the number of frames the left mouse button is held
  Mouse.rightheldpresstime(); //Returns the number of frames the right mouse button is held
  Mouse.middleheldpresstime(); //Returns the number of frames the middle mouse button is held
  
  //This function was missing
  Mouse.middledelaypressed(delay:Int); //Returns true every N frames when middle mouse button is held
  ```
* Added a new string function, `subtractfromleft(currentstring:String, length:Int = 1)`, because I always end up writing one:

  ``` haxe
  var example:String = "img:doge.png";
  var imgfile:String = S.substractfromleft(example, 4); //imgfile is now "doge.png";
  ```
* Added `Gfx.clearcolor:Int`, which replaces the older `Gfx.clearscreeneachframe:Bool`. You can now set the background colour to change to at the start of each frame, or set it to `Col.TRANSPARENT` to have a persistent background.
* Added volume level support to `Music.playsound(soundname:String, volume:Float, offset:Float);`

### Bug fixes/Tweaks
* Fixed a crash when drawing primitives in Main.new().
* General library cleanup, internal functions set to private so they don't appear in autocomplete.
* Renamed some functions in *Music.hx*. This is in advance of a general cleanup I'm planning for the next update. `Music.play()` is now `Music.playsong()`, `Music.stop()` is now `Music.stopsong()`.
* Renamed some variables in *Mouse.hx*. `Mouse.oldx` and `Mouse.oldy` are now `Mouse.previousx` and `Mouse.previousy`.
* In *Mouse.hx*, `Mouse.mouseoffstage()` and `Mouse.cursormoved()` are functions instead of Booleans. (Since you can't meaningfully set thier values.)
* Replaced `Scene.getcurrentscene()` with `Scene.name()`. `Scene.getcurrentsceneclass()` set to private.
* New default font is **Verdana**, size 24.
* Removed Mouse.visitsite() - it's a weird flash specific thing, and flash is a legacy target.
* Fixed a bug where `Gfx.screenwidth` and `Gfx.screenheight` returned 0 in Main.new().
* Fixed a crash bug if you called `Text.width()` without setting a font first.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
