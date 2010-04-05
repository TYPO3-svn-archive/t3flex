package de.wwsc.t3flex.plugins.offlineCache
{
	import de.wwsc.t3flex.T3Flex;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class OfflineCacheJob
	{
		private var _controller : OfflineCacheController

		private var _offlineCacheDataQueryObj : OfflineQueryObj;

		private function getFileFromDiscErrorHander( e : IOErrorEvent ) : void
		{
			//Alert.show( "File is missing: \n" + _offlineCacheDataQueryObj.t3FlexQueryStr + "\n" + _controller.translateID( _offlineCacheDataQueryObj.t3FlexQueryStr ),"Error" );
		}

		private function fileCompleteHandler( e : Event ) : void
		{
			var value : * = e.target.data;
			if ( _offlineCacheDataQueryObj.type == OfflineQueryObj.DATABASE_CALL )
			{
				var bytes : ByteArray = value;
				var obj : * = bytes.readObject();
				_offlineCacheDataQueryObj.callback( deserialize( obj ));
			}

			if ( _offlineCacheDataQueryObj.type == OfflineQueryObj.IMAGE_CALL )
			{
				_offlineCacheDataQueryObj.target.source = value;
			}
			if (  _offlineCacheDataQueryObj.type == OfflineQueryObj.FILE_CALL )
			{
				var url: String = "t3FlexCache/"+_controller.translateID(_offlineCacheDataQueryObj.t3FlexQueryStr);
				trace( this,"FileLoaded",url,_offlineCacheDataQueryObj.t3FlexQueryStr );
				_offlineCacheDataQueryObj.target.source = url;
				if (_offlineCacheDataQueryObj.callback())
					_offlineCacheDataQueryObj.callback();
			}
		}

// Public 	
		public function OfflineCacheJob( controller : OfflineCacheController,query : OfflineQueryObj )
		{
			_controller = controller;
			_offlineCacheDataQueryObj = query;
			getFileFromDisc( _offlineCacheDataQueryObj.t3FlexQueryStr )

		}

		private function getFileFromDisc( t3FlexQueryString : String ) : void
		{
			var urlLoader : URLLoader = new URLLoader();
			var baseUrl : String = T3Flex.getInstance().swfBaseDir;
			urlLoader.addEventListener( Event.COMPLETE,fileCompleteHandler );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR,getFileFromDiscErrorHander );
			urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,getFileFromDiscErrorHander );
			var path : URLRequest = new URLRequest( baseUrl + _controller.dirName + "/" + _controller.translateID( t3FlexQueryString ));
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			if (T3Flex.getInstance().config.debug)
				trace( "getFileFromDisc: ",this,path.url,baseUrl );
			//Alert.show( path.url,baseUrl )
			urlLoader.load( path );
		}

		private function deserialize( obj : * ) : *
		{
			var toret : Object = {};

			toret.isError = false;
			toret.metadata = obj.metadata;
			toret.data = obj.data;
			toret.fromOfflineCache = true;

			return toret;
		}
	}
}

