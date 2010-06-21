package de.wwsc.shared.flex
{
	import flash.external.ExternalInterface;

	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;

	public class QueryString
	{

		import flash.external.*;
		import flash.utils.*;

		private var _queryString : String;

		private var _all : String;

		private var _params : Object;

		public function get queryString() : String

		{

			return _queryString;

		}

		public function get url() : String
		{
			return _all;
		}

		public function get parameters() : Object
		{
			return _params;
		}

		public function getAreasArrayFromParameters() : Array
		{
			// Diese Funktion erwartet am Dateipfad, die UID der LOE Areas
			// meineSWFDatei.swf?areas=1_2_3_4
			// das Ergebnis ist ein Array
			// ist der Array.length = 0 so wurde keine Parameter gefunden
			// 3 = Emotions and Language
			// 4 = Emotions and Art
			// 5 = Emotional Competence
			// 6 = Cultural Codes of Emotion

			var myString : String = FlexGlobals.topLevelApplication.parameters.areas
			var myArray : Array = new Array;
			//trace("areas "+myString);
			if ( myString.length > 0 )
			{
				myArray = myString.split( "_" );
			}

			return myArray
		}

		public function QueryString()
		{
			readQueryString();
		}

		private function readQueryString() : void
		{
			_params = {};
			try
			{
				_all = ExternalInterface.call( "window.location.href.toString" );
				_queryString = ExternalInterface.call( "window.location.search.substring",1 );
				if ( _queryString )
				{
					var params : Array = _queryString.split( '&' );
					var length : uint = params.length;

					for ( var i : uint = 0,index : int = -1;i < length;i++ )
					{
						var kvPair : String = params[ i ];
						if (( index = kvPair.indexOf( "=" )) > 0 )

						{
							var key : String = kvPair.substring( 0,index );
							var value : String = kvPair.substring( index + 1 );
							_params[ key ] = value;
						}
					}
				}

			} catch ( e : Error )
			{
				trace( this,"Some error occured. ExternalInterface doesn't work in Standalone player." );
			}
		}
	}
}

