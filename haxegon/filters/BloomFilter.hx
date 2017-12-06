/**
 *	Copyright (c) 2014 Devon O. Wolfgang
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

/**
 * Produces a Bloom/Glow effect with adjustable color properties.
 * @author Devon O.
 */
package haxegon.filters;

import openfl.display3D.*;
import openfl.errors.*;
import openfl.Vector;

import starling.rendering.*;
import starling.filters.*;
import starling.utils.Color;

class Bloomfilter extends FragmentFilter{
	public var _red:Float = 1;
	public var red(get, set):Float;
	function get_red():Float { return _red; }
  function set_red(_r:Float):Float {
		_red = _r;
		if(actualeffect != null) cast(actualeffect, BloomEffect).red = _red;
		
	  return _red;
	}
	
	public var _green:Float = 1;
	public var green(get, set):Float;
	function get_green():Float { return _green; }
  function set_green(_g:Float):Float {
		_green = _g;
		if(actualeffect != null) cast(actualeffect, BloomEffect).green = _green;
		
	  return _green;
	}
	
	public var _blue:Float = 1;
	public var blue(get, set):Float;
	function get_blue():Float { return _blue; }
  function set_blue(_b:Float):Float {
		_blue = _b;
		if(actualeffect != null) cast(actualeffect, BloomEffect).blue = _blue;
		
	  return _blue;
	}
	
	public var _blur:Float = 2;
	public var blur(get, set):Float;
	function get_blur():Float { return _blur; }
  function set_blur(_b:Float):Float {
		_blur = _b;
		if(actualeffect != null) cast(actualeffect, BloomEffect).blur = _blur;
		
	  return _blur;
	}

	public function new(){
		super();
	}
	
	/** @private */
	override private function createEffect():FilterEffect{
		actualeffect = new BloomEffect(blur, red, green, blue);
		return actualeffect;
	}
	
	private var actualeffect:FilterEffect;
}

class BloomEffect extends FilterEffect {
 	private var fc0:Vector<Float>;
	private var fc1:Vector<Float>;
	private var _color:Vector<Float>;
	
	public var red:Float;
	public var green:Float;
	public var blue:Float;
	
	public var blur:Float;
	
	/**
	 * Create a new BloomFilter
	 * @param blur          amount of blur
	 * @param red           red value
	 * @param green         green value
	 * @param blue          blue value
	 * @param numPasses     number of passes this filter should apply (1 pass = 1 drawcall)
	 */
	public function new(_blur:Float = 2, _red:Float = 1, _green:Float = 1, _blue:Float = 1, numPasses:Int = 1) {
	  super();
		
		blur = _blur;
		red = _red;
		green = _green;
		blue = _blue;
		
		//this.numPasses = numPasses;
		
		fc0 = Vector.ofArray(cast [0, 0, 0, 2.5]);
		fc1 = Vector.ofArray(cast [-1.0, 0.0, 1.0, 9.0]);
		_color = Vector.ofArray(cast [1.0, 1.0, 1.0, 1.0]);
	}
  
  override private function createProgram():Program {
		var vertexShader:String = FilterEffect.STD_VERTEX_SHADER;
		var fragmentShader:String = 
		//original texture
		"tex ft0, v0, fs0<2d, clamp, linear, mipnone>  \n" +
		
		//output
		"mov ft1, fc0.xxxx  \n" +
		
		//size
		"mov ft2.x, fc0.y  \n" +
		"mul ft2.x, ft2.x, fc0.w  \n" +
		"div ft2.x, fc1.z, ft2.x  \n" + //rcp isn't working? line should be "rcp ft2.x, ft2.x"
		"mov ft2.y, fc0.z  \n" +
		"mul ft2.y, ft2.y, fc0.w  \n" +
		"div ft2.y, fc1.z, ft2.y  \n" + //rcp isn't working? line should be "rcp ft2.y, ft2.y"
		// START UNWRAPPED LOOP
		
		//1
		"mov ft3.xy, fc1.xx  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//2
		"mov ft3.xy, fc1.xy  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//3
		"mov ft3.xy, fc1.xz  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//4
		"mov ft3.xy, fc1.yx  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//5
		"mov ft3.xy, fc1.yy  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//6
		"mov ft3.xy, fc1.yz  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//7
		"mov ft3.xy, fc1.zx  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//8
		"mov ft3.xy, fc1.zy  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		//9
		"mov ft3.xy, fc1.zz  \n" +
		"mul ft3.xy, ft3.xy, ft2.xy  \n" +
		"add ft3.xy, ft3.xy, v0.xy  \n" +
		"tex ft4, ft3.xy, fs0<2d, clamp, linear, mipnone>  \n" +
		"add ft1, ft1, ft4  \n" +
		
		// END LOOP
		
		// average out
		"div ft1, ft1, fc1.wwww  \n" +
		"add ft1, ft1, ft0  \n" +
		
		// multiply by color
		"mul oc, ft1, fc2";
		
    return Program.fromSource(vertexShader, fragmentShader);
  }

  override private function beforeDraw(context:Context3D):Void {
		fc0[1] = texture.width;
		fc0[2] = texture.height;
		fc0[3] = 1 / blur;
		
		_color[0] = red;
		_color[1] = green;
		_color[2] = blue;
		
		super.beforeDraw(context);
    
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fc0);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, fc1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _color);
  }
}