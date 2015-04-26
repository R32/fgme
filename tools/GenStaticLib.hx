package;


import sys.FileSystem;
import haxe.Template;
import haxe.Resource;
import sys.io.File;

class GenStaticLib{

	public static function main() {
		var files:Array<String>;
		var path = "../project/";
		var gme_files = path + "gme-master/gme";
		var out_xml = path + "build.xml";
		
		if (FileSystem.exists(gme_files) && FileSystem.isDirectory(gme_files)) {
			
			files = FileSystem.readDirectory(gme_files).filter(function(name){
				return StringTools.endsWith(name, ".cpp");
			});
			
			var tp = new Template(Resource.getString("xmltp"));
			
			File.saveContent(out_xml, tp.execute(files));
			Sys.println("save as " +out_xml);
			
			var resdir = Sys.getCwd();
			Sys.setCwd(path);
			Sys.command("haxelib", ["run","hxcpp","build.xml"]);
			Sys.setCwd(resdir);
		}else{
			Sys.println('lscpp: No such directory - "' + gme_files +'"' );
		}
		Sys.command("pause");
	}
}
