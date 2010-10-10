package de.wwsc.t3flex.events
{
	import flash.events.Event;

	public class T3FlexEvent extends Event
	{
		public static const LOADING : String = "LOADING";


		public static const LOADING_COMPLETE : String = "LOADING_COMPLETE";

		public static const LOADING_ERROR : String = "LOADING_ERROR";

		public static const PARSING_DATA_START : String = "PARSING_DATA_START";

		public static const ERROR : String = "ERROR";

		public static const IMAGE_LOADED : String = "IMAGE_LOADED";

		public static const IMAGE_ERROR_NOT_SUPPORTED_FILEFORMAT : String = "IMAGE_ERROR_NOT_SUPPORTED_FILEFORMAT";

		public static const IMAGE_OFFLINECACHE_LOOK_UP : String = "IMAGE_OFFLINECACHE_LOOK_UP";

		public static const FILE_OFFLINECACHE_LOOK_UP : String = "FILE_OFFLINECACHE_LOOK_UP";

		public static const LANGUAGEOVERLAY_CREATED : String = "LANGUAGEOVERLAY_CREATED";

		public static const DATASERVICE_OFFLINECACHE_LOOK_UP : String = "DATASERVICE_OFFLINECACHE_LOOK_UP";

		public static const DATASERVICE_OFFLINECACHE_RETURN_RESULT : String = "DATASERVICE_OFFLINECACHE_RETURN_RESULT";

		public static const DATASERVICE_AUTHORIZATION_FAILED : String = "DATASERVICE_AUTHORIZATION_FAILED";

		public static const DATASERVICE_GATEWAY_SEND : String = "DATASERVICE_GATEWAY_SEND";

		public static const CACHE_INIT : String = "CACHE_INIT";

		public static const MODEL_PAGESARR_CHANGED : String = "MODEL_PAGESARR_CHANGED";

		public static const MODEL_TTCONTENTARR_CHANGED : String = "MODEL_TTCONTENTARR_CHANGED";

		public static const PAGETREE_REFRESHED : String = "PAGETREE_REFRESHED";

		public var info : Object;

		public function T3FlexEvent( $type : String,$info : Object=null,$bubbles : Boolean=true,$cancelable : Boolean=false )
		{
			super( $type,$bubbles,$cancelable );
			this.info = $info;
		}

		public override function clone() : Event
		{
			return new T3FlexEvent( this.type,this.info,this.bubbles,this.cancelable );
		}

	}
}

