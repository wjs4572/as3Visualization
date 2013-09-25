package org.wsimpson.ui

/*
** Title:	Resizable.as
** Purpose: Adds resize functions aware of scaling to the display object.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.MovieClip;
		
	// Store Definitions
	import org.wsimpson.store.OrderStore;
	
	// Utitlies
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.PointUtil;
	import org.wsimpson.util.StringUtil;
	
	public class Resizable extends MovieClip
	{
		// XML Parents Definition
		public static const HORIZONTAL = 0;									// index value for array containing position or size information
		public static const VERTICAL = 1;									// index value for array containing position or size information		
		private static const POSITIONS = "positions";						// field labels
		private static const SCALING = "scale";								// field labels
		private static const SIZING = "size";								// field labels
		private static const DISPLAY_VALUES = "display";					// field labels
		private static const LABEL_X = "x";									// field labels
		private static const LABEL_Y = "y";									// field labels
		private static const LABEL_GLOBAL_X = "global_x";					// field labels
		private static const LABEL_GLOBAL_Y = "global_y";					// field labels
		private static const LABEL_HEIGHT = "height";						// field labels
		private static const LABEL_WIDTH = "width";							// field labels
		private static const LABEL_SCREEN_HEIGHT = "screen_height";			// field labels
		private static const LABEL_SCREEN_WIDTH = "screen_width";			// field labels
		private static const LABEL_SCALEX = "scaleX";						// field labels
		private static const LABEL_SCREEN_SCALEX = "screen_scaleX";			// field labels
		private static const LABEL_SCALEY = "scaleY";						// field labels
		private static const LABEL_SCREEN_SCALEY = "screen_scaleY";			// field labels

		// Protected instance variables
		protected var _maxSize:Array;					// Maximum size
		
		// Private instance variables
		private var _minHeight:Number;					// used to ensure the minimum height is displayed
		private var _minWidth:Number;					// used to ensure the minimum width is displayed
		private var _debugger:DebugUtil;				// Debugger
		
		// Constructor
		public function Resizable()
		{
			super();
			this._minHeight = 0;
			this._minWidth = 0;
			this._debugger = DebugUtil.getInstance();
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/
		/*
		*  Name:  	MaxSize
		*  Purpose: Size and reposition the object so X percent shows.
		*
		*  @param inArr Array The max size available for this glyph
		*/
		public function get maxSize():Array 
		{
			return this._maxSize;
		}
		
		public function set maxSize(inArr:Array):void 
		{
			this._maxSize = inArr;
			this.width = this._maxSize[HORIZONTAL];
			this.height = this._maxSize[VERTICAL];		
		}
		
		/*
		*  Minimum screen size of the display object
		*/
		public function get minHeight():Number
		{
			return this._minHeight;
		}
		public function set minHeight(inNum:Number):void 
		{
			this._minHeight = inNum;
		}

		/*
		*  Minimum screen size of the display object
		*/
		public function get minWidth():Number
		{
			return this._minWidth;
		}
		public function set minWidth(inNum:Number):void 
		{
			this._minWidth = inNum;
		}

		/*
		*  The actual scale applied to the object
		*/
		public function get fullScale():Object
		{
			return PointUtil.fullScale(this);
		}
		public function set fullScale(inObj:Object):void 
		{
			// Do Nothing
		}

		/*
		*  @param inNum Number Is the required pixel size for the width on screen
		*/
		public function get screenWidth():Number
		{
			return (this.fullScale.scaleX == this.scaleX) ? this.width : (this.width * this.fullScale.scaleX);
		}
		public function set screenWidth(inNum:Number):void 
		{
			var tempWidth:Number;

			tempWidth = (this._minWidth > inNum) ? this._minWidth : inNum;
			this.width = tempWidth / this.fullScale.scaleX;
		}

		/*
		*  @param inNum Number Is the required pixel size for the height on screen
		*/
		public function get screenHeight():Number
		{
			return (this.fullScale.scaleY == this.scaleY) ? this.height : (this.height * this.fullScale.scaleY);
		}
		public function set screenHeight(inNum:Number):void 
		{
			var tempHeight:Number;
			
			tempHeight = (this._minHeight > inNum) ? this._minHeight : inNum;
			this.height = tempHeight / this.fullScale.scaleY;	
		}

		/*
		*  @param inNum Number Is the required pixel size of the movement on the x axis
		*/
		public function moveScreenX(inNum:Number):void 
		{
			var tempInt:int;
			var tempNum:Number;
			tempNum = (this.scaleX == this.fullScale.scaleX) ? inNum : (inNum / this.fullScale.scaleX);
			tempInt = Math.round(tempNum);
			this.x += tempInt;
		}

		/*
		*  @param inNum Number Is the required pixel size of the movement on the Y axis
		*/
		public function moveScreenY(inNum:Number):void 
		{		
			var tempInt:int;
			var tempNum:Number;
			tempNum = (this.scaleY == this.fullScale.scaleY) ? inNum : (inNum / this.fullScale.scaleY);
			tempInt = Math.round(tempNum);
			this.y += tempInt;			
		}
		
		/******************************************************************************************************
		**  Public
		*******************************************************************************************************/

		/**
		*  Name:  	postionXML
		*  Purpose:	Creates a string value containing the position information for the MovieClip
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*/
		public function positionXML():String
		{
			var tempObj:Object;
			var tempStore:OrderStore;
			tempStore = new OrderStore();
			tempObj = PointUtil.localToGlobal(this);
			//tempStore.newObj();
			tempStore.addNameValue(LABEL_X,this.x);
			tempStore.addNameValue(LABEL_Y,this.y);
			tempStore.addNameValue(LABEL_GLOBAL_X,tempObj.x);
			tempStore.addNameValue(LABEL_GLOBAL_Y,tempObj.y);
			
			return StringUtil.createXMLParent(POSITIONS,tempStore.toXMLString());
		}
		
		/**
		*  Name:  	scaleXML
		*  Purpose:	Creates a string value containing the scale information for the MovieClip
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*/
		public function scaleXML():String
		{
			var tempStore:OrderStore;
			var tempObj:Object;
			
			tempObj = PointUtil.localToGlobal(this);
			tempStore = new OrderStore();
			//tempStore.newObj();
			tempStore.addNameValue(LABEL_SCALEX,this.scaleX);
			tempStore.addNameValue(LABEL_SCALEY,this.scaleY);
			tempStore.addNameValue(LABEL_SCREEN_SCALEX,this.fullScale.scaleX);
			tempStore.addNameValue(LABEL_SCREEN_SCALEY,this.fullScale.scaleY);
			return StringUtil.createXMLParent(SCALING,tempStore.toXMLString());
		}
		
		/**
		*  Name:  	sizeXML
		*  Purpose:	Creates a string value containing the size information for the MovieClip
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*/
		public function sizeXML():String
		{
			var tempStore:OrderStore;
			var tempObj:Object;
			
			tempObj = PointUtil.localToGlobal(this);
			tempStore = new OrderStore();
			//tempStore.newObj();
			tempStore.addNameValue(LABEL_WIDTH,this.width);
			tempStore.addNameValue(LABEL_HEIGHT,this.height);
			tempStore.addNameValue(LABEL_SCREEN_WIDTH,this.screenWidth);
			tempStore.addNameValue(LABEL_SCREEN_HEIGHT,this.screenHeight);
			return StringUtil.createXMLParent(SIZING,tempStore.toXMLString());
		}

		/**
		*  Name:  	displayValuesXML
		*  Purpose:	Creates a string value containing the display values for the MovieClip
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*/
		public function displayValuesXML():String
		{
			return "\n" + StringUtil.createXMLParent(DISPLAY_VALUES,(positionXML() + "\n" +scaleXML() + "\n" + sizeXML() + "\n" ));
		}

	}
}