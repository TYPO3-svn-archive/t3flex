package de.wwsc.t3flex.examples.FileUpload.controller
{
	import de.wwsc.t3flex.T3Flex;
	import de.wwsc.t3flex.examples.FileUpload.T3FlexExampleFileUpload;

	public class MainApplicationController
	{

		private var _view:T3FlexExampleFileUpload;

		private function initT3Flex():void
		{
			var t3Site:T3Flex = T3Flex.getInstance();
			t3Site.config.baseUrl = "http://typo3.t3flex.com/";
			t3Site.config.baseSitePid = 36;
		}

		public function MainApplicationController(parentView:*)
		{
			_view = parentView;
		}
	}
}

