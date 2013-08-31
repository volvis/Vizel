package org.aijai.vizel;
import org.aijai.vizel.interfaces.IAssetProvider;

/**
 * ...
 * @author Pekka Heikkinen
 */
class VizelLogic
{
	public var core:Iterable<VizelLineType>;
	
	public var assetProvider:IAssetProvider;
	
	private var lastSpeaker:String;
	
	public function new() 
	{
	}
	
	public function loadSource(source:String):Void
	{
		core = new VizelCore(source);
	}
	
	public function loadCore(source:Iterable<VizelLineType>):Void
	{
		core = source;
	}
}