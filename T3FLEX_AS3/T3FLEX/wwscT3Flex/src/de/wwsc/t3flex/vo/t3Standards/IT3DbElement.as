package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.vo.DbQuery;

	import flash.utils.ByteArray;

	public interface IT3DbElement
	{

		function get crdateAsDateVO():Date;

		function getChildren(resultFunction:Function,languageId:int=-1):void;

		function getChildrenFromFilter(filterField:String,filterValue:String,resultFunction:Function,languageId:int=-1):void;

		function getChildFromUid(uid:uint,resultFunction:Function,deliverLanguageId:uint=0):void;

		function addARelation(targetClass:Class,resultFunction:Function):void;

		function getClass():Class;

		function updateRecord(resultFunction:Function):void;

		function updateOneDataField(dataField:String,resultFunction:Function,showBusyCursor:Boolean=false):void;

		function filterThisElement():Boolean;

		function removeRecord(resultFunction:Function,withWarning:Boolean=true):void;

		function get className():String;

		function set className(str:String):void;

		function getParameter(query:DbQuery):Object;

		function addALocalizedObject(languageUid:uint,checkForAnyExistingLanguageOverlay:Boolean=true):void;

		function uploadFile(fileName:String,fieldName:String,bytes:ByteArray,progressEventHandler:Function=null,completeEventHandler:Function=null,action:String="UPDATE"):void;
	}
}

