package de.wwsc.t3flex.vo
{

	import de.wwsc.shared.flex.QueryString;
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.t3Standards.T3Tt_content;

	import mx.collections.ArrayCollection;
	import mx.resources.ResourceManager;

	public class T3Helper
	{

		private static var _instance : T3Helper = new T3Helper();

		public static function getInstance() : T3Helper
		{
			return _instance;
		}

		public function T3Helper()
		{
			if ( _instance )
				throw new Error( "This is a singleton-class and can only be accessed through T3HelpFunctions.getInstance()" );
		}

		private var keys : Object = {};

		public function convertTimeStampToDate( timestamp : String ) : Date
		{
			var currDate : Date = new Date( Number( timestamp ) * 1000 ); //timestamp_in_seconds*1000 - if you use a result of PHP time function, which returns it in seconds, and Flash uses milliseconds
			var D : Number = currDate.getDate();
			var M : Number = currDate.getMonth() + 1; //because Returns the month (0 for January, 1 for February, and so on)
			var Y : Number = currDate.getFullYear();
			var theDate : String = ( M + "/" + D + "/" + Y );
			//trace(theDate);
			return currDate; // theDate;			
		}

		public function getClassFromDsId( ds : uint ) : Class
		{
			for each ( var item : Object in T3Flex.getInstance().config.tx_templavoila_dsArr )
			{
				if ( ds == item.ds )
					return item.objClass
			}
			return null;
		}

		public function buildMMUidRelationString( arrayWithT3Elements : ArrayCollection,newUid : uint,action : String="ADD" ) : String
		{
			var myString : String = "";
			if ( arrayWithT3Elements.length == 1 )
			{
				//trace("");
				if ( arrayWithT3Elements[ 0 ].name == "No entry" )
				{
					return newUid.toString();
				}

			}
			for ( var i : uint = 0;i < arrayWithT3Elements.length;i++ )
			{
				if ( action == "REMOVE" && newUid == arrayWithT3Elements[ i ].uid )
				{
					//trace("123")
					// skip this item from string
				}
				else
				{
					if ( i > 0 )
					{
						myString += ",";
					}

					myString += arrayWithT3Elements[ i ].uid
				}

			}
			if ( action == "ADD" )
			{
				myString += "," + newUid

			}
			if ( myString.charAt( 0 ) == "," )
			{
				myString = myString.substr( 1,myString.length - 1 )
			}
			return myString;
		}

		public function cleanAllHtml( str : String ) : String
		{
			if ( str )
			{
				//str = escape( str );
				//trace( "befor:" + str );
				var pattern : RegExp = /<TEXTFORMAT.*?>/g;
				var str : String = str.replace( pattern,"" );

				pattern = /<link.*?>/g;
				str = str.replace( pattern,"" );
				pattern = /<value index="vDEF".*?>/g;
				str = str.replace( pattern,"" );
				pattern = /<\/link>/g;
				str = str.replace( pattern,"" );

				pattern = /<br \/>/g;
				str = str.replace( pattern," " );
				pattern = /<b>/g;
				str = str.replace( pattern,"" );
				pattern = /<\/b>/g;
				str = str.replace( pattern,"" );

				pattern = /<i>/g;
				str = str.replace( pattern,"" );
				pattern = /<\/i>/g;
				str = str.replace( pattern,"" );

				pattern = /<p>/g;
				str = str.replace( pattern,"" );
				pattern = /<\/p>/g;
				str = str.replace( pattern,"" );
					//trace( "\nafter:" + str );

			}
			else
			{
				str = "";
			}
			return str;
		}

		public function typo3RichtextHtmlToFlexTextfieldHtml( str : String ) : String
		{
			if ( str )
			{
				var pattern : RegExp;
				//trace( "befor:" + str );
				pattern = /<br \/>/g;
				str = str.replace( pattern,"\r" );
				pattern = /’/g;
				str = str.replace( pattern,"'" );
				pattern = /<ul>/g;
				str = str.replace( pattern,"\n" );
				pattern = /<\/p>/g;
				str = str.replace( pattern,"</p>\n" );
				pattern = /<\/ul>/g;
				str = str.replace( pattern,"" );
				pattern = /<\/li>/g;
				str = str.replace( pattern,"</li>\n" );
			}
			else
			{
				str = ""
			}
			//trace( "after:" + str );
			return str + "";
		}

		public function deliverObject( myObject : Object ) : Boolean
		{
			var mySite : T3Flex = T3Flex.getInstance();
			var deliver : Boolean = true;

			// remove Objects with the wrong language
			// only valid id deliverOnlySelectedLanguage is true
			if ( mySite.config.deliverOnlySelectedLanguage && deliver )
			{
				if ( myObject.sys_language_uid != mySite.config.language.toString() && myObject.className != "de.wwsc.loe.vo::LoeProjectleader" )
				{
					//trace("wrong Language - drop Element - uid:"+myObject.uid);
					deliver = false;
				}
			}
			return deliver;
		}

		public function filterRemoveDuplicateUids( item : Object,idx : uint,arr : Array ) : Boolean
		{
			if ( keys.hasOwnProperty( item.uid ))
			{
				/* If the keys Object already has this property,
				 return false and discard this item. */
				return false;
			}
			else
			{
				/* Else the keys Object does *NOT* already have
				   this key, so add this item to the new data
				 provider. */
				keys[ item.uid ] = item;
				return true;
			}
		}



		public function getArrayFromFilter( filterField : String,filterValue : Object,sourceArr : Array ) : Array
		{
			var returnArr : Array = [];
			for each ( var item : Object in sourceArr )
			{
				//trace( this,item[ filterField ],filterValue )
				if ( filterValue == item[ filterField ])
				{
					returnArr.push( item );
				}
			}

			return returnArr;
		}

		public function getArrayFromUidInArr( uid : uint,arr : Array ) : Array
		{
			return getArrayFromFilter( "uid",uid,arr );
		}

		public function getFlexFormElementsFromDS( datastructureId : uint,source : ArrayCollection ) : ArrayCollection
		{
			var myArray : ArrayCollection = new ArrayCollection;
			var myObject : Object;
			for ( var i : uint = 0;i < source.length;i++ )
			{
				myObject = new Object;
				myObject = source[ i ];
				//trace(i,myObject.tx_templavoila_ds,myObject.uid)
				if ( myObject.tx_templavoila_ds == datastructureId )
				{
					myArray.addItem( myObject );
				}
			}

			return myArray;

		}

		public function getImageNameFromImageField( myString : String ) : String
		{
			//trace(myString);
			var myArray : Array = myString.split( "," );

			return myArray[ 0 ];
		}

		public function getIndexOfObjectFromUidInArr( uid : uint,arr : Array ) : int
		{
			var arrLength : uint = arr.length;
			for ( var i : uint = 0;i < arrLength;i++ )
			{
				if ( uid == arr[ i ].uid )
				{
					return i
				}
			}

			return -1
		}

		public function getObjectFromUidInArr( uid : uint,arr : Array ) : Object
		{
			var arrLength : uint = arr.length;
			for ( var i : uint = 0;i < arrLength;i++ )
			{
				if ( uid == arr[ i ].uid )
				{
					return arr[ i ]
				}
			}

			return null;
		}

		public function getUidOfObjectFromNameInArr( name : String,arr : Array ) : int
		{
			var arrLength : uint = arr.length;
			for ( var i : uint = 0;i < arrLength;i++ )
			{
				if ( name == arr[ i ].name )
				{
					return arr[ i ].uid
				}
			}

			return -1
		}

		public function guessLanguageFromUrl() : String
		{
			var lang : String = "de";

			var myExternalUrl : QueryString = new QueryString();
			if ( myExternalUrl.url )
			{
				var myUrl : String = myExternalUrl.url;

				//myUrl ="http://beta.languages-of-emotion.de/";
				//myUrl ="http://beta.languages-of-emotion.de/en.html";
				//myUrl ="http://beta.languages-of-emotion.de/en/graduate-program.html";
				//myUrl ="http://beta.languages-of-emotion.de/index.php?id=1&L=1";

				if ( myUrl.indexOf( "en.html" ) > 0 )
				{
					//trace ("yoyoyo")
					lang = "en";
				}

				if ( myUrl.indexOf( "/en/" ) > 0 )
				{
					//trace ("yoyoyo1")
					lang = "en";
				}

				if ( myUrl.indexOf( "&L=1" ) > 0 )
				{
					//trace ("yoyoyo2")
					lang = "en";
				}
			}
			//trace(myUrl);
			return lang;

		}

		public function parse( source : T3Tt_content,target : Object ) : void
		{
			//target = source 
			for ( var key : String in source.fields.fields )
			{
				target[ key ] = source[ key ];
			}
			//trace()
		}

		public function convertTtContentObjToTVObj( sourceObj : T3Tt_content ) : Object
		{
			//trace( sourceObj.tvDsName,sourceObj.header,sourceObj.uid );
			var newClass : Class = this.getClassFromDsId( sourceObj.tx_templavoila_ds );
			var newObj : Object = new newClass;
			this.parse( sourceObj,newObj );
			this.parseFlexFormIntoVars( newObj );
			return newObj;
		}

		private function parseFlexFormIntoVars( obj : Object ) : void
		{
			if ( obj.tx_templavoila_flex )
			{
				try
				{
					var list : XMLList = obj.tx_templavoila_flex;
					var myArray : XMLList = list.data.sheet.language.child( "field" );
					var myObj : XML;
					for each ( var item : *in myArray )
					{
						myObj = new XML();
						myObj = item

						var target : Object = new Object;
						this.recognizeTypeFromFlexform( myObj,obj );
					}
				} catch ( e : Error )
				{
					trace( e )
				}
			}
		}

		private function findStrInArr( str : String,arr : Array ) : Boolean
		{
			for each ( var item : String in arr )
			{
				if ( item == str )
					return true
			}
			return false
		}

		private function recognizeTypeFromFlexform( source : XML,target : Object ) : void
		{

			// TODO 
			// needs extra work to tidy up
			// normales Feld
			//trace( this,source.attribute( "index" ));
			if ( source.value )
			{
				// ToDo:
				// hier kann man deutlich verbessern, wie Texte erkannt werden
				var test : XMLList =  source.value.@index
				if ( test.length() > 1 )
				{
					if ( test[ 1 ] == "_TRANSFORM_vDEF.vDEFbase" )
					{
						target[ source.attribute( "index" )] = source.value[ 1 ];
					}
				}
				else if ( test[ 0 ] == "vDEF" )
				{
					target[ source.attribute( "index" )] = source.value[ 0 ];
				}
				else if ( test[ 0 ] == "_TOGGLE" )
				{
					// ignore this field
				}
				else //if ( test == "el" )
				{
					//var list : * = source[ 0 ][ 0 ]
					//var list1 : * = source[ 0 ][ 0 ].el
					var list2 : * = source[ 0 ][ 0 ].el[ 0 ]
					//var list3 : * = source[ 0 ][ 0 ].el[ 0 ].section
					//var list4 : * = source[ 0 ][ 0 ].el[ 0 ].field

					target[ source.attribute( "index" )] = list2;

				}
			}
		}

		public function setLocalLanguageFromUrl( debugLanguage : String="" ) : void
		{
			var myLanguageString : String = guessLanguageFromUrl();
			if ( debugLanguage.length > 0 )
			{
				myLanguageString = debugLanguage;
			}

			if ( myLanguageString == "en" )
			{
				ResourceManager.getInstance().localeChain = [ "en_US" ];
				T3Flex.getInstance().config.language = 1;
			}
			else
			{
				ResourceManager.getInstance().localeChain = [ "de_DE" ];
			}
			if ( T3Flex.getInstance().config.debug )
				trace( "Language: " + ResourceManager.getInstance().getString( "resources","TEST" ));
		}

		public function addOneUidToMMRelations(targetField:String,newUid:uint):String
		{
			if (targetField=="0")
			{
				targetField=newUid.toString();
			}
			else
			{
				targetField+=","+newUid.toString();
			}

			return targetField;


		}
	}
}

