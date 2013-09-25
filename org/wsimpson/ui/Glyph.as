package org.wsimpson.ui

/*
** Title:	Glyph.as
** Purpose: Base class for all glyph UI objects
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.accessibility.AccessibilityProperties;		
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.text.TextField;	
	
	// Style Definitions
	import org.wsimpson.styles.Style;	
	
	// UI
	import org.wsimpson.ui.ButtonBase;
	import org.wsimpson.ui.cell.GradientCell;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.DispalyObjectContainerUtil;
	import org.wsimpson.util.ImageUtil;
	import org.wsimpson.util.StringUtil;
	
	// Visualization Application Classes
	import org.wsimpson.ui.GlyphConst
	import org.wsimpson.ui.GlyphOver
	import org.wsimpson.interfaces.IGlyph
	
	public class Glyph extends GlyphConst implements IGlyph
	{
		// Parameters
		public var defaultColors:Array;				// The default colors
		public var glyphCount:Number;				// Number of glyphs		
	
		// protected Instance Variables
        protected var _debugger:DebugUtil;			// Creates trace statements both in debug window and output window

		// Private Instance Variables		
		private var dataCell:GradientCell;			// The value that will be masked
		private var _button:ButtonBase;				// Identifies the glyph		
		private var _style:Style;					// CSS Stylesheet assigned to the screen
		private var _fullSize:Array;				// Maximum size
		private var _meterArr:Array;				// The value that will be masked
		private var _valueArr:Array;				// The value that will be masked
		private var _listener:Function;				// Identifies the glyph
		private var _maskArea:Number;				// Calculated mask area
		private var _percent:Number;				// Percent to display
		private var _tempPercent:Number;			// Retain percent
		private var _totalArea:Number;				// Calculated total area
		private var _label:String;					// Percent to display
		private var _margin:String;					// Percent to display
		private var _rolloverObj:GlyphOver;			// String used for rollovers
		private var _targetObj:GlyphOver;			// String used for rollovers
		private var _swapObj:*;						// Storage for temp Object
		
		// Required Stage elements
		protected var cell_mask:MovieClip;			// Stage mask
	
		// Constructor
		public function Glyph()
		{
			super();
			
			this._debugger = DebugUtil.getInstance();
			this._margin = "0";
			this._percent = 1;
			this._fullSize = new Array();
			this._fullSize[HORIZONTAL] = this.width;
			this._fullSize[VERTICAL] = this.height;
			this._targetObj = new GlyphOver();
			this._rolloverObj = new GlyphOver();
			this.glyphCount = 0;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	
		}

		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/

		/*
		*  @param inStr Rollover details template
		*/
		public function get data_array():Array
		{
			return this._valueArr;
		}
		public function set data_array(inArr:Array):void 
		{
			this._valueArr = inArr;
		}

		/*
		*  @param inStr Rollover details template
		*/
		public function get rolloverStr():String
		{
			return this._rolloverObj.htmlOver;
		}
		public function set rolloverStr(inStr:String):void 
		{
			this._rolloverObj.htmlOver = inStr;
		}

		/*
		*  @param inStr Rollover targets template
		*/
		public function get targetStr():String
		{
			return this._targetObj.htmlOver;
		}
		public function set targetStr(inStr:String):void 
		{
			this._targetObj.htmlOver = inStr;
		}

		/*
		*  @param inStr Rollover style
		*/
		public function get rolloverStyle():Style
		{
			return this._rolloverObj.style;
		}
		public function set rolloverStyle(inStyle:Style):void 
		{
			this._rolloverObj.style = inStyle;
			this._targetObj.style = inStyle;
		}

		/*
		*  @param TextField for display roll over detail
		*/
		public function get detailsTF():TextField
		{
			return this._rolloverObj.textField;
		}
		public function set detailsTF(inTF:TextField):void 
		{
			this._rolloverObj.textField = inTF;
		}

		/*
		*  @param TextField for display roll over detail
		*/
		public function get targetTF():TextField
		{
			return this._targetObj.textField;
		}
		public function set targetTF(inTF:TextField):void 
		{
			this._targetObj.textField = inTF;
		}

		/*
		*  @param inStr New Button Label
		*/
		public function get id():String
		{
			return this._rolloverObj.id;
		}
		public function set id(inStr:String):void 
		{
			this._rolloverObj.id = (inStr) ? inStr : "";
		}
		
		/*
		*  @param inStr New Button Label
		*/
		public function get label():String
		{
			return this._label;
		}
		public function set label(inStr:String):void 
		{
			this._label = inStr;
			if (this._button)
			{
				this._button.buttonLabel = this._label;
			}
		}

		/*
		*  @param inStr New Button Style
		*/
		public function get style():Style 
		{
			return this._style;
		}
		public function set style(inStyle:Style):void 
		{
			this._style = inStyle;

			if (this._button)
			{
				this._button.style = this._style;
			}
		}

		/*
		*  @return String 
		*  @param inStr New Button Label
		*/
		public function get margin():String 
		{
			return this._margin;
		}

		public function set margin(inMargin:String):void 
		{
			var marginWidth:uint;
			var marginHeight:uint;
			var tempMargin:uint;
			this._margin = (inMargin) ? inMargin : this._margin;
			if (this._margin.indexOf(PIXELS) > 0)
			{
				tempMargin = uint(this._margin.replace(PIXELS,""));
				marginWidth = tempMargin;
				marginHeight = tempMargin;
			} else
			{
				tempMargin = (StringUtil.isInteger(this._margin)) ? uint(this._margin) : 0;
				marginWidth = this._maxSize[HORIZONTAL] * (tempMargin / 100);
				marginHeight = this._maxSize[VERTICAL] * (tempMargin / 100);				
			}
			this.width = this._maxSize[HORIZONTAL] - marginWidth;
			this.height = this._maxSize[VERTICAL] - marginHeight;
			this.x += (marginWidth > 0) ? (marginWidth / 2) : 0;
			this.y += (marginHeight > 0) ? (marginHeight / 2) : 0;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		/**
		*  name:  makeAccessible
		*  @param inDesc	String	String describing the button
		*/		
        public function makeAccessible(inDesc:String = "glyph button"):void
		{
			var tempStr:String;
			tempStr = (inDesc == "") ? this._rolloverObj.htmlOver : inDesc;
			this._button.makeAccessible(tempStr);
		}
		
		public function hideGlyph():void 
		{
			this.visible = false;
		}

		public function showGlyph():void 
		{
			this.visible = true;
		}

		public function moveFront():void
		{
			if (this.parent != null)
			{
				this._swapObj = this.parent.getChildAt(this.parent.numChildren-1);
				if (this._swapObj != null)
				{
					this.parent.swapChildren(this, this._swapObj);
				}
			}
		}
		
		public function moveBack():void
		{
			if ((this.parent != null) && (this._swapObj != null))
			{
				{
					this.parent.swapChildren(this, this._swapObj);
				}
			}
		}
		
		/*
		*  Name:  	reset
		*  Purpose:  Resets the meters to original values
		*/
		public function reset():void 
		{
			if (this._meterArr)
			{
				// Update values
				for (var i:uint=0; i < this._meterArr.length; i++)
				{
					if (this._meterArr[i])
					{
						this._meterArr[i].reset();
					}
				}
			}
			this._meterArr = new Array();
		}
					
		/*
		*  Name:  	refresh
		*  Purpose:  Updates the display
		*/
		public function refresh():void {
			this.showGlyph();
		}	

		/*
		*  Name:  	calculateArea
		*  Purpose: Determines the area occupied by the mask
		*
		*  @return Number Returns the total number of pixels used by the mask
		*/
 		public function calculateArea():Number {
			return ImageUtil.calcImageArea(this.cell_mask);		
		} 
		
		/*
		*  Name:  	calculatePercentArea
		*  Purpose: Determines the meter area occupied by the mask
		*
		*  @return Number Returns the percent of meter pixels occupied by the mask
		*/
 		public function calculatePercentArea():Number {
			this._maskArea = (this._maskArea) ? this._maskArea : this.calculateArea();
			this._totalArea = this.width * this.height;
			return (this._maskArea / this._totalArea);	
		}

		/*
		*  Name:  	assignMeters
		*  Purpose: Assign the values to the Meters.
		*  @note 	Expects 2 dimensional array where the rows contain two values the rank and the colorScale
		*  @param inArr Array Color Array and value for each of the meters
		*/
		public function assignMeters(inArr:Array):void
		{
			this._valueArr = inArr;
			if (this.readySetMeters())
			{
				this.setMeters();
			}
		}

		/*
		*  Name:  	addGlyphListener
		*  Purpose: Captures the button click
		*  @param inFunc Function Callback Listener
		*/
		public function addGlyphListener(inFunc:Function):void
		{
			this._listener = inFunc;
		}
		
		/*
		*  Name:  	getMeterColor
		*  Purpose: This returns the color currently assigned to the specificed meter, empty string if nonexistent
		*  @param inStr int Meter Color
		*/
		public function getMeterColor(inID:int):String
		{
			return (this._meterArr[inID]) ? this._meterArr[inID].colorRGB : "";
		}
		
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		
		public function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.init();
		}
		
		/**
		*  Name:  	mouseEvent
		*  Purpose:  An click event has occurred with a button.
		*/
        public function mouseEvent(inMC:MovieClip,event:MouseEvent):void
		{
			this._listener(inMC,event);
		}

		/**
		*  Name:  	trigger
		*  Purpose: Pass a mouse event
		*/
        public function trigger(event:MouseEvent):void
		{
			this._button.buttonChange(event);
		}
		
		protected function sendError(errorMsg:String):void
		{
			throw new Error(errorMsg);	
		}
		
		/******************************************************************************************************
		**  protected
		*******************************************************************************************************/
		
		// Initialize
		protected function init():void
		{
			this._meterArr = new Array();
			this.setButton();
			this.getMeters();
			this.showGlyph();
			if (this.readySetMeters())
			{
				this.setMeters();
			}
		}
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/

		private function readySetMeters():Boolean
		{
			return (this._meterArr && (this._meterArr.length > 0) && this._valueArr);
		}
		
		private function setButton():void 
		{
			var tempArr:Array;
			tempArr = DispalyObjectContainerUtil.getMatchingChildren(this,new RegExp(BUTTON_PATTERN));
			if (tempArr[0])
			{
				this._button = tempArr[0];			
				this._button.addButtonListener(this.mouseEvent);
				this._button.style = this._style;
				this._button.id = this.id;
				this._button.buttonLabel = (this.label) ? this.label : "";
				this.makeAccessible();
			} else
			{
				this._debugger.warningTrace("Missing the required graphButton definition on glyph");
			}
		}
		
		// http://www.kirupa.com/forum/showthread.php?t=296950
		private function getMeters():void {
			var tempArr:Array;
			var tempRegExp:RegExp;
			tempRegExp = /\d$/;
			tempArr = DispalyObjectContainerUtil.getMatchingChildren(this,new RegExp(METER_PATTERN));
			for (var i:uint; i < tempArr.length; i++)
			{
				var tempInt:uint;
				tempInt = tempArr[i].name.match(tempRegExp);			
				this._meterArr[tempInt] = tempArr[i];
				this._meterArr[tempInt].gotoAndStop(1);
			}
		}
		
		private function setMeters():void 
		{
	
			var tempArr: Array;
			
			// Reduces two loops to one
			tempArr = (this._meterArr.length > this._valueArr.length) ? this._meterArr : this._valueArr;
			
			// Update values
			for (var i:uint=0; i < tempArr.length; i++)
			{
				// If the meter has been found assign it the values received.
				if (this._meterArr[i])
				{			
					this._meterArr[i].default_color = this.defaultColors[i];
					this._meterArr[i].assignValues(this._valueArr[i]);
				
					if (this._meterArr[i].isButtonBool)
					{
						this._meterArr[i].addMeterListener(this.mouseEvent);
						this._meterArr[i].buttonLabel = this._label;
					}
					this._rolloverObj.updateField(this._valueArr[i],this._meterArr[i].colorRGB);
				} else if (this._valueArr[i])
				{
					if (this._valueArr[i][GlyphConst.DATA_INDEX])
					{
						// Assuming that if there is no meter than ranking will not be applied to the field color
						this._rolloverObj.updateField(this._valueArr[i],this._valueArr[i][GlyphConst.DATA_DEFAULT_COLOR]);
						this._targetObj.updateField(this._valueArr[i],this._valueArr[i][GlyphConst.DATA_DEFAULT_COLOR]);
					}
				}
	
			}
		}

    }
}