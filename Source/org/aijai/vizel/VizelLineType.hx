package org.aijai.vizel;

/**
 * ...
 * @author Pekka Heikkinen
 */

enum VizelLineType
{
	UNKNOWN(source:String, position:Int);
	EMPTY(source:String, position:Int);
	LOCATION(source:String, position:Int);
	CONDITIONAL(source:String, position:Int);
	ACTOR(source:String, position:Int);
	DIALOGUE(source:String, position:Int);
	EVENT(source:String, position:Int);
}