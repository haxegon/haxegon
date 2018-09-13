package haxegon;

import openfl.errors.ArgumentError;

class Scene {
	private static function init() {
		scenelist = [];
		currentscene = 0;
		
		var maininstance:Dynamic = null; 
		
		try{
			maininstance = Type.createInstance(Main, []);
		}catch (e:Dynamic){
			maininstance = Type.createEmptyInstance(Main);
	  }
		
		scenelist.push(maininstance);
		callscenemethod(scenelist[currentscene], "init");
		
		checkforrenderfunction();
	}
	
	public static function restart<T>(scenetorestart:Class<T>) {
		var sceneid:Int = -1;
		for (i in 0 ... scenelist.length) {
			if (scenetorestart == Type.getClass(scenelist[i])) {
				sceneid = i;
				break;
			}
		}
		
		if (sceneid == -1){
			//Easy, the scene hasn't been run yet. Do nothing - it'll be init when it's created.
		}else{
			//Create a new scene instance replacing the current one
			scenelist[sceneid] = Type.createInstance(scenetorestart, []);
			callscenemethod(scenelist[currentscene], "init");
		}
	}
	
	private static function checkforrenderfunction() {
		//When we change to a scene, check if this class contains a "render" method.
		//If so, allow seperation of update and render
		hasseperaterenderfunction = (Reflect.field(scenelist[currentscene], "render") != null);
		if (!hasseperaterenderfunction) {
		  //Also check for the static function
		  hasseperaterenderfunction = (Reflect.field(Type.getClass(scenelist[currentscene]), "render") != null);
		}
	}
	
	private static function update() {
		callscenemethod(scenelist[currentscene], "update");
	}
	
	private static function render() {
		callscenemethod(scenelist[currentscene], "render");
	}
	
	private static function callscenemethod(scene:Dynamic, method:String, ?pos:haxe.PosInfos) {
		var instanceFunc:Dynamic = Reflect.field(scene, method);
		if (instanceFunc != null && Reflect.isFunction(instanceFunc)) {
			try {
				Reflect.callMethod(scene, instanceFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "ERROR in callscenemethod("+scene+","+method+"): Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments.");
			} catch (msg:Dynamic ) {
				var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				throw( "ERROR in callscenemethod("+scene+","+method+") instance : " + msg + ", stack = " + stack);
			}
			return;
		}
		
		// Now try the static method
		var classFunc:Dynamic = Reflect.field(Type.getClass(scene), method);
		if (classFunc != null && Reflect.isFunction(classFunc)) {
			try {
				Reflect.callMethod(scene, classFunc, []);
			} catch ( e:ArgumentError ) {
				throw( "ERROR in callscenemethod("+scene+","+method+"): Couldn't call " + Type.getClassName(scene) + "." + method + "() without any arguments.");
			} catch ( msg:Dynamic ) {
				var stack = haxe.CallStack.toString(haxe.CallStack.exceptionStack());
				throw( "ERROR in callscenemethod("+scene+","+method+") static : " + msg + ", stack = " + stack);
			}
			return;
		}
	}
	
	private static function findscene<T>(findscene:Class<T>):Int {
		for (i in 0 ... scenelist.length) {
			if (findscene == Type.getClass(scenelist[i])) {
				return i;
			}
		}
		
		var newscene:Dynamic = null; 
		
		try{
			newscene = Type.createInstance(findscene, []);
		}catch (e:Dynamic){
			newscene = Type.createEmptyInstance(findscene);
	  }
		
		scenelist.push(newscene);
		
		return scenelist.length - 1;
	}
	
	public static function change<T>(newscene:Class<T>):T {
		currentscene = findscene(newscene);
		if (currentscene == scenelist.length - 1){
			callscenemethod(scenelist[currentscene], "init");
		}else{
			callscenemethod(scenelist[currentscene], "reset");
		}
		
		checkforrenderfunction();
		
		return cast scenelist[currentscene];
	}
	
	private static function get<T>(requiredscene:Class<T>):T {
		return cast scenelist[findscene(requiredscene)];
	}
	
	private static function getcurrentsceneclass():Dynamic {
		return cast scenelist[currentscene];
	}
	
	private static var scenelist:Array<Dynamic>;
	private static var currentscene:Int;
	private static var hasseperaterenderfunction:Bool;
}
