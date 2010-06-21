package de.wwsc.shared
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.managers.CursorManager;
	
	
	public class MonitorBusy
	{
		private static var _instance:MonitorBusy
      	private static var _allowInstantiation:Boolean;
		private var myBusyStack:ArrayCollection = new ArrayCollection;
		
		public var showHandCursor:Boolean = true;
		public var debug:Boolean = false;
		public var tickInterval:uint = 500;
		
		[Bindable]
		public var applicationBusy:Boolean = false;
		[Bindable]
		public var statusText:String = "";
		
		public function reset():void
		{
			myBusyStack = new ArrayCollection;
		}
		
		public function setStatus(identifier:String, active:Boolean=true):void
		{
			if (active)
			{
				myBusyStack.addItem(identifier);
				statusText = identifier.toString();
			}
			else
			{
				if (myBusyStack.length>0)
				{
					var found:Boolean=false;
					for (var i:uint;i<myBusyStack.length;i++)
					{
						if (!found)
						{
							if (myBusyStack[i] == identifier)
							{
								myBusyStack.removeItemAt(i);
								found=true;
							}
						}
					}
				}
			}
			
			
		}
		
		private function checkStatusHandler(e:TimerEvent):void
		{
			
			if (myBusyStack.length==0)
			{
				statusText = "idle...";
				CursorManager.showCursor();
				CursorManager.removeBusyCursor();
				this.applicationBusy = false;
			}
			else
			{
				if (!applicationBusy)
				{
					if (showHandCursor)
					{
						CursorManager.setBusyCursor();
					}
				}
				this.applicationBusy = true;
			}
			if (debug) 
			{
				trace ("***MonitorBusy- Status: "+" : "+myBusyStack.length);
				for (var i:uint = 0;i<myBusyStack.length;i++)
				{
					trace(myBusyStack[i])
				}	
			
			}
			this.dispatchEvent(new Event("UPDATE"));
		}
		
		
		
      	
      
      public static function getInstance():MonitorBusy 
      {
         if (_instance == null) {
            _allowInstantiation = true;
            _instance = new MonitorBusy;
            _allowInstantiation = false;
          }
         return _instance;
       }
      
		
		
		public function MonitorBusy()
		{
			//trace("Monitor-Busy ist gestartet")
		     if (!_allowInstantiation) {
            throw new Error("Error: Instantiation failed:  Use MonitorBusy.getInstance() instead of new.");
            
          }
			var myTimer:Timer = new Timer(tickInterval, 0);
            myTimer.addEventListener(TimerEvent.TIMER, checkStatusHandler);
            myTimer.start();
		}

	}
}




