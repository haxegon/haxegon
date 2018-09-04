# Haxegon (version 0.13.0 (2018-09-04))

Haxegon is a tiny haxe programming library aimed at beginners. Haxegon is starting to get pretty stable, so you can expect the API not to change too much more before 1.0!

The current update, 0.13.0, brings support for the latest versions of OpenFL (8.4.1), Lime (7.0.0) and Starling (2.4.1). The **documentation** focus has been pushed back to 0.14.0 to keep things up to date!

Haxegon compiles natively to **HTML5** and **Desktop** (Win, Mac, Linux, Neko). **Flash** is also supported as a legacy/development platform. Other platforms (including Mobile and Switch) are possible, and may be coming in future!

## Trying it out

Interested in trying it out? First install openfl via <a href="http://www.openfl.org/learn/docs/getting-started/">instructions here</a>, then you can install Haxegon using haxelib:

    haxelib install haxegon
    
Once the library is installed, use this blank project file to get started:

<a href="https://github.com/TerryCavanagh/haxegon/raw/master/blankproject.zip">[blankproject.zip]</a>

Documentation is available at <a href="http://haxegon.com">haxegon.com</a>, and a growing selection of example projects are <a href="https://github.com/TerryCavanagh/haxegon-samples">available here</a>. You can also extend Haxegon with <a href="http://www.haxegon.com/plugins/">plugins, available here</a>.  More coming soon!

# Last Updates

0.13.0 (2018-09-04)
------------------

### About version 0.13.0

Haxegon hasn't worked with the most recent versions of OpenFL for a couple of months now, so I decided to release this version to get things back up and running. Originally the idea was that this version would focus on documentation, but that's been pushed back. A lot of the changes in this version are advanced features added for OVERWHELM, and for my current project Dicey Dungeons - though there are plenty of other fixes and improvements that will benifit everyone who uses the library!

### New features
  * This version brings support for the latest versions of OpenFL (8.4.1), Lime (7.0.0) and Starling (2.4.1).
  * Added `Core.enablescreen`, which allows you to turn off the Haxegon screen completely. Useful if you just want to use Starling display objects directly!
  * Added `Core.imagesmoothing` - when true, uses bilinear smoothing when displaying images. `false` by default.
  * Better, faster Starling Mesh batching. (thanks, @randomnine!)
  * Optimisations to `Gfx.drawsubimage()`. (thanks, @randomnine!)
  * Added `Gfx.drawellipse()` and `Gfx.fillellipse()`.
  * Added support for paths with `../` in `Data.load` functions.
  * Added `Core.mobilebrowser()`, which returns true if the application is being played in a browser on a mobile device.
  * Added default parameters to `Save.loadvalue` - e.g. `var musicVolume = Save.loadvalue("MusicVolume", .5);`. (thanks @increpare!)
  
### Bug fixes/Tweaks
  * Updated Starling to v2.4.1.
  * Fixed a bug where `Text.width()` wasn't giving reliable values for bitmap fonts.
  * Supress default backspace key behaviour on HTML5. (It usually acts like a "back" button in browsers, which you probably don't want)
  * Added `Gfx.unloadimage()`. (Unloads an image, freeing up its resources.)
  * Support for higher resolution TTF fonts with `Text.setfont()`.
  * Added `Debug.limitdrawcalls` for display list debugging.
  * Fixed mouse deltas on touch controls.
  * Fixed `Gfx.clearscreen(Col.TRANSPARENT)` - it now works as expected on all platforms.
  * Fixed a memory leak with `Text.display()`.
  * Fixed HTML5 Fullscreen button controls.
  * Fixed `Music.currentposition`.
  * Fixed autocomplete issues in HaxeDevelop with `Text.display()`.

*(For a full update history, see <a href="https://github.com/TerryCavanagh/haxegon/blob/master/changelog.md">the changelog</a>.)*
