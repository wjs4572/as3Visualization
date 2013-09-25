package org.wsimpson.ui

/*
** Title:	DebugWindow.as
** Purpose: UI Shell for adding the text window to the screen
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import fl.controls.TextArea;
    import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.events.Event;    
	
	public class DebugWindow extends MovieClip
	{
		private	var debug_text_box_format:TextFormat;		// Debug Window Text format specific to this stage
		
		// Constructor
		public function DebugWindow()
		{
			super();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);			
		}

		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		/**
		*  Name:  setforat
		*  Purpose:  Sets the display format for the debugger window text
		*  @param passed_txt_format	TextFormat	Assigns text formatting
		*/
		public function setformat(passed_txt_format:TextFormat):void {
			this.debug_text_box_format = passed_txt_format;
			this.debug_text_box.textField.setTextFormat(passed_txt_format);
		}
		
		// Hide the debug window
		public function hide():void {
			this.debug_text_box.htmlText = "";
			this.alpha = 0;
			this.visible = false;
		}

		// Hide the debug window
		public function show(inString:String):void {
			this.debug_text_box.htmlText  = inString;
			this.visible = true;
			this.alpha = 100;
		}

		/*
		*  Name:  	refresh
		*  Purpose:  Updates the display textField with the latest text
		*  @param inString String String to display
		*/
		public function refresh(inString:String):void {
			this.debug_text_box.htmlText  = inString;
		}	
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		
		public function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.x = this.y = 0;
			this.init();
		}
		
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/
		
		// Initialize
		private function init() {

			this.debug_text_box.textField.wordWrap = true;
			this.debug_text_box.textField.multiline = true;

			// Set default behavior
			this.graphics.clear();

			this.hide();
			this.focusRect = false;
		}
    }
}