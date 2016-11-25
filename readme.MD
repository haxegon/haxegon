[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.1.0-alpha (2016-11-17))

Haxegon is a tiny haxe programming library for beginners. It's a work in progress, and proper documentation and examples are coming soon!

## Trying it out

Interested in trying it out? You can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/blob/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

Haxegon is currently in **alpha**, because it doesn't currenty work on all it's target platforms. Once it's stable enough to do that, I'll drop the -alpha tag from the version number!

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

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
