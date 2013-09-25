package org.wsimpson.visualization.experiment.infoglyph.meter

/*
** Title:	Jet90.as
** Purpose: Specific Type of Meter Class dependent on library shapes
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
		
	// UI
	import org.wsimpson.ui.Meter;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class Jet90 extends Meter
	{
		// Public Instance Variables
        public var buttonLabel:String;			// Used for identification in notifiyinglisteners upon changes

		// Private Instance Variables		
        private var _listener_array:Array;		// Notify listeners upon changes	
		
		// Multidimensional Array
		public static const METER_MASK = "alt_meter_mask_";			// The MovieClip prefix	
		public static const OUTLINE = "alt_outline_";				// The MovieClip prefix	
		
		// Constructor
		public function Jet90()
		{
			super();
			super.cell_mask = this.meter_mask = this.alt_meter_mask_1;
			super.mask_outline = this.outline = this.alt_outline_1;
			this.alt_meter_mask_1.visible = this.alt_meter_mask_2.visible = this.alt_meter_mask_3.visible = this.alt_meter_mask_4.visible = false
			this.alt_outline_1.visible = this.alt_outline_2.visible = this.alt_outline_3.visible = this.alt_outline_4.visible = false
			this.isButtonBool = true;

			// Make this a button
			this.addEventListener(flash.events.MouseEvent.CLICK,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OVER,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OUT,buttonChange,false,0,true);			
		}

		/******************************************************************************************************
		**  PARAMTERS
		*******************************************************************************************************/

		/**
		*  Name:  	outline
		*/
		public function get outline():MovieClip
		{
			return this[OUTLINE + this.rank];
		}
		
		public function set outline(inOutline:MovieClip):void
		{
			super.mask_outline = inOutline;
		}

		/**
		*  Name:  	meter_mask
		*/
		public function get meter_mask():MovieClip
		{
			return this[METER_MASK + this.rank];
		}
		
		public function set meter_mask(inMask:MovieClip):void
		{
			super.cell_mask = inMask;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		/*
		*  Name:  	setRank
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inRank Number The rank to assign to move it.
		*/
		public override function setRank(inRank:Number):void {
			this.rank = inRank;
			if (this.colorRangeArr)
			{
				if (this.rank == -1)
				{
					this.hideMeter();
				} else
				{
					this.outline = this[OUTLINE + this.rank];
					this.meter_mask = this[METER_MASK + this.rank];
					this.colorRGB = this.colorRangeArr[this.rank];
				}
			} else 
			{
				this._debugger.errorTrace("Attempt to upate meter when Color Range has not been assigned.");
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