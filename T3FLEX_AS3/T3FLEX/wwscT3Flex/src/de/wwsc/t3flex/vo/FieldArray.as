
package de.wwsc.t3flex.vo
{
	public class FieldArray
	{
		
		public var parentObj:Object = new Object();
		
		public var orderField:String = "";
		public var filterField:String;
		public var filterValue:String = "";
		public var desc:Boolean = false;
		//public var action:String = "";
		public var targetObjectClass:Class;
		
		
		public var SELECT:Object;
		public var INSERTPid:int =-1;
		public var UPDATE:Array = new Array;
		public var UPDATE_DataField:String;
		//public var SELECT_FOREIGN_TABLE:Boolean = false;
		//public var FOREIGN_TABLE:String;
		
		//public var SELECT_MM_COLUMN:String;
		
		//hier wird der "linke" Teil der MM-Relation gesetzt. Also der Bezeichner in der Tabelle
		public var MM_FIELD_STR:String ="user";
		
		
		public var fields:Object = 
		{
				
		}
		
		//public function get params()
		
		
		public function FieldArray()
		{
			SELECT =
				{
					"filterField": filterField,
			 		"filter": filterValue,
			 		"orderField": orderField,
			    	"orderDirection": (desc) ? "DESC" : "ASC"
			     	//"tx_wwscflexdata_pi1[table]" : parentObj.t3Table,
			     	//"tx_wwscflexdata_pi1[uid]" : parentObj.uid	
				}
			
			
			
		}

	}
}