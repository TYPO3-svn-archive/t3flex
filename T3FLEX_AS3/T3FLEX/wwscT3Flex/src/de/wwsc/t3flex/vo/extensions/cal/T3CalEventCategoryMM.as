package de.wwsc.t3flex.vo.extensions.cal
{
	import de.wwsc.t3flex.vo.DbHelper;
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	public class T3CalEventCategoryMM extends T3DbElement
	{
		public var uid_local:Number;
		public var uid_foreign:Number;
		public var sorting:Number;

		override public function getChildren(resultFunction:Function,languageId:int=-1):void
		{
			var myDbHelper:DbHelper = new DbHelper;
			this.uid = 2;
			myDbHelper.getStoredQuery(this,resultFunction);
		}

		public function T3CalEventCategoryMM()
		{
			super();

			// this has to be cleaned, 'cause this element is no t3-standard one
			fields.fields = new Object();
			// setting the new fields
			fields.fields["uid_local"]=int;
			fields.fields["uid_foreign"]=int;
			fields.fields["sorting"]=int;
		}
	}
}

