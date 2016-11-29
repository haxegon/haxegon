0.3.2-alpha (2016-11-29)
------------------
### Bug fixes/Tweaks
* Fixed *another* bug with sound assets not loading!

0.3.1-alpha (2016-11-28)
------------------
### Bug fixes/Tweaks
* Fixed a bug with sound assets not loading.

0.3.0-alpha (2016-11-27)
------------------
### New features
* Haxegon's `project.xml` file has changed. You'll need to grab the latest `blankproject.zip` file!
* While haxegon currently can't resize its window or change to fullscreen (I'm working on it!), as a temporary workaround for now, you can make your game start in fullscreen by toggling the following line at the top of your `project.xml` file.

  ```
  <set name="startfullscreen" value="true" />
  ```

* Added support for **.jpg** images. They're loaded the same way as **.png** images.
* There are now basic library installation instructions at <a href="http://www.haxegon.com">http://www.haxegon.com</a>.
* Added one new example to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Sky Tiles**.
  
### Bug fixes/Tweaks
* Renamed `S.subtractfromright()` to `S.removefromright()`. Added `S.removefromleft()` too!
* Renamed `Data.loadcsv_2d` to `Data.load2dcsv`.
* `Gfx.resizeimage()` was scrapped (it was causing confusion).
* Passing negative numbers to `Text.wordwrap()` outputs an error, but doesn't stop the game from running.
* Missing assets are now handled consistently - trying to use an asset that isn't loaded will attempt to load it, and if that asset doesn't exist, the debug system will log an error on screen. (previously, missing assets would throw an exception and stop the game from running.)

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

0.1.0-alpha (2016-11-17)
------------------
### New features
* Haxegon folder structure has changed, to better support packed textures and make it look less scary to beginners. Fonts, Icons and graphics now all go in the *data/graphics/* folder, while music and sound effects now both go in the *data/sounds/* folder. 
* Support for packed textures! Simply place the xml file in the data/graphics directory. No code changes needed.
* Images can be drawn without having to manually load them in first. They first time you draw them, they're loaded in.
* Added two new functions to extend the core loop:
   
  ``` haxe
  Core.callfunctionafterupdate(f:Function)  // Name a function to be called after update() in every scene
  ```
  
  ``` haxe
  Core.callfunctionafterrender(f:Function)  // Name a function to be called after render() in every scene
  ```
  This was required for compatibility with my own projects!
* Added a variable to enable/disable the Starling Stats Display, showing FPS, memory use and draw calls.

  ``` haxe
  Core.showstats = true; //Set true to display FPS and stats
  ```
* Added two new mouse functions, the mouse equivalents of `Input.delaypressed()`:
  
  ``` haxe
  Mouse.leftdelaypressed(delay:Int)  // Returns true every "delay" frames.
  ```
  
  ``` haxe
  Mouse.rightdelaypressed(delay:Int)  // Returns true every "delay" frames.
  ```

### Bug fixes/Tweaks
* Fixed `Text.wordwrap(width)`.
* Fixed `Text.input()` and `Text.getinput()`.
* Fixed a bug where the screen texture was getting created twice at startup.
* Fixed a bug with core timing. (thanks, <a href="https://github.com/randomnine/">@randomnine</a>!)
* `Gfx.imagecolor()` and `Gfx.imagealpha()` can now be called without any arguments.
* Restored older, simpler `Input.delaypressed()` behavior.

0.0.1-alpha (2016-11-06)
------------------
* Initial haxelib release!
