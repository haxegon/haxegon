[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.9.1 (2017-07-16))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. 

Haxegon compiles natively to **HTML5**, **Desktop** (Win, Mac) and **Flash**. (Linux support is currently broken, but <a href="https://github.com/openfl/starling/issues/38">is being worked on!</a>)

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

0.9.1 (2017-07-16)
------------------
### Bug fixes/Tweaks
* Fixed a crash bug with drawing too many circles or hexagons to the screen in one frame.
* Fixed Random.chance(0) having a very low change of occasionally being true (thanks @randomnine!)

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

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
