package org.wsimpson.manager

/*
** Title:	ButtonManager.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
    import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;	
	
	public class ButtonManager extends MovieClip
	{
		// Public Instance Variables
//		public static var HORIZONTAL:String = SliderDirection.HORIZONTAL;	// A alt value is present
		
		// Private Instance Variables
        private var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window
        private var listener_array:Array;		// Notify listeners upon changes
        // private var _name:String;				// Button Label
        private var _active:Boolean;			// Button Active Boolean
        private var _state:String;				// the current state
		
		// Constructor
		public function ButtonManager()
		{
			super();
			this._state = "up";
			this.gotoAndStop(this._state);
			this.addEventListener(flash.events.MouseEvent.CLICK,buttonChange);
			this.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,buttonChange);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OUT,rollOut);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OVER,rollOver);
		}
		
		public function hideSliders():void 
		{
			this._active = false;
			this.gotoAndStop("hide");
		}
		
		public function showSliders():void 
		{
			this._active = true;
			this.gotoAndStop("up");
		}

		/************************************************************************************************************************************
		**  PARAMETERS
		************************************************************************************************************************************/

        public function get label():String {
			return this._name;
        }		
        public function set label(inStr:String):void {
			this._name = inStr;
        }

        public function get state():String {
			return this._state;
        }		
        public function set state(inStr:String):void {
			this._state = inStr;
        }
		
		/**
		*  name:  addButtonListener
		*  @param inFunction	Function	Event listner
		*/
		public function addButtonListener(inFunction:Function):void {
			// //this._debugger.functionTrace("Button.addEventListener");
			
			this.listener_array = (this.listener_array == null) ? new Array() : this.listener_array;
			this.listener_array.push(inFunction);
		}

		/************************************************************************************************************************************
		**  Public
		************************************************************************************************************************************/
		/**
		*  name:  Initialize
		*  @param inDebugger	DebugUtil	Debugger print class
		*  @param inNameStr		String			The button label
		*/
		public function initialize(inNameStr:String)
		{
			// //this._debugger.functionTrace("Button.initialize");
			//this._debugger = DebugUtil.getInstance();
			this._name = inNameStr;
		}
	
		/************************************************************************************************************************************
		**  Event Handlers
		************************************************************************************************************************************/
		
		private function buttonChange(event:MouseEvent):void {
			// //this._debugger.functionTrace("Button.buttonChange");
			trace("testing the trace statement " + event.type);
			
			this.notifyListeners();
		}
		
		private function rollOut(event:MouseEvent):void {
			// //this._debugger.functionTrace("Button.rollOut");
			trace("testing the trace statement " + event.type);
			
			if (_active)
			{
				this.gotoAndStop(this._state);
			}
		}
		
		private function rollOver(event:MouseEvent):void {
			// //this._debugger.functionTrace("Button.rollOver");
			trace("testing the trace statement " + event.type);
			
			if (_active)
			{
				this.gotoAndStop("over");
			}
		}
		
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/
		
		private function notifyListeners():void {
			// //this._debugger.functionTrace("Button.addEventListener");

			for (var i:Number = 0; i < this.listener_array.length; i++)
			{
				this.listener_array[i](this);
			}
		}
		
		private function updateLabel():void {
			// //this._debugger.functionTrace("Button.updateLabel");
	
			this.labelStr.text = this._name;			

		}
		
    }
}