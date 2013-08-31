package org.aijai.vizel.interfaces;

/**
 * ...
 * @author Pekka Heikkinen
 */
interface IAssetProvider
{

	public function getActor(Keywords:Array<String>):String;
	public function getBackground(Keywords:Array<String>):String;
	
}