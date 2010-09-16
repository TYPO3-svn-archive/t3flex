package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.vo.DbHelper;

	public class T3Static_country_zones extends T3DbElement
	{
		public var zn_country_iso_2:String;
		public var zn_country_iso_3:String;
		public var zn_country_iso_nr:int;
		public var zn_code:int;
		public var zn_name_local:String;
		public var zn_name_en:String;

		public function T3Static_country_zones()
		{
			super();
			t3Table="static_country_zones";
			fields.fields["zn_country_iso_2"]=String;
			fields.fields["zn_country_iso_3"]=String;
			fields.fields["zn_country_iso_nr"]=int;
			fields.fields["zn_code"]=int;
			fields.fields["zn_name_local"]=String;
			fields.fields["zn_name_en"]=String;
		}


		override public function getChildren(resultFunction:Function,languageId:int=-1):void
		{
			var myDbHelper:DbHelper = new DbHelper;
			this.uid = 1;
			myDbHelper.getStoredQuery(this,resultFunction);
		}

	}
}

