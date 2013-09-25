package org.wsimpson.ui

/*
** Title:	Meter.as
** Purpose: Base class for all meter UI objects
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.MovieClip;
	import flash.events.Event;	

	// UI
	import org.wsimpson.ui.cell.GradientCell;
	import org.wsimpson.ui.MeterConst
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.ImageUtil;
	
	// Interface
	import org.wsimpson.interfaces.IMeter;

	
	public class Meter extends MeterConst implements IMeter
	{
		// public Instance Variables
        public var isButtonBool:Boolean;		// Creates trace statements both in debug window and output window

		// protected Instance Variables
        protected var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window

		// Required Stage elements
		protected var mask_outline:MovieClip;	// Stage mask
		protected var rank:Number;				// Index to the colorRangeArr
		protected var meterValue:Number;		// The actual value the meter represents
		protected var colorRangeArr:Array;		// The value that will be masked
		protected var dataCell:GradientCell;	// The value that will be masked

		protected var defaultColor:String;		// Default Color
		protected var valuePercentBool:Boolean;	// Boolean indicating whether the rank or the value determine 	percent presented.
		protected var valueInverseBool:Boolean;	// Boolean indicating whether to inverse the percentage when displaying the meter.
		protected var origPercentBool:Boolean;	// Original - allows for reset of a dynamic value
		protected var origInverseBool:Boolean;	// Original - allows for reset of a dynamic value
		protected var maxValue:Number;			// The maximum value for the range
		protected var meterLabel:String;		// The assigned meterLabel

		// Private Instance Variables
		private var _cellMask:MovieClip;		// Stage mask
		private var _percent:Number;			// Percent to display
		private var _maskArea:Number;			// Calculated mask area
		private var _totalArea:Number;			// Calculated total area
		private var _currentColor:String;		// Current Color
		
		// Constructor
		public function Meter()
		{
			super();
			
			this._debugger = DebugUtil.getInstance();
			this._percent = 1;
			this.rank = 0;
			this.maxValue = 0;
			this.origPercentBool = this.valuePercentBool = true;
			this.origInverseBool = this.valueInverseBool = true;
			this.isButtonBool = false;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/
		/**
		*  Name:  	Reset
		*/		
		public function reset()
		{
			this._percent = 1;
			this.rank = 0;
			this.maxValue = 0;
			this.x = 0;
			this.y = 0;
			this.dataCell.x = 0;
			this.dataCell.y = 0;
			this.valuePercentBool = this.origPercentBool;
			this.valueInverseBool = this.origInverseBool;
			this.meter_label = "";
			this.setValue(this._percent);
		}
		
		/*
		*  Name:  	meter_label
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inValue String Value The default color for the meter
		*  @return String
		*/
		public function get meter_label():String
		{
			return this.meterLabel;
		}
		public function set meter_label(inValue:String):void
		{
			this.meterLabel = inValue;
		}

		/*
		*  Name:  	setDefaultColor
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inValue String Value The default color for the meter
		*  @return String
		*/
		public function get default_color():String
		{
			return this.defaultColor;
		}
		public function set default_color(inValue:String):void
		{
			this.defaultColor = inValue;
		}

		/*
		*  Name:  	setColorArray
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inArray Array An array of colors
		*  @return Array
		*/
		public function get color_array():Array
		{
			return this.colorRangeArr;
		}
		public function set color_array(inArray:Array):void
		{
			this.colorRangeArr = inArray;
		}

				
		/**
		*  Name:  	Mask for the data cell
		*/
		public function get cell_mask():MovieClip
		{
			return this._cellMask;
		}
		
		public function set cell_mask(inMask:MovieClip):void
		{
			this._cellMask = inMask;
			if (this.dataCell)
			{
				this.dataCell.mask = this._cellMask;
			}
		}

		/**
		*  Name:  	Maximum number of layovers defined in the glyph configuration
		*/
		public function get max_value():Number
		{
			return this.maxValue;
		}
		
		public function set max_value(inMax:Number):void
		{
			this.maxValue = inMax;
		}

		/**
		*  Name:  	Maximum number of layovers defined in the glyph configuration
		*/
		public function get meter_value():Number
		{
			return this.meterValue;
		}
		
		public function set meter_value(inNum:Number):void
		{
			this.meterValue = inNum;
		}

		/**
		*  Name:  	RGB String Value
		*/
		public function get colorRGB():String
		{
			return this._currentColor;
		}
		
		public function set colorRGB(inColor:String):void
		{
			this._currentColor = inColor;
			if (this.dataCell)
			{
				this.dataCell.setRGB_CSS(this._currentColor);
			}
		}
		
		/**
		*  Name:  	Indicates whether that rank should be used for percentage display
		*/
		public function get useRank():Boolean
		{
			return !this.valuePercentBool;
		}
		
		public function set useRank(inRankBool:Boolean):void
		{
			this.valuePercentBool = !inRankBool;
		}
		
		/**
		*  Name:  	Indicates whether that value should be used for percentage display
		*/
		public function get useValue():Boolean
		{
			return this.valuePercentBool;
		}
		
		public function set useValue(inRankBool:Boolean):void
		{
			this.valuePercentBool = inRankBool;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		// Hide the meter window
		public function hideMeter():void {
			this.visible = false;
		}

		// Hide the meter window
		public function showMeter():void {
			this.visible = true;
		}
		
		/*
		*  Name:  	refresh
		*  Purpose:  Updates the display
		*/
		public function refresh():void
		{
			this.showMeter();
		}

		/*
		*  Name:  	calculateArea
		*  Purpose: Determines the area occupied by the mask
		*
		*  @return Number Returns the total number of pixels used by the mask
		*/
		public function calculateArea():Number
		{
			return ImageUtil.calcImageArea(this._cellMask);		
		}
		
		/*
		*  Name:  	calculatePercentArea
		*  Purpose: Determines the meter area occupied by the mask
		*
		*  @return Number Returns the percent of meter pixels occupied by the mask
		*/
		public function calculatePercentArea():Number
		{
			this._maskArea = (this._maskArea) ? this._maskArea : this.calculateArea();
			this._totalArea = this.width * this.height;
			return (this._maskArea / this._totalArea);		
		}
		
		/*
		*  Name:  	setDefaultColor
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inValue String Value The default color for the meter
		*/
		public function setDefaultColor(inValue:String):void
		{
			this.default_color = inValue;
		}

		/*
		*  Name:  	setColorArray
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inArray Array An array of colors
		*/
		public function setColorArray(inArray:Array):void
		{
			this.color_array = inArray;
		}	
		
		/*
		*  Name:  	setPositionPercent
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inPercent Number The percent to move it.
		*/
		public function setPositionPercent(inPercent:Number):void {

			if (dataCell)
			{
				this.dataCell.y = 	(this.valueInverseBool) ? 
									(this.dataCell.height * (1 - inPercent)) :
									(this.dataCell.height * inPercent);
			}
		}
		
		/*
		*  Name:  	setRank
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inRank Number The rank to assign to move it.
		*/
		public function setRank(inRank:Number):void 
		{		
			if (this.colorRangeArr)
			{
				this.rank = inRank;
				if (this.rank == -2)
				{
					this.hideMeter();
				} else
				{			
					this.setPositionPercent(this.rank / this.colorRangeArr.length);
					this.colorRGB = this.colorRangeArr[this.rank];
				}
			} else if (!this.colorRangeArr)
			{
				this._debugger.errorTrace("Attempt to upate meter when Color Range has not been assigned.");
			}						
			
		}
		
		/*
		*  Name:  	setValue
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inRank Number The rank to assign to move it.
		*/
		public function setValue(inValue:Number):void {
			
			// Handle the off by one error
			this.maxValue += 1;
			if (this.meterValue == -2)
			{
				this.hideMeter();
			} else
			{		
				this.setPositionPercent(inValue);					
			}
			this.colorRGB = this.defaultColor;		
		}
		
		/*
		*  Name:  	assignValues
		*  Purpose: Defines the individual values used by the meter.
		*  @param inArr Array Array of value Objects.
		*/
		public function assignValues(inArr:Array):void {
			if (inArr != null)
			{
				this.default_color = inArr[DATA_DEFAULT_COLOR];
				this.color_array = inArr[DATA_COLOR];
				this.max_value = inArr[DATA_MAX_VALUE];
				this.meter_value = inArr[DATA_DISPLAY_VALUE];
				this.meter_label = inArr[DATA_LABEL];
				this._percent = inArr[DATA_PERCENTILE];
				if (this.valuePercentBool)
				{

					this.setRank(inArr[DATA_RANK]);
				}
				else 
				{				
					this.setValue(inArr[DATA_PERCENTILE]);
				}	
			} else {				
				this.colorRGB = this.defaultColor;
				this.hideMeter();				
			}
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		
		public function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.init();
		}
		
		/******************************************************************************************************
		**  PROTECTED
		*******************************************************************************************************/
		
		// Initialize
		protected function init()
		{
			this.graphics.clear();
			this.addGradientCell();
		}
		
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/
		private function addGradientCell()
		{		
			this.dataCell = new GradientCell();
			this.colorRGB = CELL_DEFAULT;

			this.dataCell.cell_height = this._cellMask.height;
			this.dataCell.cell_width = this._cellMask.width;
			this.dataCell.mask = this._cellMask;
			
			this.dataCell.y = 100;
			
			this.addChild(this.dataCell);
			
			// Position Outline above the dataCell
			// see:  http://www.newgrounds.com/bbs/topic/699428 
			setChildIndex(this.dataCell, getChildIndex( this.mask_outline ));
			
			this.dataCell.drawRect();
			this.setPositionPercent(this._percent);
		}
    }
}