package org.wsimpson.ui

/*
** Title:	Overlay.as
** Purpose: Acts as an overlay over the existing content for transitions.  Can also be used as a mask
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
**
** 	@langversion ActionScript 3.0
**	@playerversion Flash 10.0
**	@tiptext http://tinyurl.com/2dt7vjr
*/
{
	// Adobe
	import flash.display.MovieClip;
	import flash.events.Event;
	import fl.transitions.Fade;
	import fl.transitions.Transition;
	import fl.transitions.TransitionManager;
	import fl.transitions.easing.Strong; 
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.XMLUtil;

	// UI
	import org.wsimpson.ui.cell.ColorCell;
	
	public dynamic class Overlay extends MovieClip
	{
		// Parameters
		public const propArr = ["x","y","width","height","in","out"];

		// Private Instance Variables
        private var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window
        private var _definition:XML;			// Display  properties defined
        private var _durationIn:Number;			// Display  properties defined
        private var _durationOut:Number;		// Display  properties defined
        private var _style:Object;				// Display Area Style Object
		private var _cell:ColorCell;			// ColorCell displayed
		private var _prevX:int;					// Overlay position;
		
		// Constructor
		/**
		*  name:  Overlay
		*  @param inDef		XML	Contains the parameters defined 
		*  @param inStyle	Object	Defined stylesheet for the parent object
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function Overlay(inDef:XML,inStyle:Object)
		{
			super();
			this._debugger = DebugUtil.getInstance();
			
			// Assign he Display Area Definition
			this._definition = inDef;
			
			// Object Name
			//this.name = this._definition.@["name"].toString();
			
			// Assign he Display Area Definition
			this._style = inStyle;
			
			// Default x
			this._prevX = NaN;
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		private function enterFrameHandler(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
						
			// Initialize the display
			this.init();
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		
		public function hideOverlay():void 
		{
			this.alpha = 0;
			this._prevX = this.x;
			this.x = -1024;
			this.visible = false;
		}
		
		public function showOverlay():void 
		{
			this.x = (this._prevX) ? this._prevX : this.x;
			this._prevX = NaN;
			this.visible = true;
			this.alpha = 100;
		}
		
		public function fadeInOverlay():void 
		{
			TransitionManager.start(this, {type:Fade, direction:Transition.IN, duration:this._durationIn, easing:Strong.easeIn});
		}

		public function fadeOutOverlay():void 
		{
			TransitionManager.start(this, {type:Fade, direction:Transition.OUT, duration:this._durationOut, easing:Strong.easeOut});
		}

			
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
		
		private function applyProp():void {
			for (var i:uint; i < propArr.length; i++)
			{
				switch(propArr[i])
				{ 
					case "x":
					case "y":
						this._cell[propArr[i]] = Number(this._definition.@[propArr[i]].toString());
					break;						
					case "width":
						this._cell.cell_width = Number(this._definition.@[propArr[i]].toString());
					break;						
					case "height":
						this._cell.cell_height = Number(this._definition.@[propArr[i]].toString());
					break;
					case "in":
						this._durationIn = Number(this._definition.@[propArr[i]].toString());
					break;
					case "out":
						this._durationOut = Number(this._definition.@[propArr[i]].toString());
					break;
					default:
						this._debugger.warningTrace("Unexpected property display area object definition:  " +
													propArr[i] + " = " + 
													this._definition.@[propArr[i]].toString());
					break;
				}
			}
		}

		private function assignColor():void {
			this._cell.setRGB_CSS(this._style.color);
			this._cell.backgroundColor = this._cell.datacellRGB;
		}
		
		private function init():void {
			
			this._cell = new ColorCell();
			addChild(this._cell);
			
			// Initialize the display
			this.applyProp();
			
			// background
			this.assignColor();	
			this._cell.drawRect();
		}		
			
    }
}