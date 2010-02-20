package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.vo.DbHelper;
	/**
	 * @private
	 */
	
	
	public class T3Static_country extends T3DbElement
	{
		public var cn_short_en:String;
		public var counter:uint;
		private var _stored_query_uid:uint;
		
		override public function getChildren(resultFunction:Function,languageId:int=-1):void
		{
			 var myDbHelper:DbHelper = new DbHelper;
			 this.uid = _stored_query_uid;
			 myDbHelper.getStoredQuery(this,resultFunction);
		}
		
		
		
		public function T3Static_country(stored_query_uid:uint=0)
		{
			
			super();
			t3Table="static_countries";
			this.fields.fields['cn_short_en']=String;
			
			_stored_query_uid  = stored_query_uid;
		}
		
	}
}