package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.vo.DbHelper;

	import mx.collections.ArrayCollection;

	public class T3Fe_User extends T3DbElement
	{

		[Bindable]
		public var name : String;

		[Bindable]
		public var username : String;

		[Bindable]
		public var password : String;

		[Bindable]
		public var email : String;

		[Bindable]
		public var telephone : String;

		[Bindable]
		public var fax : String;


		[Bindable]
		public var title : String;

		[Bindable]
		public var image : String;

		[Bindable]
		public var www : String;

		[Bindable]
		public var company : String;

		[Bindable]
		public var country : String;

		[Bindable]
		public var address : String;

		[Bindable]
		public var zip : String;

		[Bindable]
		public var city : String;

		[Bindable]
		public var status : String;

		[Bindable]
		public var date_of_birth : String;

		[Bindable]
		public var date_of_birthDate : Date;

		[Bindable]
		public var gender : String;

		[Bindable]
		public var usergroup : String = new String;

		private var myFilterUid : uint;

		private var myObject : Object;



		public function get usergroupArray() : Array
		{
			if ( usergroup.length > 0 )
			{
				return usergroup.split( "," );
			}
			else
			{
				return null
			}
		}

		public function set usergroupArray( myArray : Array ) : void
		{
			// XXX hier soll nichts gemacht werden
		}

		public function getUsersFromUidArray( object : Object,myData : ArrayCollection,type : String,handlerFunction : Function=null ) : void
		{
			myObject = object;
			myResultFunction = handlerFunction;

			//initApp();
			//trace("*** getUsersFromUidArray: "+myData.length);
			for ( var i : uint = 0;i < myData.length;i++ )
			{
				//getUserFromUid(myData[i]);
			}
		}

		/*
		   public function getUserFromUsername(userName:String,resultFunction:Function):void
		   {
		   var myDbHelper:DbHelper = new DbHelper;
		   myDbHelper.getChildrenFromFilterValue(this,resultFunction,"username",userName);
		   }
		 */

		public function memberOfGroup( groupId : uint ) : Boolean
		{
			var found : Boolean = false;
			if ( usergroupArray )
			{
				for ( var i : uint = 0;i < usergroupArray.length;i++ )
				{
					if ( usergroupArray[ i ] == groupId )
					{
						found = true
					}
				}
			}

			return found;
		}

		private function addUserToArray( data : ArrayCollection ) : void
		{
			/// xxx myProject.projectLeader.data.addItem(data[0]);
			myResultFunction();
		}

		public function T3Fe_User()
		{
			super();
			t3Table = "fe_users";
			fields.fields[ "username" ] = String;
			fields.fields[ "name" ] = String;
			fields.fields[ "password" ] = String;
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
			fields.fields[ "gender" ] = String;
		}

	}
}

