package haxegon.filters;

import starling.filters.FragmentFilter;
import starling.textures.Texture;

import flash.display3D.Context3D;
import flash.display3D.Program3D;

class BaseFilter extends FragmentFilter {
	// Shaders
	public var FRAGMENT_SHADER:String;
	public var VERTEX_SHADER:String;
	
	/** Program 3D */
	public var program:Program3D;
	
	/** @private */
	public function new() {
		super(1, 1.0);
	}
	
	/** Dispose */
	override public function dispose(){
		if (this.program != null) this.program.dispose();
		
		super.dispose();
	}
	
	/** Create Programs */
	override public function createPrograms(){
		setAgal();
		this.program = assembleAgal(FRAGMENT_SHADER, VERTEX_SHADER);
	}
	
	/** Set AGAL */
	public function setAgal(){
		// Override this to assign values to FRAGMENT_SHADER and VERTEX_SHADER
	}
	
	/** Activate */
	override public function activate(pass:Int, context:Context3D, texture:Texture){
		context.setProgram(this.program);
	}
}