package de.wwsc.t3flex.vo.t3Standards
{
	[Bindable]
	public class T3Fe_Groups extends T3DbElement
	{
		public var subgroup:String;
		public var description:String;
		public var title:String;
		public var TSconfig:String;

		public function T3Fe_Groups()
		{
			super();
			t3Table = "fe_groups";
			fields.fields["subgroup"]=String;
			fields.fields["description"]=String;
			fields.fields["title"]=String;
			fields.fields["TSconfig"]=String;
		}
	}
}

