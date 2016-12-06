[![Build Status](https://travis-ci.org/TerryCavanagh/haxegon.svg?branch=master)](https://travis-ci.org/TerryCavanagh/haxegon)

# Haxegon (version 0.3.2-alpha (2016-11-29))

Haxegon is a tiny haxe programming library aimed at beginners. It's currently in alpha, so things are changing fast and stuff might be broken. Currently only the **flash** target works, but **html5** and **desktop** targets should also work after the next OpenFL update (https://github.com/openfl/starling/issues/25)!

## Trying it out

Interested in trying it out? You can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. More coming soon!

# Last Updates

Haxegon is currently in **alpha**, because it doesn't currenty work on all it's target platforms. Once it's stable enough to do that, I'll drop the -alpha tag from the version number!

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

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
