package de.wwsc.t3flex.vo.extensions.cal
{
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	[Bindable]
	public class T3CalEvent extends T3DbElement
	{
		public var type:int = 0;
		public var start_date:int;	
		public var end_date:int;
		public var start_time:int;
		public var end_time:int;
		public var allday:int;	
		public var timezone:String;
		public var title:String;
		public var calendar_id:int;	
		public var category_id:int;
		public var location:String;
		public var description:String;
		public var fe_cruser_id:int;




		public function T3CalEvent()
		{
			super();
		}
	}
}

