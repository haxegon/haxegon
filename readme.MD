[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.8.0 (2017-03-17))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. 

Haxegon compiles natively to **HTML5**, **Desktop** (Win, Mac) and **Flash/AIR**. (Linux support is currently broken, but <a href="https://github.com/openfl/starling/issues/38">is being worked on!</a>)

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

0.8.0 (2017-03-17)
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
* Fixed a crash when calling Text.width() on a font you haven't drawn with yet.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
