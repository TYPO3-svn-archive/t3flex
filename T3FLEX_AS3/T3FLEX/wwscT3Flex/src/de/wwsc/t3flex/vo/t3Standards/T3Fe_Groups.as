package de.wwsc.t3flex.vo.t3Standards
{
	public class T3Fe_Groups extends T3DbElement
	{
		public var subgroup:String;
		public var description:String;
		public var title:String;

		public function T3Fe_Groups()
		{
			super();
			t3Table = "fe_groups";
			fields.fields["subgroup"]=String;
			fields.fields["description"]=String;
			fields.fields["title"]=String;
		}
	}
}

