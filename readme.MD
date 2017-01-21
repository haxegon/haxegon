[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.6.0 (2017-01-21))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. 

Haxegon compiles natively to **HTML5**, **Desktop** (Win, Mac) and **Flash/AIR**. (Linux support is currently broken, but <a href="https://github.com/openfl/starling/issues/38">is being worked on!</a>)

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

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

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
