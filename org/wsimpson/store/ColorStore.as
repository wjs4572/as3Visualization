package org.wsimpson.store

/*
** Title:	ColorStore.as
** Purpose: A Repository class for managing color scale definitions.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// Utilities
	import org.wsimpson.util.ColorUtil;
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;
   
	public final class ColorStore {
		// Private Constants
		private const GREY = "gray";						// Color name
		private const NAME = "{name}";						// Substitution String
		private const FACTOR = "{factor}";					// Substitution String
		private const ORDER = "{order}";					// Substitution String
		private const VALUE = "{value}";					// Substitution String
		private const DEFAULT_VALUE = "{default_value}";	// Substitution String
		private const CONTENT = "{content}";				// Substitution String
		private const FACTOR_HUE = "hue";					// Substitution String
		private const FACTOR_BRIGHTNESS = "brightness";		// Substitution String
		private const COLOR_FILE = 
				"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<colors>{content}\n</colors>";		// File wrapper
		private const COLOR_ELEMENT = 
				"\n\t<color  factor={factor} name={name} default={default_value}>{content}\n\t</color>";	// Begin tag requires substitution 
		private const SCALE_ELEMENT = 
				"\n\t\t<scale_entry order={order} value={value}></scale_entry>";	// Begin tag requires substitution

		// Private Instance Variables required for Singleton Creation
		private static var instance:ColorStore = new ColorStore();	// Tracks the instantiated class
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;					// Output and diagnostic window			
		private var colorObj:Object;						// Associative array of color scales
		private var contentPattern:RegExp;					// Regular Expression for the content pattern
		private var namePattern:RegExp;						// Regular Expression for the content pattern
		private var defaultPattern:RegExp;					// Regular Expression for the content pattern
		private var factorPattern:RegExp;					// Regular Expression for the content pattern
		private var orderPattern:RegExp;					// Regular Expression for the content pattern
		private var valuePattern:RegExp;					// Regular Expression for the content pattern
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function ColorStore() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use ColorStore.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():ColorStore {
			return instance;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		/**
		*  name:  retrieveColorList
		*  @return Array Array of color scale names
		*/
		public  function retrieveColorList():Array {
			var colorArr:Array;
			colorArr = new Array();
			for (var colorStr:String in this.colorObj)
			{
				colorArr.push(colorStr);
			}
			return colorArr;
		}
		
		/**
		*  name:  getColorScale
		*  @param inColorName String	Name of the Hue
		*  @return Array Array created from the scales
		*/
		public function getColorScale(inColorName):Array
		{
			return this.colorObj[inColorName.toLowerCase()][ORDER];
		}
		
		/**
		*  name:  getColorDefault
		*  @param inColorName String	Name of the Hue
		*  @return String The default color value for the color name
		*/
		public function getColorDefault(inColorName):String
		{
			return this.colorObj[inColorName.toLowerCase()][DEFAULT_VALUE];
		}		
		
		/**
		*  name:  getColorScaleLength
		*  @param inColorName String	Name of the Hue
		*  @return Number Length of the array created from the scales
		*/
		public function getColorScaleLength(inColorName:String):Number
		{
			return this.colorObj[inColorName.toLowerCase()][ORDER].length;
		}

		/**
		*  name:  setColorScale
		*  @param inColorName	String Name of the color scale hue
		*  @param inArr Array	Array of Color RGB value strings in the CSS format "#FFF or #FFFFFF"
		*/
		public function setColorScale(inColorName, inArr:Array):void
		{
			this.colorObj = (this.colorObj == null) ? new Object() : this.colorObj;
			this.colorObj[inColorName.toLowerCase()][ORDER] = inArr;
		}

		/**
		*  name:  hasColor
		*  @param inColorName	String Name of the color scale hue
		*/
		public function hasColor(inColorName):Boolean
		{
			return (this.colorObj[inColorName] != null);
		}
		
		// load color scales
		private function updateColorScales(inXML:XML):void
		{
			var tempXMLList:XMLList;
			tempXMLList = inXML..color;
			this.colorObj = (this.colorObj == null) ? new Object() : this.colorObj;
			
			for each (var item:XML in tempXMLList)
			{			
				var colorXMLList:XMLList;
				var nameStr:String;
				nameStr = item.@name;
				nameStr = nameStr.toLowerCase();
				this.colorObj[nameStr] = new Object();
				this.colorObj[nameStr][ORDER] = new Array();
				colorXMLList = item..scale_entry;
				this.colorObj[nameStr][FACTOR] = item.@factor;	
				this.colorObj[nameStr][DEFAULT_VALUE] = item.@default;	
				for each (var step:XML in colorXMLList)
				{
					this.colorObj[nameStr][ORDER][Number(step.@order)] = step.@value.toString();
				}
			}
		}

		/**
		*  name:  toXMLString
		*  @return String An XML String of the file contents matching the import format
		*/
		public function toXMLString():String
		{
			var tempFileStr:String;
			var tempContentStr:String;
			tempFileStr = COLOR_FILE;
			tempContentStr = "";
			
			for (var tempStr in this.colorObj)
			{
				var tempColorStr:String;
				var colorScaleStr:String;
				tempColorStr = COLOR_ELEMENT;
				tempColorStr = tempColorStr.replace(this.factorPattern,StringUtil.doubeQuoteStr(this.colorObj[tempStr][FACTOR]));
				tempColorStr = tempColorStr.replace(this.namePattern,StringUtil.doubeQuoteStr(tempStr));
				tempColorStr = tempColorStr.replace(this.defaultPattern,StringUtil.doubeQuoteStr(this.colorObj[tempStr][DEFAULT_VALUE]));
				colorScaleStr = "";
				for (var i:uint = 0; i < this.colorObj[tempStr][ORDER].length; i++)
				{
					var scale_entryStr:String;
					scale_entryStr = SCALE_ELEMENT;
					scale_entryStr = scale_entryStr.replace(this.orderPattern,StringUtil.doubeQuoteStr(i.toString()));
					scale_entryStr = scale_entryStr.replace(this.valuePattern,StringUtil.doubeQuoteStr(this.colorObj[tempStr][ORDER][i]));
					colorScaleStr += scale_entryStr;
				}
				tempContentStr += tempColorStr.replace(this.contentPattern,colorScaleStr);
			}
			tempFileStr = tempFileStr.replace(this.contentPattern,tempContentStr);
			return tempFileStr;
		}
		
		/**
		*  name:  toString
		*  @return String An XML String of the file contents matching the import format
		*/
		public function toString():String
		{
			return this.toXMLString();
		}
		
		/**
		*  name:  createGreyScale
		*/
		public function createGreyScale():void
		{
			var colorUtil:ColorUtil;
			var step:Number;
			colorUtil = new ColorUtil(0x000000);  // set to black
			step = 10;
			this.colorObj[GREY] = (this.colorObj[GREY]) ? this.colorObj[GREY] : new Object();
			this.colorObj[GREY][FACTOR] = FACTOR_BRIGHTNESS;					
			this.colorObj[GREY][ORDER] = new Array();			
			for (var i:Number = 0; i < 10; i++)
			{
				colorUtil.value = i * step;
				this.colorObj[GREY][ORDER][i] = "#" + 
												colorUtil.toStringRed(16) +
												colorUtil.toStringGreen(16) +
												colorUtil.toStringBlue(16);
			}
		}

		/**
		*  name:  initColorScales
		*  @param inXML	String	XML definition of the color scales
		*/
		public function initColorScales(inXMLStr:String):void
		{
			this._debugger = DebugUtil.getInstance();
			
			// Substitution Pattern
			this.contentPattern = new RegExp(CONTENT);
			this.namePattern = new RegExp(NAME);
			this.defaultPattern = new RegExp(DEFAULT_VALUE);
			this.factorPattern = new RegExp(FACTOR);
			this.orderPattern = new RegExp(ORDER);
			this.valuePattern = new RegExp(VALUE);
			
			this.updateColorScales(new XML(inXMLStr));
			this.createGreyScale();
		}

	}
}