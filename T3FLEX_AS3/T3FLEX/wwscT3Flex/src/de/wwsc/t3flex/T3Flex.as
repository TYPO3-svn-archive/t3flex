//------------------------------------------------------------------------------
//
//   Copyright 2010 - wwsc Maerkte und Medien GmbH 
//   Reimar Kosack, http://wwsc.de 
//   For further informations see blog.t3flex.com 
//
//------------------------------------------------------------------------------
package de.wwsc.t3flex
{
	import de.wwsc.shared.WwscHelper;
	import de.wwsc.t3flex.model.T3FlexModel;
	import de.wwsc.t3flex.vo.T3FlexConfiguration;

	import flash.events.ContextMenuEvent;
	import flash.events.EventDispatcher;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import mx.core.FlexGlobals;

	/**
	 * T3Flex is the main class providing all settings and setups for your applications.
	 * T3Flex is only avaiable as a singleton-Object.
	 *  @example Typo3Setup
	 *	<listing version="3.0" >
	 *
	 * // Insert in Typo3-Setup
	 * // SetUp a extension Template for the page that should react as the dataprovider
	 * // Insert the extension template to that page
	 *
	 * 	// Insert in Constants
	 * 	// the PIDs are defining, where access is allowed
	 * 		plugin.tx_t3flex.pidList = 69,100,139,115
	 * 		//plugin.tx_t3flex.recursive = 1
	 *
	 * // Insert in Configuration
	 * 	page >
	 * 	page < lib.t3flex
	 *
	 *	// Insert in your AS3-Document
	 *
	 *	</listing>
	 */
	public class T3Flex extends EventDispatcher
	{
		//
		private static var _instance : T3Flex

		private static var _allowInstantiation : Boolean;

		/**
		 * Instance of the Typo3-Sitesetup
		 */
		public var config : T3FlexConfiguration = new T3FlexConfiguration();

		/**
		 * Instance of the Typo3-Model
		 */
		public var model : T3FlexModel = new T3FlexModel();
		/**
		 * Delivers the directory of the SWF-File
		 * Might be moved to configuration or helper in the future
		 */
		public function get swfBaseDir() : String
		{
			var wwsc : WwscHelper = new WwscHelper();
			return wwsc.swfBaseDir

		}

		/**
		 * Singleton-Function
		 * @return T3Flex
		 */
		public static function getInstance() : T3Flex
		{
			if ( _instance == null )
			{
				_allowInstantiation = true;
				_instance = new T3Flex();
				_allowInstantiation = false;
			}
			return _instance;
		}

		private function setContextMenu() : void
		{
			var menu:ContextMenu = new ContextMenu();
			var myEntry : ContextMenuItem = new ContextMenuItem( "T3Flex - the Typo3/AS3 Bridge © 2010 wwsc.de",true )
			menu.customItems.push(myEntry);
			myEntry.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT,ctMenu );
			FlexGlobals.topLevelApplication.contextMenu = menu;
			FlexGlobals.topLevelApplication.contextMenu.hideBuiltInItems();
		}

		private function ctMenu( event : ContextMenuEvent ) : void
		{
			var wwsc : WwscHelper = new WwscHelper();
			wwsc.goToUrl( "http://blog.t3flex.com/about/" );
		}

		/**
		 * T3Flex is the main class providing all settings and setups for your applications.
		 * T3Flex is only avaiable as a singleton-Object.
		 * <p>
		 * If u use the free version of the swc- a copyright-notice is added to your right-click menu.
		 * Do not remove this entry. Thx!
		 * </p>
		 */
		public function T3Flex() : void
		{
			if ( !_allowInstantiation )
			{
				throw new Error( "Error: Instantiation failed: Use T3Flex.getInstance() instead of new." );
			}

			model.bulkLoader.start();
			// Show copyright notice
			setContextMenu();
		}

	}
}

