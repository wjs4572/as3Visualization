package org.wsimpson.visualization.experiment.infoglyph.meter

/*
** Title:	Bar.as
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
	
	public class Bar extends Meter
	{
		// Public Instance Variables
        public var buttonLabel:String;			// Used for identification in notifiyinglisteners upon changes

		// Private Instance Variables		
        private var _listener_array:Array;		// Notify listeners upon changes
		
		// Constructor
		public function Bar()
		{
			super();
			super.cell_mask = this.meter_mask;
			super.mask_outline = this.outline;
			this.outline.visible = false;
			this.isButtonBool = true;
			this.minHeight = 2; 				// Based on observed limit to visible color
			
			this.origPercentBool = this.valuePercentBool = false;
			this.origInverseBool = this.valueInverseBool = true;
			
			// Make this a button
			this.addEventListener(flash.events.MouseEvent.CLICK,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OVER,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OUT,buttonChange,false,0,true);
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/	
		
		/**
		*  Name:  	RGB String Value
		*/
				/**
		*  Name:  	RGB String Value
		*/
		public function get colorAlpha():Number
		{
			return this.dataCell.a;
		}
		
		public function set colorAlpha(inAlpha:Number):void
		{
			this.dataCell.a = inAlpha;
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
		public override function setRank(inRank:Number):void
		{

			if (this.colorRangeArr)
			{
				this.rank = inRank - 1;
				if (this.rank == -2)
				{
					this.hideMeter();
				} else
				{
					this.colorRGB = this.colorRangeArr[this.rank];
				}
			} else 
			{
				this._debugger.errorTrace("Attempt to upate meter when Color Range has not been assigned.");
			}		
		}

		/*
		*  Name:  	setPositionPercent
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inPercent Number The percent to move it.
		*/
		public function setPercentHours(inPercent:Number):void
		{
			if (dataCell)
			{
				this.dataCell.x = 	(this.valueInverseBool) ? 
									(this.dataCell.width * (1 - inPercent)) :
									(this.dataCell.width * inPercent);
			}
		}
		
		public function buttonChange(event:MouseEvent):void
		{
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
		public function addMeterListener(inFunction:Function):void
		{
			this._listener_array = (this._listener_array == null) ? new Array() : this._listener_array;
			this._listener_array.push(inFunction);
		}
		/******************************************************************************************************
		**  EVENTS
		*******************************************************************************************************/		

		public function rollOut(event:MouseEvent):void
		{
			this.outline.visible = false;
		}

		public function rollOver(event:MouseEvent):void
		{
			this.outline.visible = true;	
		}

		public function get highlight():Boolean
		{
			return this.outline.visible;
		}
		public function set highlight(inBool:Boolean):void
		{
			if (this.isButtonBool)
			{
				this.outline.visible = inBool;
			}
		}
		
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/		
		private function notifyListeners(event:MouseEvent):void
		{
			for (var i:Number = 0; i < this._listener_array.length; i++)
			{
				this._listener_array[i](this,event);
			}
		}
	}
}