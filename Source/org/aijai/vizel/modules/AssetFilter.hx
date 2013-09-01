package org.aijai.vizel.modules;
import haxe.ds.ArraySort;

/**
 * ...
 * @author Pekka Heikkinen
 */

interface IAssetFilter
{
	public function getActor(Keywords:Array<String>):String;
	public function getBackground(Keywords:Array<String>):String;
	public function getScript(Keywords:Array<String>):String;
}

class AssetFilter implements IAssetFilter
{
	private var keywords:Map < String, Array<Int> > ;
	private var source:Array<String>;
	
	public function new(Source:Iterator<String>) {
		load(Source);
	}
	
	/**
	 * Insert the list of assets to search from.
	 * For example, if using OpenFL, insert <code>openfl.Assets.type.keys()</code>.
	 * By inserting this manually you can, for example, filter out assets you don't want.
	 * 
	 * @param	Source
	 */
	private function load(Source:Iterator<String>):Void
	{
		source = [];
		keywords = new Map < String, Array<Int> > ();
		var splitExpression:EReg = ~/[!_ .,:;\/]+/g;
		for (asset in Source)
		{
			source.push(asset);
			var sp:Array<String> = splitExpression.split(asset);
			for (key in sp)
			{
				key = key.toLowerCase();
				if (keywords.exists(key) == false)
				{
					keywords.set(key, [source.length-1]);
				}
				else
				{
					var srcIndex:Int = source.length - 1;
					var src:Array<Int> = keywords.get(key);
					if (Lambda.indexOf(src, srcIndex) == -1)
					{						
						keywords.get(key).push(source.length-1);
					}
				}
			}
		}
	}
	
	public function getScript(Keywords:Array<String>):String
	{
		return get(Keywords, sortFromScript);
	}
	
	public function getActor(Keywords:Array<String>):String
	{
		return get(Keywords, sortFromCharacter);
	}
	
	public function getBackground(Keywords:Array<String>):String
	{
		return get(Keywords, sortFromBackground);
	}
	
	/**
	 * Do a keyword lookup from an array of keys.
	 * @param	lookFor	Array<String> of keywords to look for
	 * @param	sort	Optional sorting function for the results
	 * @return
	 */
	private function get(Keywords:Array<String>, Sort:String->String->Int = null):String
	{
		var matches:Map<Int, Int> = new Map<Int, Int>();
		
		for (keyUppercase in Keywords)
		{
			var key:String = keyUppercase.toLowerCase();
			if (keywords.exists(key))
			{
				for (asset in keywords.get(key))
				{
					
					if (matches.exists(asset) == false)
					{
						matches.set(asset, 0);
					}
					matches.set(asset, matches.get(asset) + 1);
				}
			}
		}
		
		var matchRoof:Int = 1;
		var numMatches:Int = 0;
		var bestMatches:Array<Int> = [];
		for (asset in matches.keys())
		{
			numMatches = matches.get(asset);
			if (numMatches == matchRoof)
			{
				bestMatches.push(asset);
			}
			else if (numMatches > matchRoof)
			{
				bestMatches = [asset];
				matchRoof = numMatches;
			}
		}
		
		var assetList:Array<String> = Lambda.array( Lambda.map(bestMatches, function(i) { return source[i]; } ) );
		if (Sort != null)
		{
			ArraySort.sort(assetList, Sort);
		}
		return assetList[0];
	}
	
	private function sortFromBackground(a:String, b:String):Int
	{
		var keywordSort:Int = sortByEreg(a, b, ~/background.+png$/);
		if (keywordSort == 0) return sortByFilename(a, b); else return keywordSort;
	}
	
	private function sortFromCharacter(a:String, b:String):Int
	{
		var keywordSort:Int = sortByEreg(a, b, ~/character.+png$/);
		if (keywordSort == 0) return sortByFilename(a, b); else return keywordSort;
	}
	
	private function sortFromScript(a:String, b:String):Int
	{
		var keywordSort:Int = sortByEreg(a, b, ~/script.+txt$/);
		if (keywordSort == 0) return sortByFilename(a, b); else return keywordSort;
	}
	
	private function sortByEreg(a:String, b:String, expr:EReg):Int
	{
		var aBG:Bool = expr.match(a);
		var bBG:Bool = expr.match(b);
		if (aBG == false && bBG != false) return 1;
		if (aBG != false && bBG == false) return -1;
		return 0;
	}
	
	private function sortByKeyword(a:String, b:String, key:String):Int
	{
		var aBG:Int = a.indexOf(key);
		var bBG:Int = b.indexOf(key);
		if (aBG == -1 && bBG != -1) return 1;
		if (aBG != -1 && bBG == -1) return -1;
		return 0;
	}
	
	private function sortByFilename(a:String, b:String):Int
	{
		var aLen:Int = a.length - a.lastIndexOf("/");
		var bLen:Int = b.length - b.lastIndexOf("/");
		if (aLen > bLen)
		{
			return 1;
		}
		if (aLen < bLen)
		{
			return -1;
		}
		return 0;
	}
	
}