package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.vo.DbHelper;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class T3Fe_User extends T3DbElement
	{

		public var name : String;

		public var username : String;

		//public var password : String;

		public var email : String;

		public var telephone : String;

		public var fax : String;

		public var title : String;

		public var image : String;

		public var www : String;

		public var company : String;

		public var country : String;

		public var address : String;

		public var zip : String;

		public var city : String;

		public var status : String;

		public var date_of_birth : String;

		public var date_of_birthDate : Date;

		public var usergroup : String = new String;

		private var myFilterUid : uint;

		private var myObject : Object;


		public function memberOfGroup( groupId : uint ) : Boolean
		{
			var found : Boolean = false;
			var arr:Array = usergroup.split(",");
			if ( arr.length>0 )
			{
				for ( var i : uint = 0;i < arr.length;i++ )
				{
					if ( arr[ i ] == groupId )
					{
						found = true
					}
				}
			}

			return found;
		}

		public function T3Fe_User()
		{
			super();
			t3Table = "fe_users";
			fields.fields[ "username" ] = String;
			fields.fields[ "name" ] = String;
			//fields.fields[ "password" ] = String;
			fields.fields[ "usergroup" ] = String;
			fields.fields[ "email" ] = String;
			fields.fields[ "telephone" ] = String;
			fields.fields[ "fax" ] = String;
			fields.fields[ "title" ] = String;
			fields.fields[ "image" ] = String;
			fields.fields[ "www" ] = String;
			fields.fields[ "company" ] = String;
			fields.fields[ "country" ] = String;
			fields.fields[ "address" ] = String;
			fields.fields[ "zip" ] = String;
			fields.fields[ "city" ] = String;
			fields.fields[ "status" ] = String;
			fields.fields[ "date_of_birth" ] = String;

		}

	}
}

