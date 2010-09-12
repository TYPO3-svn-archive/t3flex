package de.wwsc.t3flex.model {
	import br.com.stimuli.loading.BulkLoader;

	import de.wwsc.t3flex.events.T3FlexEvent;
	import de.wwsc.t3flex.vo.T3FlexPagetree;
	import de.wwsc.t3flex.vo.T3ObjectPool;

	import flash.events.EventDispatcher;

	public class T3FlexModel extends EventDispatcher {
		/**
		 * Constant used to identify the bulkloader used by T3Flex
		 * default "T3FLEXLOADER"
		 */
		public const T3FLEXLOADER : String = "T3FLEXLOADER";

		[Bindable]
		public var objectPool:T3ObjectPool = new T3ObjectPool();

		[Bindable]
		private var _pagesArr : Array = [];

		[Bindable]
		private var _ttContentArr : Array = [];

		[Bindable]
		public var pagetree : T3FlexPagetree = new T3FlexPagetree;

		[Bindable]
		public var t3TvIndexValues : Array = [];

		/**
		 * T3Flex integrates a bulkloader to handle the loading of many items.
		 * <p>
		 * It's only integrated in T3Image at the moment
		 * </p>
		 * <p>
		 * Have a look at this great AS3-Project!!!
		 * </p>
		 * @see http://code.google.com/p/bulk-loader/
		 */
		public var bulkLoader : BulkLoader = new BulkLoader( T3FLEXLOADER,8 );

		public function T3FlexModel() {
			this.addEventListener( T3FlexEvent.MODEL_PAGESARR_CHANGED,pagetree.rebuildPagetree );
		}

		[ Bindable( T3FlexEvent = T3FlexEvent.MODEL_PAGESARR_CHANGED )]

		public function get pagesArr() : Array {
			if ( _pagesArr ) {
				return _pagesArr;
			} else {
				return [];
			}
		}

		public function set pagesArr( value : Array ) : void {
			_pagesArr = value;
			this.dispatchEvent( new T3FlexEvent( T3FlexEvent.MODEL_PAGESARR_CHANGED ));
		}

		[ Bindable( T3FlexEvent = T3FlexEvent.MODEL_TTCONTENTARR_CHANGED )]

		public function get ttContentArr() : Array {
			return _ttContentArr;
		}

		public function set ttContentArr( value : Array ) : void {
			_ttContentArr = value;
			this.dispatchEvent( new T3FlexEvent( T3FlexEvent.MODEL_TTCONTENTARR_CHANGED,_ttContentArr ));
		}


	}
}

