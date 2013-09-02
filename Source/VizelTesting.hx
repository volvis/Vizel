package;


import flash.display.Sprite;
import flash.Lib;
import org.aijai.vizel.modules.AssetFilter;
import org.aijai.vizel.modules.LineReader;
import openfl.Assets;
import org.aijai.vizel.Vizel;

class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		var vL:Vizel = new Vizel();
		vL.lineReader = new LineReader(Assets.getText("assets/sample/scripts/Opening.txt"));
		vL.assetFilter = new AssetFilter(Assets.type.keys());
		vL.actorNames = [
			"SHIMON" => "Shimon",
			"SCONE" => "Scone"
		];
		
		for (c in vL)
		{
			
			trace(c);
			for (cmd in c)
			{
				switch(cmd)
				{
					case SetOptions(options):
						vL.setOption(options[Math.round(Math.random())]);
					default: null;
				}
			}
		}
		
		//vL.load(Assets.getText("assets/sample/Opening.txt"));
		/*var kw:AssetProvider = new AssetProvider();
		kw.load(Assets.type.keys());
		trace(kw.getBackground(["Shimon"]));*/
		//trace(kw.requestShortestMatch(["Shimon"], ["character", "milffk"]));
		/*var vc:VizelCore = new VizelCore( Assets.getText("assets/sample/Opening.txt"));
		for (l in vc)
		{
			trace(l);
		}*/
		//new Vizel();
		/*trace('ay');
		trace(Std.parseInt(Vizel.configuration.request("color", "default")));*/
		//var sp:Keywords = Keywords.fromString("Hello harry, how are you?");
		/*var ak:AssetKeywords = new AssetKeywords();
		var k = ak.request("Hello, I am Sam!");
		trace(k);*/
		//AssetKeywords.request("Hello Sam, at night");
	}
	
	
}