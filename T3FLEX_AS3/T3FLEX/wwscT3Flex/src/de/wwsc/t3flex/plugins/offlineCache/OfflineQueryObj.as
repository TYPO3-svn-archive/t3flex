package de.wwsc.t3flex.plugins.offlineCache
{
import mx.rpc.http.HTTPService;

public class OfflineQueryObj
{
	public static const DATABASE_CALL : String = "DB"
	
	public static const IMAGE_CALL : String = "IMG"
	
	public static const VIDEO_CALL : String = "VIDEO"
	public static const FILE_CALL : String = "FILE"
	
	public var callback : Function;
	
	public var type : String
	
	public var gateway : HTTPService;
	
	public var t3FlexQueryStr : String
	
	public var parameters : Object
	
	public var target : *;
	
	//public var myCacheObject.dataService = this;
	//public var resultFunction : Function;
	
	public function OfflineQueryObj()
	{
	}
}
}