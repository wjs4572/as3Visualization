package org.wsimpson.ui

/*
** Title:	Glyph.as
** Purpose: Base class for all glyph UI objects
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	// Adobe UI
	import flash.text.StyleSheet;
	import flash.text.TextField;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;

	// Visualization Application Classes	
	import org.wsimpson.ui.GlyphConst
	
	// Style Definitions
	import org.wsimpson.styles.Style;	
		
	public class GlyphOver
	{
		// protected Instance Variables
        protected var _debugger:DebugUtil;			// Creates trace statements both in debug window and output window

		// Private Instance Variables		
		private var _htmlText:String;				// The value that will be masked
		private var _id:String;						// The unique identifier for the glyph
		private var _style:Style;					// CSS Stylesheet assigned to the screen	
		private var _tf:TextField;					// Textfield used for the roll over
		
		// Constructor
		public function GlyphOver()
		{
			this._debugger = DebugUtil.getInstance();			
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/
		/**
		*  Name:  	The HTML to display on rollover
		*/
		public function get htmlOver():String
		{
			return this._htmlText;
		}
		
		public function set htmlOver(inStr:String):void
		{
			this._htmlText = StringUtil.replaceTabs(inStr);
		}

		/*
		*  @param inStr New Button Label
		*/
		public function get id():String
		{
			return this._id;
		}
		public function set id(inStr:String):void 
		{	
			var idPattern:RegExp;
			var tempStr:String;
			
			this._id = inStr;
			
			tempStr = this._htmlText
			idPattern = new RegExp(GlyphConst.GLYPHS_ID);
			this._htmlText = (tempStr) ? tempStr.replace(idPattern,this._id) : "";
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
		}
		
		/*
		*  @param TextField for display roll over detail
		*/
		public function get textField():TextField
		{
			return this._tf;
		}
		public function set textField(inTF:TextField):void 
		{
			this._tf = inTF;
		}

		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		/*
		*  Name:  	updateField
		*  Purpose: updates
		*  @param inArr Array The field values to update in the htmlText
		*  @param inColor String The color used by the meter
		*/
/*
******************
**  The magic string "value outside range" needs to access the "localization" class which does not yet exist
**  this should be a singleton initiated by the contoller with the pointer to the model
******************
*/			

		public function updateField(inArr:Array,inColor:String):void
		{
			var colorPattern:RegExp;	
			var fieldPattern:RegExp;
			var idPattern:RegExp;
			var rankPattern:RegExp;
			var valuePattern:RegExp;	
			var colorStr:String;
			var colorStyle:String;
			var fieldStr:String;
			var rankStr:String;
			var tempStr:String;
			var valueStr:String;
			var inValue:String;
			var tempObj:Object;
			var tempInx:String;
			tempInx = (inArr == null) ? "5" : inArr[GlyphConst.DATA_INDEX]
			colorStyle = GlyphConst.STYLE_NAME + tempInx;
			
			// Define Fields
			colorStr = GlyphConst.GLYPHS_FIELD_COLOR;
			fieldStr = GlyphConst.GLYPHS_FIELD_NAME;
			rankStr = GlyphConst.GLYPHS_FIELD_RANK;
			valueStr = GlyphConst.GLYPHS_FIELD_VALUE;
					
			// Define Patterns
			idPattern = new RegExp(GlyphConst.GLYPHS_FIELD_INDEX);
			colorPattern = new RegExp(colorStr.replace(idPattern,tempInx),"g");
			fieldPattern = new RegExp(fieldStr.replace(idPattern,tempInx),"g");
			rankPattern = new RegExp(rankStr.replace(idPattern,tempInx),"g");
			valuePattern = new RegExp(valueStr.replace(idPattern,tempInx),"g");
		
			// Update RollOver Text
			tempStr = this._htmlText;
			tempStr = tempStr.replace(colorPattern,inColor);
			// Define Values
			if (inArr != null)
			{
				inValue = 	(inArr[GlyphConst.DATA_DISPLAY_VALUE] == "-1") ? 
							"value outside range" : 
							inArr[GlyphConst.DATA_DISPLAY_VALUE];	
				tempStr = tempStr.replace(fieldPattern,StringUtil.trim(inArr[GlyphConst.DATA_LABEL]));
				tempStr = tempStr.replace(rankPattern,StringUtil.trim(inArr[GlyphConst.DATA_RANK]));
				tempStr = tempStr.replace(valuePattern,StringUtil.trim(inValue));
			}
			
			this._style = (!this._style) ?  new Style() : this._style;
			this._style = (this._tf) ? (this._tf.styleSheet as Style) : this._style;

			tempObj = this._style.getStyle(colorStyle);
			if (tempObj == null) 
			{
				this.sendError("GlyphOver:  Missing CSS style for = " + colorStyle);
			} else
			{
				tempObj.color = inColor;
				this._style.setStyle(colorStyle,tempObj);
				this._tf.styleSheet = this._style;
			}
			this._tf.condenseWhite = false;
			this._htmlText = tempStr;
		}
		
		/******************************************************************************************************
		**  PROTECTED
		*******************************************************************************************************/

		protected function sendError(errorMsg:String):void
		{
			throw new Error(errorMsg);	
		}
		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/

    }
}