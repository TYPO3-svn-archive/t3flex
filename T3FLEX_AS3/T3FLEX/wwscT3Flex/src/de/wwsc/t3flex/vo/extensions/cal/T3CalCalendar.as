package de.wwsc.t3flex.vo.extensions.cal
{
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	import flash.events.Event;

	public class T3CalCalendar extends T3DbElement
	{

		public var title:String;
		public var owner:String;

		public function addAGroupToCal(groupUid:int):void
		{
			//FIXME::: There's a bug in T3FLEX when more than one relation is possible
			// Workaround::: Change standard-value in MySQL to e.g. "fe_groups"
			//var relation:T3CalMMCalGroup = new T3CalMMCalGroup();
			//relation.addARelation(T3CalMMCalGroup,mmCalGroupRelationCreated)
		}


		public function T3CalCalendar()
		{
			super();
			this.t3Table = "tx_cal_calendar";
			fields.fields["title"]=String;
			fields.fields["owner"]=String;
		}
	}
}

