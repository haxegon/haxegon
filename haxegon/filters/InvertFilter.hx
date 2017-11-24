package haxegon.filters;

import starling.textures.Texture;

import flash.display3D.Context3D;
import flash.display3D.Program3D;
import openfl.display3D.Context3DProgramType;
import openfl.Vector;

/* TO DO: This is broken now */
class InvertFilter extends BaseFilter {
	public function new() {
	  super();	
	}
	
	override public function setAgal() {
		FRAGMENT_SHADER =
	  "tex ft0, v0, fs0 <2d, clamp, linear, mipnone>  \n" + // read texture color
		"max ft0, ft0, fc1             								  \n" + // avoid division through zero in next step
		"div ft0.xyz, ft0.xyz, ft0.www 									\n" + // restore original (non-PMA) RGB values
		"sub ft0.xyz, fc0.xyz, ft0.xyz  								\n" + // subtract rgb values from '1'
		"mul ft0.xyz, ft0.xyz, ft0.www  								\n" + // multiply with alpha again (PMA)
		"mov oc, ft0                    								\n";  // copy to output
	}
	
	override public function activate(pass:Int, context:Context3D, texture:Texture) {
		context.setProgramConstantsFromVector(
      Context3DProgramType.FRAGMENT, 0, Vector.ofArray(cast [1.0, 1.0, 1.0, 1.0])); //fc0
		context.setProgramConstantsFromVector(
      Context3DProgramType.FRAGMENT, 1, Vector.ofArray(cast [0, 0, 0, 0.0001])); //fc1
		super.activate(pass, context, texture);
	}
}