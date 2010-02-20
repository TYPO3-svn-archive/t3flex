package de.wwsc.t3flex.examples.T3TimeMachine.controller
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Quart;

	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.examples.T3TimeMachine.T3TimeMachine;
	import de.wwsc.t3flex.examples.T3TimeMachine.model.MainApplicationModel;

	import flash.geom.Point;

	import spark.events.IndexChangeEvent;

	public class MainApplicationController
	{
		private var _view:T3TimeMachine;
		private var _model:MainApplicationModel;

		private function initT3Flex():void
		{
			var t3Site:T3Flex = T3Flex.getInstance();
			t3Site.config.baseUrl = "http://typo3.t3flex.com/";
			t3Site.config.baseSitePid = 36;
		}

		public function MainApplicationController(parentView:*,parentModel:MainApplicationModel)
		{
			_model = parentModel;
			_view = parentView;
			initT3Flex();
		}

		public function scrollGroup ( n : int ) : void
		{
			if (_view.timeMachine.layout.target.verticalScrollPosition)
			{
				var scrollPoint : Point = _view.timeMachine.layout.getScrollPositionDeltaToElement( n );
				var duration : Number = ( Math.max( scrollPoint.y, _view.timeMachine.layout.target.verticalScrollPosition ) - Math.min( scrollPoint.y, _view.timeMachine.layout.target.verticalScrollPosition )) * .005;
				TweenLite.to( _view.timeMachine.layout, duration, { verticalScrollPosition: scrollPoint.y, ease: Quart.easeOut });
			}
		}

		public function timeMachine_caretChangeHandler ( event : IndexChangeEvent ) : void
		{
			scrollGroup( event.newIndex );
			event.target.invalidateDisplayList();
		}

		public function timeMachine_creationCompleteHandler () : void
		{
			var perspectivePoint : Point = new Point( _view.timeMachine.width * .5, _view.timeMachine.height * .5 );
			//root.transform.perspectiveProjection.projectionCenter = localToGlobal( perspectivePoint );
		}
	}
}



