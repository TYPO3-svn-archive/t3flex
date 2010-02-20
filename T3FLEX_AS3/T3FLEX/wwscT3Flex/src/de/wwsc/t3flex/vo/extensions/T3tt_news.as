package de.wwsc.t3flex.vo.extensions {
	import de.wwsc.shared.WwscHelper;
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.DbHelper;
	import de.wwsc.t3flex.vo.DbQuery;
	import de.wwsc.t3flex.vo.t3Standards.T3DbElement;

	public class T3tt_news extends T3DbElement {

		[Bindable]
		public var title : String;
		public var image : String;
		public var imagecaption : String;
		public var datetime : Number;
		[Bindable]
		public var short : String;
		[Bindable]
		public var bodytext : String;
		public var l18n_parent : String;

		public function getAllNewsOfCatUid( newsCatId : uint,resultFunction : Function,languageStr : String=null ) : void {
			if ( T3Flex.getInstance().config.debug )
				trace( "getAllNewsOfCatUid " + newsCatId )
			myResultFunction = resultFunction;
			this.uid = newsCatId;

			var query : DbQuery = new DbQuery();
			query.selectForeignTable = true;
			query.foreignTable = "tt_news";
			query.select_MM_Column = "category";
			query.select_MM_Class = T3tt_news;
			if ( languageStr == "de" )
				query.deliverLanguageId = 0;

			var myDbHelper : DbHelper = new DbHelper;
			//myDbHelper.SELECT_MM_CLASS= T3tt_news;
			myDbHelper.dbQuery = query;

			myDbHelper.getMMForUid( this,resultFunction );
		}

		public function get dateTimeDate() : Date {
			var wwsc : WwscHelper = new WwscHelper();

			return wwsc.convertTimeStampToDate( datetime.toString());
		}

		public function getShortText() : String {
			var myReturnString : String = this.short;
			// Diese Funktion prüft, ob ein KurzText vorhanden ist, absonsten wird der Bodytext genommen
			if ( this.short.length == 0 ) {
				myReturnString = this.bodytext;
			}

			return myReturnString;
		}

		public function getClickUrl( baseUrl : String,DetailPageUid : uint,NewsUid : uint,BackPageUid : uint ) : String {
			var myReturnUrl : String;
			return myReturnUrl = baseUrl + "?no_cache=1&id=" + DetailPageUid + "&tx_ttnews[tt_news]=" + NewsUid + "&tx_ttnews[backPid]=" + BackPageUid;

		}
		public function getImageUrl( baseUrl : String,fileName : String ) : String {
			var myImageArray : Array = fileName.split( "," );
			var myReturnUrl : String;
			return myReturnUrl = baseUrl + "uploads/pics/" + myImageArray[ 0 ];

		}


		public function T3tt_news() {
			//TODO: implement function
			super();
			t3Table = "tt_news"
			fields.fields = _t3BaseFields;
			fields.fields[ "title" ] = String;
			fields.fields[ "datetime" ] = String;
			fields.fields[ "image" ] = String;
			fields.fields[ "imagecaption" ] = String;
			fields.fields[ "short" ] = String;
			fields.fields[ "bodytext" ] = String;
			fields.fields[ "l18n_parent" ] = String;


		}

	}
}

