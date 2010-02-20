package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.T3Helper;
	import mx.events.PropertyChangeEvent;
	
	public class T3Page extends T3DbElement
	{
		
		[Bindable]
		public var title : String;
		
		public var media : String;
		
		[Bindable]
		public var subtitle : String;
		
		public var description : String;
		
		public var sorting : uint;
		
		public var mount_pid : uint;
		
		public var nav_hide : uint;
		
		public var useCachedObjectsWhenShowingRelations : Boolean = false;
		
		private var _ttContentArr : Array
		
		private var _triedToFetchObjFromTtContent : Boolean = false;
		
		private var _childrenPagesArr : Array;
		
		public function get parentPage() : T3Page
		{
			return T3Flex.getInstance().model.pagetree.getParentPageOfT3Page( this );
		}
		
		public function T3Page()
		{
			super();
			t3Table = "pages";
			fields.fields = _t3BaseFields;
			fields.fields[ "title" ] = String;
			fields.fields[ "sorting" ] = uint;
			fields.fields[ "mount_pid" ] = uint;
			fields.fields[ "media" ] = String;
			fields.fields[ "description" ] = String;
			fields.fields[ "nav_hide" ] = uint;
			fields.fields[ "subtitle" ] = uint;
		}
		
		public function get childrenPagesArr() : Array
		{
			return T3Flex.getInstance().model.pagetree.getPagesArrOfChildrenFromUid( this.uid );
		}
		
		public function get test() : uint
		{
			return childrenPagesArr.length;
		}
		
		public function get ttContentArr() : Array
		{
			//var contentLoader : T3Tt_content = new T3Tt_content;
			//contentLoader.getChildren( ttContentsLoaded );
			//var arr : Array = T3Flex.getInstance().model.ttContentArr
			var ttContentArr:Array = []
			if (tx_templavoila_flex)
			{
				var str:String = tx_templavoila_flex.data.sheet.language.field.value
				if (str)
				{
				var arr:Array = str.split(",")
				for each ( var uid:uint in arr)
				{
					var element:* = T3Helper.getInstance().getObjectFromUidInArr(uid,T3Flex.getInstance().model.ttContentArr);
					if (element)
						ttContentArr.push(element);
				}
				}
			}
			
			return ttContentArr
			
			// ToDO:
			// works when maik finished job
			//contentLoader.getAllChildrenWithPid(this.uid,ttContentsLoaded);
		
		}
		
		public function get level():uint
		{
			if (parentPage)
			{
				// one level
				if (parentPage.parentPage)
				{
					// level two
					if (parentPage.parentPage.parentPage)
					{
						// level 3
						if (parentPage.parentPage.parentPage.parentPage)
						{
							// level 4
							if (parentPage.parentPage.parentPage.parentPage.parentPage)
							{
								// level 5
								if (parentPage.parentPage.parentPage.parentPage.parentPage.parentPage)
								{
									return 6
								}
								else
								{
									return 5
								}
							}
							else
							{
								level 4
							}
						}
						else
						{
							return 3
						}
					}
					else
					{
						return 2
					}
				}
				else
				{
					return 1
				}
			}
			
			
			return null
		}
		

		
		private function ttContentsLoaded( data : Array ) : void
		{
			T3Flex.getInstance().model.ttContentArr = data;
		}
		
		public function set ttContentArr( value : Array ) : void
		{
			_ttContentArr = value;
			dispatchEvent( new PropertyChangeEvent( "propertyChange",false,false,null,_ttContentArr ));
		}
	
	}
}