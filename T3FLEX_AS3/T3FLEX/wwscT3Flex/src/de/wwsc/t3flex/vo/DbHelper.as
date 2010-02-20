package de.wwsc.t3flex.vo
{
	import de.wwsc.shared.MonitorBusy;
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.events.T3FlexEvent;
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;

	import mx.controls.Alert;
	import mx.core.Application;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	public class DbHelper extends EventDispatcher
	{
		public var dbQuery : DbQuery = new DbQuery;

		public var myResultFunction : Function;

		public var INSERT_MM_CLASS : Class;

		private var myType : String;

		private var myObject : Object;

		public var data : Array = [];

		public function getMMForUid( object : Object,resultFunction : Function ) : void
		{
			if ( T3Flex.getInstance().config.debug )
				trace( "getMMForUid: " + object.uid );
			myResultFunction = resultFunction;
			initApp( "SELECT_MM",object );
		}

		public function addARelation( targetClass : Class,object : T3DbElement,resultFunction : Function ) : void
		{
			//trace ("getMMForUid: "+targetClass.toString());
			myResultFunction = resultFunction;
			var myClass : Class = targetClass as Class;

			var myTarget : Object = new myClass();
			myTarget.uid = object.uid;

			initApp( "INSERT",myTarget );
		}

		public function getAllChildrenOfTable( object : Object,resultFunction : Function,languageId : int=-1 ) : void
		{
			var className : String = flash.utils.getQualifiedClassName( object )
			if ( T3Flex.getInstance().config.debug )
				trace( "getAllChildrenOfTable: " + object.className );

			object.uid = 0;
			if ( languageId > -1 )
			{
				this.dbQuery.deliverLanguageId = languageId;
			}

			myResultFunction = resultFunction;
			initApp( "SELECT",object )
		}

		public function getStoredQuery( object : Object,resultFunction : Function ) : void
		{
			MonitorBusy.getInstance().setStatus( "T3-DataQuery" );
			if ( T3Flex.getInstance().config.debug )
				trace( "getSTORED_QUERY: " + object.className );
			myResultFunction = resultFunction;
			initApp( "STORED_QUERY",object )
		}

		public function getChildrenFromFilterValue( filterField : String,filterValue : String,object : Object,resultFunction : Function,languageId : int=-1 ) : void
		{
			if ( T3Flex.getInstance().config.debug )
				trace( "getAllChildrenFromFilterValue: " + filterValue,filterField );
			object.uid = 0;
			if ( languageId > -1 )
			{
				this.dbQuery.deliverLanguageId = languageId;
			}

			this.dbQuery.filterField = filterField;
			this.dbQuery.filterValue = filterValue;

			myResultFunction = resultFunction;
			initApp( "SELECT",object )
		}

		public function getChildFromUid( object : Object,uid : uint,resultFunction : Function,deliverLanguageId : uint=0 ) : void
		{
			if ( T3Flex.getInstance().config.debug )
				trace( "getChildFromUid: " + object.className );
			myResultFunction = resultFunction;
			object.uid = uid;
			this.dbQuery.deliverLanguageId = deliverLanguageId;
			initApp( "SELECT",object )

		}

		/**
		 * gateway : this is the communication layer with the server side php code
		 */

		private var gateway : HTTPService = new HTTPService();

		private var dataArr : Array = [];

		private var fields : Object;

		public function initApp( action : String,myItem : Object ) : void
		{
			gateway.method = "POST";
			gateway.useProxy = false;
			gateway.resultFormat = "e4x";

			gateway.addEventListener( ResultEvent.RESULT,resultHandler );
			gateway.addEventListener( FaultEvent.FAULT,faultHandler );

			// XXX hier kann man optimieren und ein Event auswerfen (loading)

			myObject = myItem;
			dbQuery.action = action;

			var parameters : Object = myObject.getParameter( dbQuery );

			var service : DataService = new DataService( resultHandler,faultHandler );
			service.doRequest( dbQuery,parameters,fillHandler );
		}

		/**
		 * result handler for the fill call.
		 * if it is an error, show it to the user, else refill the arraycollection with the new data
		 *
		 */
		private function fillHandler( e : Object ) : void
		{
			if ( e.isError )
			{
				if ( T3Flex.getInstance().config.displayAlertOnError )
					Alert.show( "T3Flex-Error: " + e.data.error );

				var myEvent : Event = new Event( T3FlexEvent.LOADING_ERROR );
				T3Flex.getInstance().dispatchEvent( myEvent );

				MonitorBusy.getInstance().reset();
			}
			else
			{
				if ( String( e.metadata.get_URL_ID ).length > 0 )
				{
					if ( T3Flex.getInstance().config.ftu.length == 0 )
					{
						var myToken : String = String( e.metadata.get_URL_ID ).replace( "&ftu=","" );
						T3Flex.getInstance().config.ftu = e.metadata.get_URL_ID;
					}
				}
				else
				{
					if ( T3Flex.getInstance().config.ftu.length == 0 )
					{
						if ( T3Flex.getInstance().config.noUserCheck == false )
						{
							//Alert.show("You are not authenticated. Please contact your admin.","FE-Login failed");
						}
					}
				}

				if ( dbQuery.select_MM_Class )
				{
					var myClass : * = dbQuery.select_MM_Class as Class;
					var newObject : * = new myClass;
					fields = newObject.fields.fields;
				}
				else
				{
					fields = myObject.fields.fields;
				}

				// ToDo:
				// das ist überflüssig und kann rausgenommen werden
				// die Ergebnisse müssen nicht 2mal geparst werden
				dataArr = [];
				for each ( var row : XML in e.data.row )
				{
					var temp : * = {};
					for ( var key : String in fields )
					{
						temp[ key + 'Col' ] = row[ key ];
					}

					dataArr.push( temp );
				}
				transformDataArray();

			}
		}

		/**
		 * deserializes the xml response
		 * handles error cases
		 *
		 * @param e ResultEvent the server response and details about the connection
		 */
		public function deserialize( obj : *,e : * ) : *
		{
			var toret : Object = {};

			toret.originalEvent = e;

			if ( obj.data.elements( "error" ).length() > 0 )
			{
				toret.isError = true;
				toret.data = obj.data;
			}
			else
			{
				toret.isError = false;
				toret.metadata = obj.metadata;
				toret.data = obj.data;
			}

			return toret;
		}

		/**
		 * result handler for the gateway
		 * deserializes the result, and then calls the REAL event handler
		 * (set when making a request in the doRequest function)
		 *
		 * @param e ResultEvent the server response and details about the connection
		 */
		public function resultHandler( e : ResultEvent ) : void
		{
			var topass : * = deserialize( e.result,e );
			e.token.handler.call( null,topass );
		}

		/**
		 * fault handler for this connection
		 *
		 * @param e FaultEvent the error object
		 */
		public function faultHandler( e : FaultEvent ) : void
		{

			var myEvent : Event = new Event( T3FlexEvent.LOADING_ERROR );
			T3Flex.getInstance().dispatchEvent( myEvent );

			var errorMessage : String = "Connection error: " + e.fault.faultString;
			if ( e.fault.faultDetail )
			{
				errorMessage += "\n\nAdditional detail: " + e.fault.faultDetail;
			}

			if ( T3Flex.getInstance().config.displayAlertOnError )
				Alert.show( errorMessage,"T3Flex-DbHelper:Error" );

			MonitorBusy.getInstance().reset();
		}

		/**
		 * makes a request to the server using the gateway instance
		 *
		 * @param method_name String the method name used in the server dispathcer
		 * @param parameters Object name value pairs for sending in post
		 * @param callback Function function to be called when the call completes
		 */
		public function doRequest( method_name : String,parameters : Object,callback : Function ) : void
		{
			//gateway.url = Application.application._global.config.ENDPOINT_URL;

			parameters[ 'method' ] = method_name;

			gateway.request = parameters;

			var call : AsyncToken = gateway.send();
			call.request_params = gateway.request;

			call.handler = callback;
		}

		private function transformDataArray() : void
		{
			var startTime : uint = getTimer();
			//trace("0: "+String(getTimer()-startTime))
			data = [];
			var myClass : Class;

			// construct the correct Object-Class
			if ( dbQuery.select_MM_Class )
			{
				myClass = dbQuery.select_MM_Class as Class;
			}
			else
			{
				myClass = getDefinitionByName( myObject.className ) as Class;
			}
			//trace("1: "+String(getTimer()-startTime))
			var myNewData : Object = new myClass;

			// convert each Element into a Object
			for ( var i : uint = 0;i < dataArr.length;i++ )
			{
				myNewData = new myClass;
				for ( var key : String in fields )
				{
					var value : Object = dataArr[ i ][ key + 'Col' ].toString();
					if ( key == "tx_templavoila_flex" )
					{
						myNewData[ key ] = new XMLList( value );
							//myNewData[ key ] = new XML( value );
					}
					else
					{
						myNewData[ key ] = value

					}
				}
				// check each element against some basic rules
				// like language
				if ( T3Helper.getInstance().deliverObject( myNewData ))
				{
					data.push( myNewData )
						//data.push(myNewData);
				}
			}


			// loading complete
			MonitorBusy.getInstance().setStatus( "T3-DataQuery",false );

			//trace("3: "+String(getTimer()-startTime))
			// check if a resultFunction was set
			//trace("123"+Boolean(myResultFunction));
			if ( Boolean( myResultFunction ))
			{
				//trace("4: "+String(getTimer()-startTime))
				myResultFunction( data );
			}
			//trace("4: "+String(getTimer()-startTime))
		}

		public function DbHelper()
		{
		}

	}
}

