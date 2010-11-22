package de.wwsc.t3flex.vo {
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.events.T3FlexEvent;
	import de.wwsc.t3flex.vo.t3Standards.T3Page;
	import de.wwsc.t3flex.vo.t3Standards.T3Tt_content;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.collections.ArrayCollection;

	public class T3FlexPagetree extends EventDispatcher {

		public var _parentPagesArray : Array = new Array;

		private var _pagetree : XML;

		private var _buildPageTreeCounter : uint = 0;

		private var _buildPageTreeFromElementsArrayC : ArrayCollection;

		public var completeEvent : Event = new Event( "Complete" );

		public function get pagetree() : XML {
			if ( _pagetree ) {
				return _pagetree;
			} else {
				return buildPageTree();
			}
		}

		public function set pagetree( value : XML ) : void {
			_pagetree = value;
			this.dispatchEvent( new T3FlexEvent( T3FlexEvent.PAGETREE_REFRESHED,pagetree ));
		}

		private function buildPageTree() : XML {
			var startingPoint : T3Page = new T3Page;

			var tree : XML = <pagetree></pagetree>;
			// XXX
			// TO DO :
			// what happens if no startpoint were set
			for each ( var uid : uint in T3Flex.getInstance().config.pagetreeStartingPoints ) {
				startingPoint = T3Helper.getInstance().getObjectFromUidInArr( uid,T3Flex.getInstance().model.pagesArr ) as T3Page;
				if (startingPoint)
				{
					var node : XML = <page uid={startingPoint.uid} title={startingPoint.title}  mount_pid={startingPoint.mount_pid}></page>;
					node = addChildren( node );
					tree.appendChild( node );
				}

			}

			return tree;
		}

		public function rebuildPagetree( e : T3FlexEvent ) : void {
			_pagetree = buildPageTree();
		}

		private function getXmlChildrenNodesFromUid( uid : uint ) : XMLList {
			var returnXml : XMLList;
			var children : XMLList;
			for each ( var node : XML in pagetree ) {
				var subnodes : XMLList = pagetree..page;
				var filteredNodes : XMLList = subnodes.( @uid == uid )
				if ( filteredNodes.length() == 0 )
					filteredNodes = subnodes.( @mount_pid == uid )
				var parentNode : XML = filteredNodes[ 0 ];
				if ( parentNode ) {
					children = parentNode.children();

				}
					//trace( this )
			}

			return children;
		}

		public function getPagesArrOfChildrenFromUid( uid : uint ) : Array {
			var arr : Array = [];
			var list : XMLList = getXmlChildrenNodesFromUid( uid );
			if ( list ) {
				for each ( var node : XML in list ) {
					var pid : uint = node.attribute( "uid" );
					arr.push( T3Helper.getInstance().getObjectFromUidInArr( pid,T3Flex.getInstance().model.pagesArr ));
				}
			}
			return arr;
		}

		public function getParentPageOfT3Page( t3Page : T3Page ) : T3Page {
			if ( t3Page ) {
				return T3Helper.getInstance().getObjectFromUidInArr( t3Page.pid,T3Flex.getInstance().model.pagesArr ) as T3Page;
			} else {
				return null
			}

		}

		public function getPageFromUid( uid : uint ) : T3Page {
			return T3Helper.getInstance().getObjectFromUidInArr( uid,T3Flex.getInstance().model.pagesArr ) as T3Page
		}

		private function addChildren( parentNode : XML ) : XML {
			var parentPageUid : uint = Number( parentNode.attribute( "uid" ));
			var mount_pid : uint = Number( parentNode.attribute( "mount_pid" ));

			if ( mount_pid > 0 ) {
				parentPageUid = mount_pid
			}

			var childrenPages : Array = T3Helper.getInstance().getArrayFromFilter( "pid",parentPageUid,T3Flex.getInstance().model.pagesArr )
			//	trace( parentPageUid )
			for each ( var page : T3Page in childrenPages ) {
				var node : XML = <page uid={page.uid} title={page.title} mount_pid={page.mount_pid}></page>;
				node = addChildren( node );
				parentNode.appendChild( node );
					//trace( parentPageUid,page.uid )
			}
			return parentNode;

		}

		public function parsePagesArrayCToTreeHasmap( data : ArrayCollection ) : Boolean {
			for ( var i : uint = 0;i < data.length;i++ ) {
				_parentPagesArray[ data[ i ].uid ] = data[ i ];
			}
			return true
		}

		// Hilfsfunktion für getParentPageUid, da diese Funktion nicht gecachet wäre
		private function getParentPageUidFromTTContentPid( contentPid : uint,resultFunction : Function ) : void {
			//myContent.pid;
			//trace("Suche das Page-Element mit der UID:" + contentPid)
			var myPage : T3Page = new T3Page
			myPage.getChildFromUid( contentPid,resultFunction );
		}

		private function parentPageUidLoaded( data : ArrayCollection ) : void {
			var myPage : T3Page = data[ 0 ] as T3Page;
			_parentPagesArray[ myPage.uid ] = myPage.pid;
			_buildPageTreeCounter++;
			loadNextPageUidFromContent();
		}

		private function loadNextPageUidFromContent() : void {
			//trace(_buildPageTreeCounter)
			if ( _buildPageTreeFromElementsArrayC.length == _buildPageTreeCounter ) {
				// das Ende wurde erreicht
				this.dispatchEvent( completeEvent );
					//trace("tada")
			} else {
				getParentPageUidSpecial( _buildPageTreeFromElementsArrayC[ _buildPageTreeCounter ]);
			}
		}

		public function buildParentPagesHashMapFromArrayC( myArrayC : ArrayCollection ) : void {
			_buildPageTreeFromElementsArrayC = myArrayC;
			_buildPageTreeCounter = 0;
			loadNextPageUidFromContent();

		}

		private function getParentPageUidSpecial( myT3Content : T3Tt_content ) : void {
			var myHashmap : Array = _parentPagesArray

			// ist für diese Seite bereits eine ParentPageId gespeichert?
			if ( myHashmap[ myT3Content.pid ]) {
				// ja
				//resultfunction(myHashmap.getValue(myT3Content.pid));
				//trace("vorhanden")
				_buildPageTreeCounter++;
				loadNextPageUidFromContent();
					//myReturnUid= myHashmap[myT3Content.pid];
			} else {
				// nein
				// dann lade das tt_page element und schaue dort nach
				getParentPageUidFromTTContentPid( myT3Content.pid,parentPageUidLoaded );
			}
		}

		public function getParentPageUid( myT3Content : T3Tt_content ) : int {
			var myHashmap : Array = _parentPagesArray
			var myReturnUid : int = -1

			// ist für diese Seite bereits eine ParentPageId gespeichert?
			if ( myHashmap[ myT3Content.pid ]) {
				// ja
				myReturnUid = myHashmap[ myT3Content.pid ].pid;
			}
			return myReturnUid
		}

		public function T3FlexPagetree() {
		}

	}
}

