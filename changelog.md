
0.11.0 (2018-01-16)
------------------
### New features
* This is the biggest update to Haxegon in more than a year! This update will probably break compatibility with your older haxegon projects. I recommend starting over with a new <a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a> folder, and transferring your assets and source code across. The main things to watch out for are the new data/ folder structure, and changes to Music/Sound.
* Haxegon has been updated to work with OpenFL 7.0 and Starling 2.0.
* The project structure has changed. There is a new `project.xml` file for haxegon projects, and a `data/` folder with a new, flatter, simpler layout. Grab the new <a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a> file to get started. The data folder inside contains a guide for adding assets to your haxegon project.
* `Gfx.resizescreen(width, height)` has had an upgrade, and is now a lot more flexible. The following settings are now possible:
``` haxe
  //Create a 640x360 pixel screen, which is streched and letterboxed to the current window.
  Gfx.resizescreen(640, 360);
  
  //Create a screen which MATCHES the current window size. When the window size changes,
  //update Gfx.screenwidth and Gfx.screenheight to the new values.
  Gfx.resizescreen(0, 0);
  
  //Create a dynamic screen of height 360, but with a floating width that matches the scale
  //of the current window and updates Gfx.screenwidth to match:
  Gfx.resizescreen(0, 360);
  
  //Create a dynamic screen of width 640, but with a floating height that matches the scale
  //of the current window and updates Gfx.screenheight to match:
  Gfx.resizescreen(640, 0);
```
* Setting `Gfx.keeppixelratio` to **true** tells haxegon to keep a 1:1 pixel ratio when stretching the screen to fit a window, even if this creates black bars on all sides. Possibly good for very low resolution games!
* `Text.input()` is now a little simplier:
``` haxe
  if(Text.input(x, y)){
    trace(Text.inputresult);
  }
```
* Added support for **.wav** files.
* There's a brand new music engine in Haxegon rewritten from scratch. It's now possible to crossfade music, layer multiple looping sounds, control the panning of each sound, as well as lots of other cool complex stuff that wasn't possible before.
``` haxe
  //Play an explosion sound effect.
  Sound.play("explosion");
  
  //Stop all sound effects:
  Sound.stop();
  
  //Stop only the "explosion" sound effects, and fade them out over 0.2 seconds:
  Sound.stop("explosion", 0.2);
  
  //Play the "backgroundtheme".
  Music.play("backgroundtheme");
  
  //Play the "backgroundtheme", but fade in over 3 seconds.
  Music.play("backgroundtheme", 0, 3.0);
  
  //Stop the music, fading out over 3 seconds.
  Music.stop(3);
  
  //Set the position of the current song to 15 and a half seconds in:
  Music.currentposition = 15.5;
```
* Replaced `Data.blank2darray(w, h)` with `Data.create2darray(w, h, defaultvalue)`, and made the function work correctly for all types - Ints, Strings, Bools, custom classes, whatever.
* Added `Scene.restart(Myscene)`, which discards and reloads a named scene.

### Bug fixes/Tweaks
* The default window size has been changed to a **720p** friendly **1280x720**.
* On native platforms, on dual Nvidia/Intel devices, Haxegon will now use your Nvidia card instead of your integrated intel one. 
* Removed `Core` extension functions. They still exist, but now require `@:access(haxegon.Core)` at the start of your class to discourage unnecessary use.
* Haxegon now works correctly on high dpi devices.
* `Filter.blur` is now a **Float** instead of a **Bool**, and supports different degrees of bluriness.
* Speed improvements to `Gfx.getpixel()`.
* Re-added `Text.setfont(font, size)` to allow you to change font and size at the same time.
* Right click context menu is disabled in HTML5.
* Added an `Input.getkeyfromcharacter()` function as a reverse of `Input.getchar()`.
* `Text.typingsound` lets you associate a sound effect with typing.
* Fixed alignment on text rotations.
* Lots and lots of other long running tiny bugs fixed.

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

0.9.1 (2017-07-16)
------------------
### Bug fixes/Tweaks
* Fixed a crash bug with drawing too many circles or hexagons to the screen in one frame.
* Fixed `Random.chance(0)` having a very low change of occasionally being true (thanks @randomnine!)

0.9.0 (2017-06-02)
------------------
### New features
* Added a new simple example to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Filters**.
* Added support for simple fullscreen filters. Currently just `bloom` and `blur`, but more coming soon!
``` haxe
  Filter.bloom = 1.0; // Enable bloom filter
  Filter.bloom = 2.0; // Enable really bright bloom filter
  Filter.blur = true; // Enable blur filter
  
  Filter.reset(); //Disable all active filters
```
* Redesign of the `Debug` class. There's now a nicer and more useful Debug window, with the following two functions:
``` haxe
  Debug.log("Error!"); //Output an error to the console and the debug window
  Debug.clear(); //Clear the debug window
```
* Added handy new colour shifting functions:
``` haxe
  //Returns a colour with the RGB components (0-255) adjusted.
  newcolour = Col.shiftred(oldcolour, amount);
  newcolour = Col.shiftgreen(oldcolour, amount);
  newcolour = Col.shiftblue(oldcolour, amount);
  
  //Returns a colour with the hue component (0-360) adjusted.
  newcolour = Col.shifthue(oldcolour, amount);
  
  //Returns a colour with the saturation or lightness (0-1.0) adjusted.
  newcolour = Col.multiplysaturation(oldcolour, amount);
  newcolour = Col.multiplylightness(oldcolour, amount);
```
* Cleanup to `Random.hx`. Some old cluttery functions have been removed - `Random.pickint()`, `Random.pickfloat()`, `Random.pickstring()` (just use `Random.pick()`!), also `Random.occasional()` and `Random.rare()` (just use `Random.chance(percentodds:Float)`!).
* Added `Random.shuffle()`.
``` haxe
  var temparray:Array< String> = ["cat", "dog", "pig", "rabbit", "frog"];
  Debug.log("Original order is: " + temparray);
  
  Random.shuffle(temparray);
  Debug.log("After shuffling: " + temparray);
```

### Bug fixes/Tweaks
* Updated to work with the latest 5.0 versions of OpenFL and Lime.
* Fixed smoothing issue with `Gfx.drawsubimage()`.
* Disabled right click on Flash target. You can press <i>Ctrl + Left Click</i> to simulate a right click on Flash.
* Fixed a bug where haxegon wasn't using the fps value from `project.xml`. (via https://twitter.com/randomnine/)
* Default FPS is now 60 instead of 30.
* Internal improvements to drawing primatives. (via https://twitter.com/KommanderKlobb/)
* Support for quadbatching on `Gfx.drawhexagon()`, `Gfx.fillhexagon()`, `Gfx.drawcircle()` and `Gfx.fillcircle()`, resulting in speed improvements on all those functions.
* Fixed `Mouse.offscreen()` (via https://twitter.com/randomnine/) 
* Fixed a crash bug if you draw a circle of radius 0.
* Fixed line thickness on `Gfx.drawbox()`.
* Fixed `Random.seed`.
* General cleanups to the library.

0.8.0 (2017-03-10)
------------------
### New features
* Implemented `Gfx.getpixel()`. It's very slow right now - I'll work on speeding it up for the next version!
* Default font has changed from Verdana to the bitmap font **PC Paint Normal**. This is included in the engine, and doesn't require you to include any assets.
* Calling `Gfx.clearscreen(Col.TRANSPARENT)` when drawing to an image now restores the transparency of that image.
* On Native targets, you can capture the mouse cursor by setting the values of `Mouse.x` and `Mouse.y`.
* Implemented `Mouse.offscreen()`.
* Some new helper functions added to `Geom` (which was called `Help` in the last build). All `Geom` functions work in Radians, to be consistant with Haxe's Math class.
``` haxe
  //Return the smallest angle between a and b, including sign:
  var smallestangle:Float = Geom.anglebetween(a, b);
  
  //Clamp a value between a minimum and maximum value
  var clamptedvalue:Float = Geom.clamp(value, min, max);
  
  //Convert radians to degrees, and vice versa
  var rad:Float = Geom.todegrees(deg);
  var deg:Float = Geom.todegrees(rad);
```

### Bug fixes/Tweaks
* The `Help` class has been renamed `Geom`. The renamed functions are `Geom.inbox`, `Geom.overlap`, `Geom.getangle` and `Geom.distance`.
* `Gfx.scale()` can be called with no parameters to reset image scale setting (Same as `Gfx.scale(1, 1)`).
* `Gfx.scale()` can be called with a single parameter scale x and y the same.
* Fixed a crash when calling `Text.width()` on a font you haven't drawn with yet.

0.7.0 (2017-01-22)
------------------
### New features
* Added a new simple example to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Truetype Fonts**.
* Added `Core.delaycall(f:Function, time:Float)`, which calls a function after a specified number of seconds. E.g.
``` haxe
trace("go!");
Core.delaycall(callmelater, 2.5);

function callmelater(){
  trace("two and half seconds have passed!");
}
```
* Added a couple of useful helper functions in a new Help class. (Suggestions for a better class name welcome!)
``` haxe
  Help.inbox(x, y, rectx, recty, rectw, recth);  //True if point (x, y) is in rectangle
  Help.overlap(x1, y1, w1, h1, x2, y2, w2, h2);  //True if rectangles overlap
  Help.distance(x1, y1, x2, y2);                 //Distance in pixels between two points
  Help.getangle(x1, y1, x2, y2);                 //Angle [0-360] between two points
  Help.clamp(value, min, max);                   //Clamps a value between [min, max]
  ```
* Added `Mouse.deltax` and `Mouse.deltay`, which return the change in mouse position since the last frame.

### Bug fixes/Tweaks
* Removed `Mouse.previousx` and `Mouse.previousy`.
* Passing no arguments to `Input.forcerelease()` releases all keys currently being held.
* Sped up `Data.loadtext()` on native targets.
* Sped up bitmap font rendering (using starling QuadBatches).
* Improvements to drawtile quadbatching. 

0.6.0 (2017-01-21)
------------------
### New features
* Added a new example game to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Tiny Heist**.
* Haxegon now uses Starling's QuadBatches internally, which speeds up drawing of primitives in many cases, especially HTML5.
* A number of surface drawing functions have been implemented:
``` haxe
  //Grab an image from the screen
  Gfx.grabimagefromscreen(imagename, screenx, screeny);
  
  //Grab a tile from the screen
  Gfx.grabtilefromscreen(tilesetname, tilenumber, screenx, screeny);
  
  //Grab an image from an image
  Gfx.grabimagefromimage(destinationimage, sourceimage, sourceimagex, sourceimagey);
  
  //Grab a tile from an image
  Gfx.grabtilefromimage(tilesetname, tilenumber, imagename, imagex, imagey);
  
  //Copy a tile from one tileset to another
  Gfx.copytile(totileset, totilenumber, fromtileset, fromtilenumber);
```
* The new save functions from the last version have been moved to Save.hx. Some functions have been renamed, and some new functions have been added:
``` haxe
  //Loading and saving values:
  Save.savevalue(key, value);             //e.g. Save.savevalue("highscore", highscore);
  Save.loadvalue(key);                    //e.g. highscore = Save.loadvalue("highscore");
  Save.exists(key);                       //e.g. if(!Save.exists("highscore")) highscore = 0;
  
  //Changing or deleting the save files
  Save.fileexists(filename:String);       //Returns true if this file exists (i.e. it has at least one key saved)
  Save.filename = "mygame_slot1";         //Sets a name for your savefile (optional! default is "haxegongame".)
  Save.delete(filename:String);           //Delete a save file (leaving parameter blank deletes the default)
  ```
 * `Save.keys` is an array of strings containing all the saved keys for the current savefile. An example usage:
``` haxe
  for(i in 0 ... Save.keys.length){
    trace(Save.keys[i] + ": " + Save.loadvalue(Save.keys[i]));
  }
  ```
* Added `Core.window`, for native targets only. Allows you to control parameters of the current application window. See <a href="http://api.openfl.org/lime/ui/Window.html">OpenFL documentation</a> for more information.
* Added `Core.quit()`, for native targets only. Quits the application.
  
### Bug fixes/Tweaks
* Fixed a bug where `Gfx.drawtoimage()` and `Gfx.drawtotile()` didn't work if called in `Main.new()`.
* Default value for `Save.loadvalue(key)` is always 0 - it no longer logs a warning.
* Implemented `Text.wordwrap` as a variable instead of a function.
* Fixed `Core.callafterupdate(f:Function)`.

0.5.0 (2016-12-26)
------------------
### New features
* Native targets now work! As Haxegon now works on all of its target plaforms (HTML5, Native and Flash/AIR), I've dropped the *-alpha* tag from the version number. Exciting! Things are still pretty unstable and will be until 1.0.0, but the library is now at a point where it's basically useable.
* Added new functions to Data for loading and saving key/value pairs:
``` haxe
  Data.save(key, value);             //e.g. Data.save("highscore", highscore);
  Data.load(key);                    //e.g. highscore = Data.load("highscore");
  Data.savefile = "mygame_slot1";    //Sets a name for your savefile (optional! default is "haxegongame".)
  Data.deletesave(filename:String);  //Delete a save file (leaving parameter blank deletes the default)
  ```
  
### Bug fixes/Tweaks
* Asset loading doesn't care about being case sensitive anymore.
* Fixed bug where HTML5 build always displayed a fullscreen warning at startup.
* General library cleanups.

0.4.0-alpha (2016-12-10)
------------------
### New features
* Thanks to new updates to both OpenFL and Starling, Haxegon now works on HTML5! Native targets will come later, and HTML5 should improve as time goes on. My intention is for HTML5 to eventually be the lead target.
* Added `Gfx.fullscreen` boolean. Set to **true** or **false** anywhere to toggle fullscreen!
* `Gfx.resizescreen()` no longer takes a *scale* parameter - the canvas now automatically scales to fit the current window.
* Added two new examples to the <a href="https://github.com/TerryCavanagh/haxegon-samples">haxegon-samples</a> repo: **Music and Sounds**, and **Scene Change**.
* Moved color functions from `Gfx.hx` to `Col.hx`, where they seem to make more sense: 
  
  ``` haxe
  Col.rgb(red [0-255], green [0-255], blue [0-255]);
  Col.getred(col);
  Col.getgreen(col);
  Col.getblue(col);
  
  Col.hsl(hue [0-360], saturation [0-1.0], lightness [0-1.0]);
  Col.gethue(col);
  Col.getsaturation(col);
  Col.getlightness(col);
  ```
* Added some new string manipulation functions to `S.hx`:

  ``` haxe
  S.join(array, separator); //Returns a single string of the elements of array joined together
  S.seperate(array, delimiter); //Returns an array of strings, split by the given delimiter.
  S.asciicode(character); //Returns the ASCII value of the character.
  S.fromascii(ascii code); //Converts an ascii code to a string. E.g. fromascii(65) == "A"
  ```
  
### Bug fixes/Tweaks
* New **blankproject.zip** - `startfullscreen` has been removed from project.xml. You shouldn't need to update unless your project folder is older than 0.3. (if you want to start in fullscreen now, just set `Gfx.fullscreen = true;` in your Main.new() function.)
* Fixed crash if you resized the window.
* Fixed crash if calling drawing functions in `Main.new()`.
* Speed up to drawing to surfaces other than the screen.
* Fix to .OGG loading on HTML5.
* Cleaned up some old hashdefines, and general library cleanup. Deleted haxegon/util folder.

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
