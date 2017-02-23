package ;



import flash.display.Loader;
import flash.events.Event;
import flash.Lib;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

@:file("../stringecho.swf") class Alchemy_Lib extends flash.utils.ByteArray{}
/**
对于 以 loader 的形式加载 alchemy生成的 swc, 应该使用另一个叫 alc-asc 的 脚本,
以便得到的 swc 文件更小

*/
class EchoTestLoader{

	static var loader:Loader;
	static var cLibInit:CLibInit;
	static var clib:Dynamic;
	static public function main():Void {
		loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _loaded);
		loader.loadBytes(new Alchemy_Lib());
	}

	static function _loaded(evt:Event):Void {
		//Lib.current.addChild(loader);

		cLibInit = Type.createInstance(loader.contentLoaderInfo.applicationDomain.getDefinition("cmodule.stringecho.CLibInit"), []);

		clib = cLibInit.init();
		// 注意: 以 loader 形式加载的 domainMemory, 并不等于 当前 applicationDomain
		//var state = loader.contentLoaderInfo.applicationDomain.getDefinition("cmodule.stringecho::gstate");
		//trace(state.ds == loader.contentLoaderInfo.applicationDomain.domainMemory); // true
		// 如上边示例, 这样就可以混合 haxe::flash.Memory 和 alchemy 一起编程了.
	}
}


// 由于 flash 库是以 loader 的形式加载的, 所以不可以用 extern class 的形式来描述.
typedef CLibInit = {
	/**
	  初使化, 也就是调用 c 胶水函数中的 init
	*/
	function init():Dynamic;
	/**

	* @param path 自定义一个文件名, 这样编译成 SWC 的 c 语言中 可以调用文件函数调用 open(path,)
	* @param data 文件名相关
	*/
	function supplyFile(path:String, data:flash.utils.ByteArray):Void;

	/**
	  提供一个 mc 对象, 用于 c语言, alchemy 将会正确创建 TextField 	用于 stdout/stderr
	* @param sprite
	*/
	function setSprite(sprite:flash.display.Sprite):Void;

	/**
	  设置环境变量.	好像没什么用处这个方法.
	* @param key
	* @param value
	*/
	function putEnv(key:String, value:String):Void;
}