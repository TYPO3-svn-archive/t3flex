package de.wwsc.t3flex.vo.t3Standards
{
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.T3Helper;

	public class T3Tt_content extends T3DbElement
	{

		[Bindable]
		public var header : String;
		[Bindable]
		public var bodytext : String;
		[Bindable]
		public var image : String;

		public var flexformDataStructurId : uint;

		public var l18n_parent : String;

		public var tx_templavoila_to : Number;

		public var CType : String;

		public function get pageObject() : T3Page
		{
			if ( this.pid )
			{
				return T3Helper.getInstance().getObjectFromUidInArr( this.pid,T3Flex.getInstance().model.pagesArr ) as T3Page
			}
			return null;
		}

		public function get tvDsName() : String
		{
			for each ( var item : Object in T3Flex.getInstance().config.tx_templavoila_dsArr )
			{
				if ( item.ds == this.tx_templavoila_ds )
					return item.name;
			}
			return "undefined"
		}

		public function getAllChildrenWithPid( pid : uint,resultFunction : Function ) : void
		{
			this.getChildrenFromFilter( "pid",pid.toString(),resultFunction );
		}

		public function T3Tt_content()
		{
			super();
			t3Table = "tt_content";
			fields.fields = _t3BaseFields;
			fields.fields[ "tx_templavoila_flex" ] = String;
			fields.fields[ "l18n_parent" ] = String;
			fields.fields[ "bodytext" ] = String;
			fields.fields[ "image" ] = String;
			fields.fields[ "tx_templavoila_to" ] = Number;
			fields.fields[ "CType" ] = String;
			fields.fields[ "header" ] = String;

		}

	}
}

