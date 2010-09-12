package de.wwsc.t3flex.vo
{
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.t3Standards.IT3DbElement;
	
	import mx.utils.ObjectUtil;

	public class T3ObjectPoolCall
	{
		private var _callBack:Function;
		private var _dicElementUid:String;
		private var _obj:IT3DbElement;


		public function T3ObjectPoolCall(obj:IT3DbElement,uid:uint,dicElementUid:String,callBack:Function,languageId:uint)
		{
			_callBack = callBack;
			_dicElementUid = dicElementUid;
			_obj = obj;
			var myDbHelper : DbHelper = new DbHelper;
			myDbHelper.getChildFromUid( obj,uid,elementLoadedHandler,languageId );

		}

		private function elementLoadedHandler(data:Array):void
		{
			
			_obj = data[0] as IT3DbElement;
				
			if (_obj && Boolean(_callBack))
				_callBack(data);

		}


	}
}

