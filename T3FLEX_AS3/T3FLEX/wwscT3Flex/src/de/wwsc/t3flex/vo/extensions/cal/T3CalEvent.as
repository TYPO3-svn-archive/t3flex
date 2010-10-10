package de.wwsc.t3flex.vo.extensions.cal
{
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	import flashx.textLayout.elements.TCYElement;

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
		public var location:String;
		public var description:String;
		public var organizer:String;
		public var fe_cruser_id:int;






		public function T3CalEvent()
		{
			super();
			t3Table = "tx_cal_event";
			fields.fields["title"]=String;
			fields.fields["description"]=String;
			fields.fields["organizer"]=String;
			fields.fields["start_time"]=int;
			fields.fields["calendar_id"]=int;
			fields.fields["start_date"]=int;
			fields.fields["allday"]=int;
			fields.fields["end_time"]=int;
			fields.fields["end_date"]=int;
		}


		public function get start_Date_AsDate():Date
		{

			var endDateStr:String = start_date.toString();

			var year:int = int(endDateStr.substr(0,4));
			var month:int = int(endDateStr.substr(4,2))-1;
			var day:int = int(endDateStr.substr(6,2))

			var hours:uint = start_time / 60 / 60 
			var minutes:int = (start_time/60)-(hours*60);

			var date:Date = new Date(year,month,day,hours,minutes);

			return date;
		}

		public function get end_Date_AsDate():Date
		{

			var endDateStr:String = end_date.toString();

			var year:int = int(endDateStr.substr(0,4));
			var month:int = int(endDateStr.substr(4,2))-1;
			var day:int = int(endDateStr.substr(6,2))

			var hours:uint = end_time / 60 / 60 
			var minutes:int = (end_time/60)-(hours*60);

			var date:Date = new Date(year,month,day,hours,minutes);

			return date;

		}

		public function set end_Date_AsDate(value:Date):void
		{
			// time in seconds
			end_time = convertDateToT3CalendarBaseTime(value);

			// time converted to calendarbase time format
			end_date = convertDateToT3CalendarBaseDate(value);
		}

		public function set start_Date_AsDate(value:Date):void
		{
			// time in seconds
			start_time = convertDateToT3CalendarBaseTime(value);

			// time converted to calendarbase time format
			start_date = convertDateToT3CalendarBaseDate(value);
		}


		public function convertDateToT3CalendarBaseDate(date:Date):int
		{
			var t3calDate:String = "";

			var year:int = date.getFullYear();
			var month:int = date.getMonth()+1;
			var day:int = date.date;

			// add year
			t3calDate = year.toString();

			// add month
			if (month<10)
			{
				t3calDate+="0"+month;
			}
			else
			{
				t3calDate+=month;
			}

			// add day
			if (day<10)
			{
				t3calDate+="0"+day;
			}
			else
			{
				t3calDate+=day
			}

			return int(t3calDate)

		}

		public function convertDateToT3CalendarBaseTime(date:Date):int
		{
			var hours:int = date.getHours();
			var minutes:int = date.getMinutes();

			return (hours*60 + minutes) * 60;
		}


	}
}

