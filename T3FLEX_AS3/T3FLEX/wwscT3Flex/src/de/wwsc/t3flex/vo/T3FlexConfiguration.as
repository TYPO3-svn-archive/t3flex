package de.wwsc.t3flex.vo
{
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.vo.t3Standards.T3Fe_User;

	import mx.controls.Alert;

	/**
	 * For setup of Typo3 pls have a look at the example in the T3Flex-Class
	 * @see T3Flex#Typo3Setup
	 */
	public class T3FlexConfiguration
	{

		[Bindable]
		private var _baseUrl : String;

		private var _useHttp : Boolean = false;

		// authenticated String /Token;

		public var pagetreeStartingPoints : Array = [];

		public var tx_templavoila_dsArr : Array = [];

		/**
		 * the string used to authenticate the user
		 **/
		public var ftu : String = "";

		/**
		 * will be a future feature / pls do not use now
		 * @private
		 **/
		public var noCacheOfRequests : uint = 1;

		/**
		 * @private
		 * will be a future feature / pls do not use now
		 * @default=false
		 **/
		public var setNoCacheToFalseForNextQuery : Boolean = false;

		/**
		 * Set to true if you want to get a t3Flex Alert-Box on Loading-Errors
		 * @default = false
		 * */
		public var displayAlertOnError : Boolean = false;

		/**
		 * Typo3-PageID, where the Dataprovider is located in Typo3
		 * IMPORTANT! only PIDs are allowed no "Real-URLs"
		 * @default = 1
		 * */
		public var baseSitePid : uint = 1;

		/**
		 * Typo3-PageType: which displays the XML-Data
		 * Do only change, if you know what you're doing!
		 * @default = 9020
		 * */
		public var baseType : uint = 9020;

		/**
		 * Typo3-PageType: which displays the Images
		 * Do only change, if you know what you're doing
		 * @default = 9031
		 * */
		public var baseTypeImages : uint = 9031;

		/**
		 * Typo3-PageId where new records are stored into
		 * @default = -1
		 * */
		public var insertPid : int = -1;

		/**
		 * Is set to the language-ID used in Typo3
		 * @default=0
		 **/
		public var language : uint = 0;

		/**
		 * If set to true only entries of the given main language will be delivered
		 * @see de.wwsc.t3flex.vo.t3Standards.T3HelpFunctions#setLocalLanguageFromUrl()
		 * @see #language
		 * @default = false
		 **/
		public var deliverOnlySelectedLanguage : Boolean = false;

		/**
		 * Object where informations about Typo3-SiteStructure can be found
		 */
		public var pageTree : T3FlexPagetree = new T3FlexPagetree();

		/**
		 * Object where you can store password and username that is used for checking if your user is allowed to use the dataservice.
		 * <p>We strongly recommend securing your dataservice</p>
		 * @see #loginUserStoragePid
		 * @see #noUserCheck
		 * @default = null
		 */
		public var loginUser : T3Fe_User;

		/**
		 * Typo3-PID where your the Login-User is stored
		 * @see #loginUserStoragePid
		 * @see #noUserCheck
		 * @default = null
		 */
		public var loginUserStoragePid : uint;

		/**
		 * Enable this option if your deploying your file to more than one domain
		 * The BaseUrl is identified via the _url of the swfFile, so this will only work correctly, when the file is deployed directly from a webserver
		 * @default = false
		 */
		public var enableDetectionOfBaseUrl : Boolean = false;

		/**
		 * T3Flex caches pictures loaded via the T3Image Class
		 * This improves the loading performances
		 * Set to false if need to load pictures everytime
		 * @default = true
		 */
		public var enableT3ImageCache : Boolean = true;

		/**
		 * If set to true the Class MonitorBusy is used to inform about the loading process
		 * @default = false
		 */
		public var enableT3ImageCacheMonitorBusy : Boolean = false;

		/**
		 *
		 */
		public var enableOfflineCache : Boolean = false;

		public var offlineCacheStartFunction : Function;

		/**
		 * Enable/Disable the output of traces in console
		 * @default = false
		 */
		public var debug : Boolean = false;

		/**
		 * If enabled T3Flex will display an Alert-PopUp-Message on T3Flex-Errors
		 * @default = false
		 */
		public var debugAlertBox : Boolean = false;

		/**
		 * If set to <code>true</code> T3Flex-Dataservice will send your credentials of your loginUser with the first query.
		 * <p>We strongly recommend securing your dataservice</p>
		 * @see #loginUser
		 * @see #loginUserStoragePid
		 * @see #noUserCheck
		 * @default = false
		 */
		public var noUserCheck : Boolean = false;

		//public var deliverHidden:Boolean = false;
		//public var deliverDeleted:Boolean = false;

		/**
		 * @private
		 */
		public const extensionName : String = "tx_t3flex_pi1";

		public var imageUploadDir : String = "uploads/tx_srfeuserregister/";

		public var debugBaseUrl : String;

		/**
		 * defines after how many MINUTES T3Flex is sending the Login-Credentials again to receive a new ftu String
		 * @see #loginUser
		 * @see #noUserCheck
		 * @default = 15
		 */
		public var sessionTimeOutAfter : uint = 15;

		/**
		 * Variable to which is set through the Dataservice everytime a call was processed
		 * @see #sessionTimeOutAfter
		 */
		public var sessionTimeOfLastDataCall : int;

		public function get baseUrl() : String
		{
			// if detection is enabled, the application will look for the correct typo3-path
			// therefore we analyse the storage of the .swf
			// the swf has to be stored at least in "uploads"
			//t3BaseUrlFromSwfStorage
			if ( T3Flex.getInstance().config.enableDetectionOfBaseUrl )
			{
				_baseUrl =T3Helper.getInstance().baseUrlOfDomain;

				// if you are working locally / we'll use the debugBaseUrl
				//Alert.show(_baseUrl);
				if ( _baseUrl == "localhost" )
				{
					_baseUrl = debugBaseUrl;

				}
				else
				{
					_baseUrl = t3BaseUrlFromSwfStorage;

				}
			}
			// Throw a error if _baseurl is empty
			if ( !_baseUrl )
			{
				throw new Error( "baseUrl is not set. Please set up the baseUrl in t3Configuration" );
			}

			return _baseUrl;
		}

		public function set baseUrl( url : String ) : void
		{
			_baseUrl = url;
		}

		public function get t3BaseUrlFromSwfStorage() : String
		{
			var pos : int = T3Helper.getInstance().swfBaseDir.lastIndexOf( "/uploads/" );
			var myString : String = T3Helper.getInstance().swfBaseDir.substring( 0,pos + 1 )
			return myString;
		}

		public function T3FlexConfiguration()
		{
		}
	}
}


