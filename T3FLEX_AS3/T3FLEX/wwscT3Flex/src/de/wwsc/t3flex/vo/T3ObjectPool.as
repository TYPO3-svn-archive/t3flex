package de.wwsc.t3flex.vo
{
	import de.wwsc.t3flex.vo.t3Standards.IT3DbElement;

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class T3ObjectPool
	{
		public var dic:Dictionary = new Dictionary();

		public function T3ObjectPool()
		{
		}



		public function getObjectFromUid(uid:int,sourceObj:IT3DbElement,refreshElement:Boolean=false,languageId:uint=0):IT3DbElement
		{
			var t3Object:IT3DbElement = sourceObj;
			var elementUid:String = renderObjectUid(uid,t3Object.className,languageId);
			var myClass:Class = getDefinitionByName(t3Object.className) as Class

			if (dic.hasOwnProperty(elementUid) && refreshElement)
			{
				return dic[elementUid]
			}
			else
			{
				var obj:IT3DbElement = new myClass;
				dic[elementUid] = obj;

				// Load the element directly
				var poolCall:T3ObjectPoolCall = new T3ObjectPoolCall(obj,uid,elementUid,null,languageId)
				return obj;
			}
		}

		public function getT3ElementFromUidWithCallBack(uid:int,sourceObj:IT3DbElement,callBack:Function,refreshElement:Boolean=false,languageId:uint=0):void
		{
			var t3Object:IT3DbElement = sourceObj;
			var elementUid:String = renderObjectUid(uid,t3Object.className,languageId);
			var myClass:Class = getDefinitionByName(t3Object.className) as Class

			if (dic.hasOwnProperty(elementUid) && refreshElement)
			{
				var data:Array = [dic[elementUid]]
				callBack(data)
			}
			else
			{
				var obj:IT3DbElement = new myClass;

				// Load the element directly
				var poolCall:T3ObjectPoolCall = new T3ObjectPoolCall(obj,uid,elementUid,callBack,languageId)

				dic[elementUid] = obj;
					//return dic[elementUid]
			}
		}


		private function renderObjectUid(uid:uint,classNameStr:String,languageUid:uint):String
		{
			//var date:Date = new Date();
			//var dateStr:String = date.date.toString();
			return classNameStr+"_"+uid+"_"+languageUid
		}

	}
}

