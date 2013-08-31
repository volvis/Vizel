package org.aijai.vizel;


/**
 * ...
 * @author Pekka Heikkinen
 */
class VizelCore
{
	private var source:Array<String>;
	public var lineNumber:Int;
	
	public function new(sourceText:String) 
	{
		source = sourceText.split("\n");
		lineNumber = 0;
	}
	
	public function iterator():Iterator<VizelLineType>
	{
		return this;
	}
	
	public function hasNext():Bool
	{
		return lineNumber < source.length;
	}
	
	public function next():VizelLineType
	{
		var filepos = lineNumber;
		var lineSource:String = source[lineNumber++];
		var src:String = StringTools.trim(lineSource);
		
		if (!~/\w/.match(lineSource))
		{
			return VizelLineType.EMPTY(src, filepos);
		}
		
		var numTabs:Int = countStartingTabs(lineSource);
		
		if (numTabs == 0)
		{
			var eventExpr:EReg = ~/^\w+/;
			if (eventExpr.match(lineSource))
			{
				return VizelLineType.EVENT(src, filepos);
			}
			var locationExpr:EReg = ~/^INT\.|EXT\./;
			if (locationExpr.match(lineSource))
			{
				return VizelLineType.LOCATION(src, filepos);
			}
			var conditionExpr:EReg = ~/^COND\./;
			if (conditionExpr.match(lineSource))
			{
				return VizelLineType.CONDITIONAL(src, filepos);
			}
		}
		else if (numTabs == 1)
		{
			return VizelLineType.DIALOGUE(src, filepos);
		}
		else if (numTabs == 2)
		{
			return VizelLineType.ACTOR(src, filepos);
		}

		return VizelLineType.UNKNOWN(lineSource, filepos);
	}
	
	private function capitalize(str:String):String
	{
		str = StringTools.trim(str);
		return str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();
	}
	
	private function countStartingTabs(str):Int
	{
		var tabs:Int = 0;
		var spacesPerTab:Int = 4;
		if (str.charCodeAt(0) == 9)
		{
			while (str.charCodeAt(tabs) == 9)
			{
				tabs++;
			}
		}
		else if (str.charCodeAt(0) == 32)
		{
			while (str.charCodeAt(tabs*spacesPerTab) == 32)
			{
				tabs++;
			}
		}
		return tabs;
	}
	
	private function collectKeywords(source:String)
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