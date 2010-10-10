package de.wwsc.t3flex.vo
{
	public class DbQuery
	{

		public static const SELECT:String = "SELECT";
		public static const INSERT:String = "INSERT";
		public static const UPDATE:String = "UPDATE";
		public static const STORED_QUERY:String = "STORED_QUERY";
		public static const SELECT_MM:String = "SELECT_MM";
		public static const UPDATE_ONE_DATAFIELD:String = "UPDATE_ONE_DATAFIELD";
		public static const DELETE:String = "DELETE";

		public var ignoreAllLanguageSettings:Boolean = false;
		public var deliverLanguageId:int = -1;
		public var action:String
		public var select_MM_Class:Class;
		public var select_MM_Column:String;
		public var filterField:String;
		public var filterValue:String;

		public var selectForeignTable:Boolean;
		public var foreignTable:String;
		public var update_datafieldStr:String;


		public var storedQueryParametes:Array;

		/**
		 * Defines the number of records that will be delivered
		 * @default = 1000
		 */		
		public var count:uint = 1000;

		/**
		 * Points to the starting point of the records
		 * @default = 0
		 */		
		public var pointer:uint = 0;


		public function DbQuery()
		{
		}

	}
}


