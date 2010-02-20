package de.wwsc.t3flex.vo.t3Standards
{

	import de.wwsc.shared.WwscHelper;
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.events.T3FlexEvent;
	import de.wwsc.t3flex.plugins.offlineCache.OfflineQueryObj;
	import de.wwsc.t3flex.vo.T3FlexConfiguration;

	import flash.display.Bitmap;
	import flash.events.Event;

	import mx.controls.Image;
	import mx.events.FlexEvent;

	public class T3Image extends Image
	{

		//private var myDataConfig:DataConfig = new DataConfig;
		[Bindable]
		private var _baseUrl : String;

		private var _noCacheStr : String;

		private var _typeStr : String;

		private var _nameOfExtension : String;

		private var _basicPIDStr : String;

		private var _widthParameter : String = _nameOfExtension + "[w]=";

		private var _heigthParameter : String = _nameOfExtension + "[h]=";

		private var _imgParameter : String = _nameOfExtension + "[img]=";

		private var _enableBitmapSmoothing : Boolean = false;

		private var _fullUrl : String = "";

		private var imgUrl : String;

		public static const UPLOAD_DIR_TV : String = "tx_templavoila/";

		public static const UPLOAD_DIR_FE_USER : String = "tx_srfeuserregister/";

		public static const UPLOAD_DIR_TT_NEWS : String = "pics/";

		public static const UPLOAD_DIR_PAGE : String = "media/";

		[Bindable]
		public var filename : String;

		[Bindable]
		public var type : String;

		[Bindable]
		public var description : String;

		[Bindable]
		public var imageLink : String;

		private function init() : void
		{
			var mySite : T3FlexConfiguration = T3Flex.getInstance().config;
			_baseUrl = mySite.baseUrl;
			_typeStr = "type=" + mySite.baseTypeImages;
			_noCacheStr = "no_cache=" + mySite.noCacheOfRequests;
			_nameOfExtension = mySite.extensionName;
			_basicPIDStr = "id=" + mySite.baseSitePid;
			_widthParameter = _nameOfExtension + "[w]=";
			_heigthParameter = _nameOfExtension + "[h]=";
			_imgParameter = _nameOfExtension + "[img]=";

		}

		public function setImage( imgName : String,imgWidth : Number=-1,imgHeight : Number=-1,proportion : String="m",uploadDir : String="tx_templavoila/",enableBitmapSmoothing : Boolean=false ) : void
		{
			if ( imgName != "" )
			{
				_enableBitmapSmoothing = enableBitmapSmoothing;
				if ( imgHeight == -1 )
				{
					imgHeight = height;
				}
				if ( imgWidth == -1 )
				{
					imgWidth = width;
				}

				_fullUrl = getUrlOfImage( imgName,imgHeight,imgWidth,proportion,uploadDir );

				if ( T3Flex.getInstance().config.enableOfflineCache )
				{
					var obj : OfflineQueryObj = new OfflineQueryObj()
					obj.t3FlexQueryStr = _fullUrl;
					obj.target = this;
					obj.type = OfflineQueryObj.IMAGE_CALL;
					obj.callback = fireEvent;
					T3Flex.getInstance().dispatchEvent( new T3FlexEvent( T3FlexEvent.IMAGE_OFFLINECACHE_LOOK_UP,obj ));
				}
				else
				{
					{
						if ( T3Flex.getInstance().model.bulkLoader.hasItem( _fullUrl ))
						{
							var bitmap : Bitmap = T3Flex.getInstance().model.bulkLoader.getBitmap( _fullUrl,false )
							if ( bitmap )
							{
								if ( bitmap.bitmapData )
								{
									this.source = bitmap
									var wwsc : WwscHelper = new WwscHelper;
									wwsc.delay( 100,fireEvent )
								}
								else
								{
									T3Flex.getInstance().model.bulkLoader.remove( _fullUrl );
									T3Flex.getInstance().model.bulkLoader.add( _fullUrl,{ type:"image",
											priority:250 });
									T3Flex.getInstance().model.bulkLoader.get( _fullUrl ).addEventListener( Event.COMPLETE,loadingCompleteHandler );
								}
							}
						}
						else
						{
							T3Flex.getInstance().model.bulkLoader.add( _fullUrl,{ type:"image",
									priority:250 });
							T3Flex.getInstance().model.bulkLoader.get( _fullUrl ).addEventListener( Event.COMPLETE,loadingCompleteHandler );

						}
					}
				}
			}
		};

		private function loadingCompleteHandler( e : Event ) : void
		{
			var test : * = T3Flex.getInstance().model.bulkLoader.getBitmap( _fullUrl )
			this.source = test;
			updateCompleteHandler( new FlexEvent( "" ))
		}

		private function updateCompleteHandler( e : FlexEvent ) : void
		{
			//this.removeEventListener( FlexEvent.ENTER_FRAME,updateCompleteHandler )
			if ( _enableBitmapSmoothing )
			{
				smoothImage();

			}
			else
			{
				fireEvent();
			}

			// fire, when Image was loaded
		}

		public function fireEvent() : void
		{
			this.dispatchEvent( new T3FlexEvent( T3FlexEvent.IMAGE_LOADED,this,true ));

		}

		private function smoothImage() : void
		{
			var bmp : Bitmap = this.content as Bitmap;
			if ( bmp )
			{
				bmp.smoothing = _enableBitmapSmoothing;
				fireEvent();
			}
			else
			{
				this.dispatchEvent( new T3FlexEvent( T3FlexEvent.IMAGE_ERROR_NOT_SUPPORTED_FILEFORMAT ));
					//trace( "==>",this );
			}

		}

		public function get fullUrl() : String
		{
			return _fullUrl;
		}

		public function getUrlOfImage( imgName : String,height : Number=0,width : Number=0,proportion : String="m",uploadDir : String="T3Fe_User" ) : String
		{
			// die Umgebungsvariablen werden von der T3-Konfiguration übertragen
			init();
			var myUrl : String =_baseUrl + "?" + _basicPIDStr + "&" + _typeStr + "&" + _noCacheStr;

			imgUrl = uploadDir + getFirstImage( imgName );
			myUrl += "&" + _imgParameter + imgUrl;

			// add the height
			if ( height > 0 )
			{
				myUrl += "&" + _heigthParameter + height;
			}

			// add the width
			if ( width > 0 )
			{
				myUrl += "&" + _widthParameter + width;
			}

			// parameter
			if ( proportion == "m" && ( width > 0 || height > 0 ))
			{
				myUrl += proportion
			}
			if ( proportion == "c" && ( width > 0 || height > 0 ))
			{
				myUrl += proportion
			}

			if ( T3Flex.getInstance().config.debug )
				trace( "getUrlOfImage: " + myUrl );

			return myUrl;

		}

		public function changeBulkLoaderPriority( newPriority : int=500 ) : void
		{
			T3Flex.getInstance().model.bulkLoader.changeItemPriority( _fullUrl,newPriority );
		}

		public function getFirstImage( url : String ) : String
		{
			if ( url != null )
			{
				var myArray : Array = url.split( "," );
				return myArray[ 0 ];
			}
			else
			{
				return "";

			}
		}

		public function T3Image()
		{
			super();
		}

	}
}

