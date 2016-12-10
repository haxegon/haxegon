[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.4.0-alpha (2016-12-10))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. Currently only the **html5** and **flash** targets work, but **desktop** targets are planned soon!

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

Haxegon is currently in **alpha**, because it doesn't currenty work on all it's target platforms. Once it's stable enough to do that, I'll drop the -alpha tag from the version number!

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

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
