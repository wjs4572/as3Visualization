package org.wsimpson.visualization.experiment.infoglyph.meter

/*
** Title:	Layober.as
** Purpose: Specific Type of Meter Class dependent on library shapes
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe UI
	import flash.events.MouseEvent;
	
	// UI
	import org.wsimpson.ui.Meter;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class Layover extends Meter
	{
		// Public Instance Variables
        public var buttonLabel:String;			// Used for identification in notifiyinglisteners upon changes

		// Private Instance Variables		
        private var _listener_array:Array;		// Notify listeners upon changes	
		private var _scaleFactor:Number;		// Scale

		// Constructor
		public function Layover()
		{
			super();
			super.cell_mask = this.meter_mask;
			super.mask_outline = this.outline;
			this.origPercentBool = this.valuePercentBool = false;
			this.origInverseBool = this.valueInverseBool = false;

			this.outline.visible = false;
			this.isButtonBool = true;
			this.minHeight = 20; 				// Based on observed limit to visible color (not scaled)
			this.minWidth = 30; 				// Based on observed limit to visible color (not scaled)
			
			// Make this a button
			this.addEventListener(flash.events.MouseEvent.CLICK,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OVER,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OUT,buttonChange,false,0,true);			
		}
		
		/******************************************************************************************************
		**  Parameters
		*******************************************************************************************************/

		/*
		*  @param inNum Number Is the required pixel size for the width on screen
		*/
		public override function get screenWidth():Number
		{
			return (this.height * this.fullScale.scaleY);
		}
		public override function set screenWidth(inNum:Number):void 
		{
			var tempWidth:Number;
			var tempRatio: Number;
			var rotation:Number;
			rotation = this.rotation;
			this.rotation = 0;
			
			// Scale rotated for displaying layovers
			tempRatio = this.height / this.width;
			tempWidth = (this.minWidth > inNum) ? this.minWidth : inNum;
			this.height = (tempWidth / this.fullScale.scaleY) * 2;
			this.width = this.height / tempRatio;
			
			this.rotation = rotation;
		}

		/*
		*  @param inNum Number Is the required pixel size for the height on screen
		*/
		public override function get screenHeight():Number
		{
			return (this.width * this.fullScale.scaleX);
		}
		public override function set screenHeight(inNum:Number):void 
		{
			var tempHeight:Number;
			var rotation:Number;
			var tempRatio: Number;
			rotation = this.rotation;
			this.rotation = 0;

			// Scale rotated for displaying layovers
			tempRatio = this.height / this.width;
			tempHeight = (this.minHeight > inNum) ? this.minHeight : inNum;
			this.width = (tempHeight / this.fullScale.scaleX) * 2;
			this.height = this.width / tempRatio;
			
			this.rotation = rotation;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		/**
		*  name:  addMeterListener
		*  @param inFunction	Function	Event listner
		*/
		public function addMeterListener(inFunction:Function):void {
			this._listener_array = (this._listener_array == null) ? new Array() : this._listener_array;
			this._listener_array.push(inFunction);
		}
		
		/******************************************************************************************************
		**  EVENTS
		*******************************************************************************************************/		

		public function rollOut(event:MouseEvent):void {
			this.outline.visible = false;
		}

		public function rollOver(event:MouseEvent):void {
			this.outline.visible = true;	
		}

		public function get highlight():Boolean {
			return this.outline.visible;
		}
		public function set highlight(inBool:Boolean):void {
			if (this.isButtonBool)
			{
				this.outline.visible = inBool;
			}
		}
		
		public function buttonChange(event:MouseEvent):void {
			switch(event.type)
			{
				case MouseEvent.MOUSE_OUT:
					this.rollOut(event);
				break;
				case MouseEvent.MOUSE_OVER:
					this.rollOver(event);
				break;
				default:
					// do nothing
				break;
			}
			this.notifyListeners(event);
		}
		
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/		
		private function notifyListeners(event:MouseEvent):void {
			for (var i:Number = 0; i < this._listener_array.length; i++)
			{
				this._listener_array[i](this,event);
			}
		}
	}
}