package de.wwsc.t3flex.vo.extensions.cal
{
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	public class T3CalCategory extends T3DbElement
	{
		public var title:String;
		public var parent_category: int;

		public function T3CalCategory()
		{
			super();
			t3Table = "tx_cal_category";
			fields.fields["title"]=String;
			fields.fields["parent_category"]=int;
		}
	}
}

