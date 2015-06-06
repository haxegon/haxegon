package terrylib;

//From Arne's legendary 16 colour palette: http://androidarts.com/palette/16pal.htm

class Col {
	public static var BLACK:Int = 0xFF000000;
	public static var GREY:Int = 0xFF9D9D9D;
	public static var GRAY:Int = 0xFF9D9D9D;
	#if !flash
	  public static var WHITE:Int = 0xFFFFFFFF;
	#else
	  public static var WHITE:Int = 0xFFFFFF;
	#end
	public static var RED:Int = 0xFFBE2633;
	public static var PINK:Int = 0xFFE06F8B;
	public static var DARKBROWN:Int = 0xFF493C2B;
	public static var BROWN:Int = 0xFFA46422;
	public static var ORANGE:Int = 0xFFEB8931;
	public static var YELLOW:Int = 0xFFF7E26B;
	public static var DARKGREEN:Int = 0xFF2F484E;
	public static var GREEN:Int = 0xFF44891A;
	public static var LIGHTGREEN:Int = 0xFFA3CE27;
	public static var NIGHTBLUE:Int = 0xFF1B2632;
	public static var DARKBLUE:Int = 0xFF005784;
	public static var BLUE:Int = 0xFF31A2F2;
	public static var LIGHTBLUE:Int = 0xFFB2DCEF;
	public static var MAGENTA:Int = 0xFFFF00FF;
}