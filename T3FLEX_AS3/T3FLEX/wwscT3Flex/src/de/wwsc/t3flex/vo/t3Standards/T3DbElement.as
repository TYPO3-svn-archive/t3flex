package de.wwsc.t3flex.vo.t3Standards
{
	import com.marstonstudios.UploadPostHelper;

	import de.wwsc.shared.MonitorBusy;
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.events.T3FlexEvent;
	import de.wwsc.t3flex.vo.DbHelper;
	import de.wwsc.t3flex.vo.DbQuery;
	import de.wwsc.t3flex.vo.FieldArray;
	import de.wwsc.t3flex.vo.T3Helper;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	public class T3DbElement extends EventDispatcher
	{
		private var _className : String = new String;

		public var tx_templavoila_flex : XMLList;

		private var _tempNewSysLanguageId : uint;

		//public var _name:String;

		public var fields : FieldArray = new FieldArray();

		public var t3Table : String;

		//public var filter_sys_language:Number=0;

		public var uid : Number;

		public var pid : Number;

		public var sys_language_uid : Number = 0;

		public var l10n_parent : Number;

		public var tstamp : String;

		public var crdate : String;

		public var startTime : String;

		public var endTime : String;

		public var cruser_id : uint;

		public var deleted : uint;

		public var hidden : uint;

		public var tx_templavoila_ds : uint;

		public var imagecols : uint;

		public var _LOCALIZED_UID : uint;

		public var myResultFunction : Function;

		[Bindable]
		public var data : ArrayCollection = new ArrayCollection;

		public var _t3BaseFields : Object = { 'uid':Number,
				'pid':Number,
				'tstamp':Number,
				'crdate':Number,
				'cruser_id':Number,
				'deleted':Number,
				'hidden':Number,
				'sys_language_uid':Number,
				'l10n_parent':Number,
				'tx_templavoila_ds':Number,
				'tx_templavoila_flex':XML,
				'imagecols':Number,
				'_LOCALIZED_UID':Number }

		public function get crdateAsDateVO():Date
		{
			return T3Helper.getInstance().convertTimeStampToDate(crdate)
		}

		public function getChildren( resultFunction : Function,languageId : int=-1 ) : void
		{
			myResultFunction = resultFunction;
			var myDbHelper : DbHelper = new DbHelper;
			MonitorBusy.getInstance().setStatus( "T3-DataQuery" );
			myDbHelper.getAllChildrenOfTable( this,resultFunction,languageId );
		}

		public function getChildrenFromFilter( filterField : String,filterValue : String,resultFunction : Function,languageId : int=-1 ) : void
		{
			myResultFunction = resultFunction;
			var myDbHelper : DbHelper = new DbHelper;
			MonitorBusy.getInstance().setStatus( "T3-DataQuery" );
			myDbHelper.getChildrenFromFilterValue( filterField,filterValue,this,resultFunction,languageId );
		}

		public function getChildFromUid( uid : uint,resultFunction : Function,deliverLanguageId : uint=0 ) : void
		{
			var myDbHelper : DbHelper = new DbHelper;
			myDbHelper.getChildFromUid( this,uid,resultFunction,deliverLanguageId );
		}

		public function addARelation( targetClass : Class,resultFunction : Function ) : void
		{
			var myDbHelper : DbHelper = new DbHelper;
			myDbHelper.addARelation( targetClass,this,resultFunction );
		}

		public function getClass() : Class
		{

			return Class( getDefinitionByName( getQualifiedClassName( this )));

		}

		public function updateRecord( resultFunction : Function ) : void
		{
			MonitorBusy.getInstance().setStatus( "T3-DataQuery" );
			var myDbHelper : DbHelper = new DbHelper();
			myDbHelper.myResultFunction = resultFunction;
			//myResultFunction = resultFunction;

			myDbHelper.initApp( "UPDATE",this );
		}

		public function updateOneDataField( dataField : String,resultFunction : Function,showBusyCursor : Boolean=false ) : void
		{
			if ( showBusyCursor )
				MonitorBusy.getInstance().setStatus( "T3-DataQuery" );

			//this.fields.UPDATE_DataField = dataField;

			var myDbHelper : DbHelper = new DbHelper();
			myDbHelper.myResultFunction = resultFunction;
			myDbHelper.dbQuery.update_datafieldStr = dataField;
			//myResultFunction = resultFunction;

			myDbHelper.initApp( DbQuery.UPDATE_ONE_DATAFIELD,this );
		}

		public function filterThisElement() : Boolean
		{
			return T3Helper.getInstance().deliverObject( this );;
		}

		public function removeRecord( resultFunction : Function,withWarning : Boolean=true ) : void
		{
			myResultFunction = resultFunction;

			if ( withWarning )
			{
				Alert.show( "Do you really want to erase this entry from the database?","Warning before removal",3,null,removeRecordProceed )
			}
			else
			{
				var myE : CloseEvent = new CloseEvent( "Alert" );
				myE.detail = Alert.YES;
				removeRecordProceed( myE );
			}
		}

		private function removeRecordProceed( e : CloseEvent ) : void
		{

			if ( e.detail == Alert.YES )
			{
				var myDbHelper : DbHelper = new DbHelper();
				myDbHelper.myResultFunction = myResultFunction;
				myDbHelper.initApp( "DELETE",this );
			}
			else
			{
				trace( this, "removeRecordProceed","not deleted" )
			}

		}

		public function get className() : String
		{
			_className = flash.utils.getQualifiedClassName( this );
			return _className;
		}

		public function set className( str : String ) : void
		{
			_className = str;
		}

		public function getParameter( query : DbQuery ) : Object
		{
			var action : String = query.action;
			var myParams : Object = new Object();
			if ( action == DbQuery.SELECT )
			{
				myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;
				// Sonderfall, wenn getAllChildren ausgeführt wird, dann soll keine UID eingegeben werden.
				if ( this.uid > 0 )
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;
				}

			}

			if ( action == DbQuery.STORED_QUERY )
			{

				myParams[ T3Flex.getInstance().config.extensionName + "[qid]" ] = this.uid;
			}

			if ( action == DbQuery.SELECT_MM )
			{

				if ( query.selectForeignTable )
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[foreign_table]" ] = query.foreignTable; //this.fields.FOREIGN_TABLE
				}
				else
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;
				}
				//var myString:String= wwsc.getStrFromClass(this.fields.SELECT_MM_CLASS);
				//trace(myString);
				myParams[ T3Flex.getInstance().config.extensionName + "[column]" ] = query.select_MM_Column; //this.fields.SELECT_MM_COLUMN;
				myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;
			}

			// Update
			if ( action == DbQuery.UPDATE )
			{
				//myParams += fields.SELECT;

				myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;

				for ( var key : String in fields.fields )
				{
					//trace(this,key)
					if ( key != "uid" && key != 'pid' && key != 'crdate' && key != 'sorting' )
					{
						var myParamKey : String = T3Flex.getInstance().config.extensionName + "[FE][" + key + "]";
						myParams[ myParamKey ] = this[ key ]
						if ( T3Flex.getInstance().config.debug )
							trace( myParamKey + ":" + this[ key ]);
					}
				}
				if ( this._LOCALIZED_UID > 0 )
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this._LOCALIZED_UID;
				}
				else
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;
				}

			}
			// UPDATE ONE DATAFIELD
			if ( action == DbQuery.UPDATE_ONE_DATAFIELD )
			{
				//myParams += fields.SELECT;
				query.action = DbQuery.UPDATE;
				//this.fields.action = "UPDATE";	

				myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;
				myParams[ T3Flex.getInstance().config.extensionName + "[FE][" + query.update_datafieldStr + "]" ] = this[ query.update_datafieldStr ];
				myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;

			}

			// INSERT 
			if ( action == DbQuery.INSERT )
			{

				myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;

				myParams[ T3Flex.getInstance().config.extensionName + "[FE][" + this.fields.MM_FIELD_STR + "]" ] = this.uid;

				// Define the PID where the data is put
				var insertPid : int = -1;
				if ( this.fields.INSERTPid > -1 )
				{
					insertPid = this.fields.INSERTPid;
				}
				else
				{
					insertPid = T3Flex.getInstance().config.insertPid;
				}

				if ( insertPid == -1 )
				{
					throw new Error("No INSERTPid was set / T3Flex / Data was created at pid 0")
				}
				else
				{
					myParams[ T3Flex.getInstance().config.extensionName + "[FE][pid]" ] = insertPid;
				}

			}
			if ( action == "DELETE" )
			{
				myParams[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;
				myParams[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;
			}
			return myParams;
		}

		public function addALocalizedObject( languageUid : uint,checkForAnyExistingLanguageOverlay : Boolean=true ) : void
		{
			_tempNewSysLanguageId = languageUid;

			if ( checkForAnyExistingLanguageOverlay )
			{
				this.getLocalizedObject( languageUid )
			}
			else
			{
				this.addARelation( this.getClass(),addALocalizedObjectHandler )
			}
		}

		private function addALocalizedObjectHandler( data : ArrayCollection ) : void
		{
			var t3DbElement : T3DbElement = data[ 0 ];
			var myClass : Class = this.getClass()
			var newElement : * = new myClass;
			newElement.uid = t3DbElement.uid;
			newElement.l10n_parent = this.uid;
			newElement.sys_language_uid = _tempNewSysLanguageId;
			newElement.updateRecord( addALocalizedObjectCopiedObjectChangedHandler );
		}

		private function addALocalizedObjectCopiedObjectChangedHandler( data : ArrayCollection ) : void
		{
			var element : T3DbElement = data[ 0 ];
			this.dispatchEvent( new T3FlexEvent( T3FlexEvent.LANGUAGEOVERLAY_CREATED,element ));

		}

		/**
		 * Is looking for any existing LanguageOverlay and is returning the Obejct via Event LANGUAGEOVERLAY_CREATED
		 * Depends on function addALocalizedObject
		 * @param languageUid
		 * @param returnFunction
		 *
		 */
		private function getLocalizedObject( languageUid : uint ) : void
		{
			this.getChildFromUid( this.uid,getLocalizedObjectHandler,languageUid );
		}

		private function getLocalizedObjectHandler( data : ArrayCollection ) : void
		{
			var element : Object = data[ 0 ];
			if ( element.l10n_parent == 0 )
			{
				// there is no languageOverlay
				this.addARelation( this.getClass(),addALocalizedObjectHandler )
			}
			else
			{
				// return the existing languageOverlay
				this.dispatchEvent( new T3FlexEvent( T3FlexEvent.LANGUAGEOVERLAY_CREATED,element ));

			}
		}

		/**
		 * Upload a file to a TYPO3-Filefield
		 * uid has to be filled
		 *
		 * Important:
		 * This function can only be called from a dispatched user event (Like AlertBoxClose or MouseEvent)
		 * @see http://jessewarden.com/2008/10/flash-player-10-surprise-error-2176.html
		 *
		 * ToDo:
		 * Add support for a authorized T3Flex-Dataprovider
		 * @param file Reference to a existing file. You can listen to all valid events of your file to know the status of your upload
		 * @param fieldName Name(String) of the datafield to be filled
		 * @param progressEventHandler Function to catch progress Events while upload
		 * @param completeEventHandler Function to catch the complete Event
		 * @param action Only "UPDATE" is tested and supported at this time
		 *
		 */
		public function uploadFile( fileName : String,fieldName : String,bytes : ByteArray,progressEventHandler : Function=null,completeEventHandler : Function=null,action : String="UPDATE" ) : void
		{
			if ( this.uid && this.t3Table )
			{

				var variables : URLVariables = new URLVariables();
				variables[ T3Flex.getInstance().config.extensionName + "[table]" ] = this.t3Table;
				variables[ T3Flex.getInstance().config.extensionName + "[uid]" ] = this.uid;
				variables[ T3Flex.getInstance().config.extensionName + '[action]' ] = action;
				variables[ 'id' ] = T3Flex.getInstance().config.baseSitePid;

				var endpoint : String = T3Flex.getInstance().config.baseUrl + "index.php?id=" + T3Flex.getInstance().config.baseSitePid;
				var fieldNameStr : String = T3Flex.getInstance().config.extensionName + "[FS][" + fieldName + "]"

				// set up the request & headers for upload;
				var urlRequest : URLRequest = new URLRequest();
				urlRequest.url = endpoint;
				urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
				urlRequest.method = URLRequestMethod.POST;
				urlRequest.data = UploadPostHelper.getPostData( fileName,bytes,fieldNameStr,variables );
				urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control','no-cache' ));

				// start upload
				var urlLoader : URLLoader = new URLLoader();
				urlLoader.addEventListener( ProgressEvent.PROGRESS,progressEventHandler );
				urlLoader.addEventListener( Event.COMPLETE,completeEventHandler );
				//urlLoader.addEventListener( IOErrorEvent.IO_ERROR,eventFileUploadError );
				//urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR,eventFileUploadError );
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.load( urlRequest );

			}
			else
			{
				throw new Error( "T3Flex: UploadFile only works with a existing databaseentry" );
			}

		}

		public function T3DbElement()
		{
			fields.parentObj = this;
			fields.fields = _t3BaseFields;
		}

	}
}

