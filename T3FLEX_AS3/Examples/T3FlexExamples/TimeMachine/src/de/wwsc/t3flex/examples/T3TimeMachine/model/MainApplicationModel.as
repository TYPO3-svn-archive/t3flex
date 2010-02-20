package de.wwsc.t3flex.examples.T3TimeMachine.model
{
	import de.wwsc.t3flex.examples.T3TimeMachine.T3TimeMachine;
	import de.wwsc.t3flex.examples.T3TimeMachine.view.NewsItemRenderer;
	import de.wwsc.t3flex.examples.T3TimeMachine.view.contentItemRenderer;
	import de.wwsc.t3flex.vo.extensions.T3tt_news;
	import de.wwsc.t3flex.vo.t3Standards.T3Tt_content;

	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;

	public class MainApplicationModel
	{
		private var _view:T3TimeMachine;

		[Bindable]
		public var content:ArrayCollection = new ArrayCollection();


		public function loadTt_news():void
		{
			var myNewsLoader:T3tt_news = new T3tt_news;
			myNewsLoader.getChildren(newsLoadedHandler);
		}

		public function loadTt_content():void
		{
			var contentLoader:T3Tt_content = new T3Tt_content;
			_view.timeMachine.itemRenderer = new ClassFactory( NewsItemRenderer)//new Class(de.wwsc.t3flex.examples.T3TimeMachine.view.NewsItemRenderer);
			contentLoader.getChildren(contentsLoadedHandler);
		}

		private function contentsLoadedHandler(data:Array):void
		{
			trace(this,data.length);
			_view.timeMachine.itemRenderer = new ClassFactory( contentItemRenderer)//"de.wwsc.t3flex.examples.T3TimeMachine.view.contentItemRenderer"
			content = new ArrayCollection(data);
		}

		private function newsLoadedHandler(data:Array):void
		{
			trace(this,data.length);
			content = new ArrayCollection(data);
		}

		public function MainApplicationModel(parentView:*)
		{
			_view = parentView;
		}
	}
}

