package org.aijai.vizel.utils;

/**
 * ...
 * @author Pekka Heikkinen
 */
class VizelString
{

	public function new() 
	{
		
	}
	
	public static function lineFromOption(str:String):String
	{
		return str.split(" > ")[0];
	}
	
	public static function capitalize(str:String):String
	{
		str = StringTools.trim(str);
		return str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();
	}
	
	public static function collectKeywords(source:String):Array<String>
	{
		var collection:Array<String> = [];
		var keywordExpr:EReg = ~/[A-Z]{2,}/;
		
		var positionExpr: { pos:Int, len:Int } = {pos:0, len:0};
		
		while (keywordExpr.matchSub(source, positionExpr.pos+positionExpr.len))
		{
			positionExpr = keywordExpr.matchedPos();
			collection.push(source.substring(positionExpr.pos, positionExpr.pos + positionExpr.len));
		}
		return collection;
	}
	
}