package de.wwsc.t3flex.vo
{
import de.wwsc.t3flex.T3Flex;
import de.wwsc.t3flex.events.T3FlexEvent;
import de.wwsc.t3flex.plugins.offlineCache.OfflineQueryObj;

import flash.utils.getTimer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.HTTPService;

public class DataService
{
	
	public function DataService( resultHandler : *,faultHandler : * ) : void
	{
		this.gateway = new HTTPService();
		this.gateway.url = _ENDPOINT_URL;
		this.gateway.method = "POST";
		this.gateway.useProxy = false;
		this.gateway.resultFormat = "e4x";
		
		this.gateway.addEventListener( ResultEvent.RESULT,resultHandler );
		this.gateway.addEventListener( FaultEvent.FAULT,faultHandler );
	}
	
	private var _config : T3FlexConfiguration = T3Flex.getInstance().config;
	
	private var _ENDPOINT_URL : String = _config.baseUrl + "index.php";
	
	private var _traceString : String = _ENDPOINT_URL + "?";
	
	private var gateway : HTTPService;
	
	public function doRequest( query : DbQuery,parameters : Object,callback : Function ) : void
	{
		if ( _config.loginUser )
		{
			if ( _config.ftu.length > 0 && !iNeedToRefreshMySession())
			{
				parameters[ 'ftu' ] = _config.ftu;
			}
			else
			{
				parameters[ 'ftu' ] = "";
				parameters[ 'logintype' ] = "login";
				parameters[ "pid" ] = _config.loginUserStoragePid;
				parameters[ "user" ] = _config.loginUser.username;
				//parameters[ "pass" ] = _config.loginUser.password;
				
			}
		}
		
		if ( query.filterField && query.filterValue )
		{
			parameters[ T3Flex.getInstance().config.extensionName + "[fFld]" ] = query.filterField;
			parameters[ T3Flex.getInstance().config.extensionName + "[fVal]" ] = query.filterValue;
		}
		
		// xxx 
		// noch ohne Funktion, da das Cachen nicht geht!
		if ( _config.setNoCacheToFalseForNextQuery )
		{
			parameters[ 'no_cache' ] = 0;
			_config.setNoCacheToFalseForNextQuery = false;
		}
		else
		{
			parameters[ 'no_cache' ] = _config.noCacheOfRequests;
		}
		
		// No User Check
		if ( !T3Flex.getInstance().config.noUserCheck )
		{
			T3Flex.getInstance().config.sessionTimeOfLastDataCall = getTimer();
		}
		
		// Pointer
		parameters[ T3Flex.getInstance().config.extensionName + "[pointer]" ] = query.pointer;
		
		// Count	
		parameters[ T3Flex.getInstance().config.extensionName + "[count]" ] = query.count;
		
		// Language-Settings
		if ( query.ignoreAllLanguageSettings )
		{
			// do nothing
		}
		else
		{
			if ( query.deliverLanguageId > -1 )
			{
				parameters[ 'L' ] = query.deliverLanguageId;
			}
			else
			{
				parameters[ 'L' ] = _config.language;
			}
		}
		// baseSitePID
		parameters[ 'id' ] = _config.baseSitePid;
		// ExtensionName
		parameters[ T3Flex.getInstance().config.extensionName + '[action]' ] = query.action;
		
		gateway.request = parameters;
		
		var event : T3FlexEvent = new T3FlexEvent( T3FlexEvent.DATASERVICE_GATEWAY_SEND,parameters );
		T3Flex.getInstance().dispatchEvent( event )
		
		if ( _config.debug || _config.enableOfflineCache )
		{
			
			var arrayC : ArrayCollection = new ArrayCollection();
			
			for ( var key : String in parameters )
			{
				var obj : Object = new Object;
				obj.key = key;
				obj.parameter = parameters[ key ];
				arrayC.addItem( obj );
			}
			
			var sort : Sort = new Sort();
			var sortfield : SortField = new SortField( "key" );
			sort.fields = [ sortfield ];
			arrayC.sort = sort;
			arrayC.refresh();
			
			for each ( var item : Object in arrayC )
			{
				_traceString += "&" + item.key + "=" + item.parameter
			}
			
			if ( _config.debug )
				trace( "T3Flex-DataService-Call: " + query.action + " ==> " + parameters[ T3Flex.getInstance().config.extensionName + '[table]' ] + "\n" + _traceString );
		}
		// Setting the callback-Function
		if ( _config.enableOfflineCache )
		{
			var myCacheObject : OfflineQueryObj = new OfflineQueryObj();
			myCacheObject.callback = callback;
			myCacheObject.type = OfflineQueryObj.DATABASE_CALL;
			myCacheObject.gateway = gateway;
			myCacheObject.t3FlexQueryStr = _traceString;
			myCacheObject.parameters = parameters;
			//myCacheObject.dataService = this;
			//myCacheObject.resultFunction = callFunction;
			T3Flex.getInstance().dispatchEvent( new T3FlexEvent( T3FlexEvent.DATASERVICE_OFFLINECACHE_LOOK_UP,myCacheObject ))
			gateway.addEventListener( ResultEvent.RESULT,resultEvent );
		}
		else
		{
			var call : AsyncToken = gateway.send();
			call.request_params = gateway.request;
			call.handler = callback;
		}
	}
	
	private function resultEvent( e : ResultEvent ) : void
	{
		
		//var topass : * = deserialize( e.result,e );
		//e.token.handler.call( null,topass );
		gateway.removeEventListener( ResultEvent.RESULT,resultEvent );
		var returnObject : Object = new Object;
		returnObject.id = this._traceString;
		returnObject.resultEvent = e;
		//returnObject.topass = topass;
		T3Flex.getInstance().dispatchEvent( new T3FlexEvent( T3FlexEvent.DATASERVICE_OFFLINECACHE_RETURN_RESULT,returnObject ));
	}
	
	// ToDo: Delete
	private function callFunction( e : Object ) : void
	{
		//trace( e.toString());
	}
	
	private function iNeedToRefreshMySession() : Boolean
	{
		var myValue : int = getTimer() - T3Flex.getInstance().config.sessionTimeOfLastDataCall;
		var miliseconds : int = T3Flex.getInstance().config.sessionTimeOutAfter * 1000 * 60;
		if ( myValue > miliseconds )
		{
			return true
		}
		else
		{
			return false
		}
	}
}
}