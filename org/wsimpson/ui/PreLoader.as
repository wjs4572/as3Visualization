package org.wsimpson.ui

/*
** Title:	PreLoader.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
    import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	// Utilities
	import org.wsimpson.util.DebugUtil;	

	public class PreLoader extends MovieClip
	{
		
		// Choose one update per second 
		private var _updateInterval:int = 67; 
		
		// Private Instance Variables
        private var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window
		
		// Constructor
		public function PreLoader()
		{
			super();
			this._debugger = DebugUtil.getInstance();
			var myTimer:Timer = new Timer(_updateInterval,0); 
			myTimer.start(); 
			myTimer.addEventListener( TimerEvent.TIMER, rotate );
		}
	
		/******************************************************************************************************
		**  Event Handlers
		******************************************************************************************************/
		
		public function rotate(event:TimerEvent ):void {
			// Update controls here 
			// Force the controls to be updated on screen 
			event.updateAfterEvent();
		}
	}
}