package de.wwsc.t3flex.plugins.offlineCache
{
import de.wwsc.t3flex.T3Flex;
import de.wwsc.t3flex.events.T3FlexEvent;

public class OfflineCacheController
{
	
	public var dirName : String = "t3flexcache";
	
	public var enableSwfStandalonePlayer : Boolean = false;
	
// private functions
	private function getFileFromDisc( e : T3FlexEvent ) : void
	{
		var query : OfflineCacheJob = new OfflineCacheJob( this,e.info as OfflineQueryObj )
	}
	
// Public	
	public function OfflineCacheController()
	{
	
	}
	
	public function start() : void
	{
		T3Flex.getInstance().addEventListener( T3FlexEvent.DATASERVICE_OFFLINECACHE_LOOK_UP,getFileFromDisc );
		T3Flex.getInstance().addEventListener( T3FlexEvent.IMAGE_OFFLINECACHE_LOOK_UP,getFileFromDisc );
		T3Flex.getInstance().addEventListener( T3FlexEvent.FILE_OFFLINECACHE_LOOK_UP,getFileFromDisc );
	}
	
	public function translateID( originalStr : String ) : String
	{
		var str : String = "";
		var reg : RegExp = new RegExp( "[^a-z,0-9,.]","gi" )
		str = originalStr.replace( reg,"" )
		//str += ".t3flex"
		return str;
	}

}
}