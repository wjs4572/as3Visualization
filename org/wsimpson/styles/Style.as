package org.wsimpson.styles

/*
** Title:	Style.as
** Purpose: A Repository class for managing the object styling, including text formats used within a project.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Formatting
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
   
	public final class Style extends StyleSheet {
		
		// Default format values
		public static const DISPLAY = "none";					// Stylesheet CSS 'display' supports "inline", "block" or "none"
		public static const FONT_BOLD = "bold";					// Stylesheet CSS
		public static const FONT_ITALIC = "italic";				// Stylesheet CSS
		public static const FONT_NONE = "none";					// Stylesheet CSS
		public static const FONT_NORMAL = "normal";				// Stylesheet CSS
		public static const FONT_UNDERLINE = "underline";		// Stylesheet CSS

		// Private Instance Variables (Properties)
		private	var _debugger:DebugUtil;					// Output and diagnostic window
		private var formatObj:Object;						// An Associative array of TextFormats
		
		// Public Array of Text format values
		public var txtFormatPropArr:Array;
		
		public function Style() {
			super();
			this._debugger = DebugUtil.getInstance();
			this.formatObj = new Object();
			txtFormatPropArr = ["font","size","color"," bold","italic","underline","url","target",
								"align","leftMargin","rightMargin","indent","leading","letterSpacing",
								"kerning"];
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		public  function listFiles():void {
			this._debugger.wTrace("Style Contents - Names:  ");
			for (var i:Number = 0; i < super.styleNames.length; i++)
			{
				this._debugger.wTrace("Style Name:  " + super.styleNames[i]);
			}
		}

		public  function printTextFormat(inTXTFormat:TextFormat):String {
			var tempStr:String = "";
			tempStr = "Style Contents - Listing: \n";
			for (var i:Number=0; i < txtFormatPropArr.length; i++)
			{
				if (inTXTFormat.hasOwnProperty(txtFormatPropArr[i]))
				{
					tempStr += 	"property:  " +	
								txtFormatPropArr[i] + " = " +
								inTXTFormat[txtFormatPropArr[i]];
				} else
				{
					tempStr += 	"## WARNING:  +	property " + txtFormatPropArr[i] + " not defined";
				}
				tempStr += "\n";
			}
			return tempStr;
		}
		
		public  function fileContents():void {
			var tempStr:String = "Style Contents - Listing: \n";
			for (var i:Number = 0; i < super.styleNames.length; i++)
			{
				var tempFormat:TextFormat;
				tempFormat = super.transform(super.getStyle(super.styleNames[i]));
				
				tempStr += "Style Name: " + super.styleNames[i] + "\n";
				tempStr += this.printTextFormat(tempFormat);
			}
			this._debugger.wTrace(tempStr);
		}

		/**
		*  name:  syncStyle
		*  purpose:  Ensures that the Style object lists all styles in the super as well
		*/
		public function syncStyle():void
		{
			for (var i:Number = 0; i < super.styleNames.length; i++)
			{
				var tempStr:String;
				tempStr = super.styleNames[i];
				this.formatObj[tempStr] = (this.formatObj[tempStr] == null) ? super.getStyle(tempStr): this.formatObj[tempStr];
			}
		}
		
		/**
		*  name:  hasStyle
		*  purpose:  Create a new object that can be used as a style
		*  @param inNameStr	String	Name of the format
		*  @return Boolean StyleExists
		*/
		public function hasStyle(inNameStr:String):Boolean
		{
			return this.formatObj.hasOwnProperty(inNameStr);
		}

		private function isPresent(styleName:String, index:int, arr:Array):Boolean {
            return hasStyle(styleName);
        }
		
		/**
		*  name:  hasStyles
		*  purpose:  Confirms the presence of defined styles for the Array of style names
		*  @param inStyleNames	Array	Array of style names
		*  @return Boolean All of the requested styles have definitions
		*/
		public function hasStyles(inStyleNames:Array):Boolean
		{
			return inStyleNames.every(isPresent);
		}
		
		/**
		*  name:  missingStyles
		*  purpose:  Searches the defined styles for expected styles that are missing
		*  @param inStyleNames	Array	Style names
		*  @return Array Names of missing styles
		*/
		public function missingStyles(inStyleNames:Array):Array
		{
			var tempArr:Array;
			tempArr = new Array();
			for each (var styleName:String in inStyleNames)
			{
				if (!this.hasStyle(styleName))
				{
					tempArr.push(styleName);
				}
			}
			return tempArr;
		}
		
		/**
		*  name:  addStyle
		*  purpose:  Create a new object that can be used as a style
		*  @param inNameStr	String	Name of the format
		*  @param inFormat TextFormat Previously created text format
		*/
		public function addStyle (	inNameStr:String, inColor:Object = null, inDisplay:Object = DISPLAY, inFont:Object = null, 
									inSize:Object = null, inFontStyle:Object = FONT_NORMAL, inFontWeight:Object = FONT_NORMAL,  
									inKerning:Object = false, inLeading:Object = null, inLetterSpacing:Object = null, 
									inLeftMargin:Object = null, inRightMargin:Object = null, inAlign:Object = null, 
									inDecoration:Object = FONT_NONE, inIndent:Object = null):void
		{
			var styleObj:Object;
			// Create new
			styleObj = new Object;
			
			// Assign field values
			styleObj.color = inColor;
			styleObj.display = inDisplay;
			styleObj.fontFamily = inFont; // Already defaults to New Times Roman
			styleObj.fontSize = inSize;  // Pixel and Points are not distinguished here
			styleObj.fontStyle = inFontStyle; 
			styleObj.fontWeight = inFontWeight;
			styleObj.kerning = inKerning;
			styleObj.leading = inLeading;
			styleObj.letterSpacing = inLetterSpacing;
			styleObj.marginLeft = inLeftMargin;
			styleObj.marginRight = inRightMargin;
			styleObj.textAlign = inAlign;
			styleObj.textDecoration = inDecoration;
			styleObj.textIndent = inIndent;
			
			// Add Style to super
			super.setStyle(inNameStr,styleObj);
			
			// Keep local reference to the style object
			this.formatObj[inNameStr] = (this.formatObj[inNameStr] == null) ? new Object() : this.formatObj[inNameStr];
		}
		
		/**
		*  name:  addTextFormat
		*  @param inNameStr	String	Name of the format
		*  @see	http://help.adobe.com/en_US/AS3LCR/Flash_10.0/flash/text/TextFormat.html
		*	
		*	Remaining parameters match the constructor for the TextFormat class
		*/
		public function addTextFormat(	inNameStr:String,inFont:String = null, inSize:Object = null,
										inColor:Object = null, inBold:Object = null, inItalic:Object = null, 
										inUnderline:Object = null, inUrl:String = null, inTarget:String = null,
										inAlign:String = null, inLeftMargin:Object = null, 
										inRightMargin:Object = null, inIndent:Object = null, inLeading:Object = null,
										inLetterSpacing:Object = null, inKerning:Object = false):void
		{
			var fontDecoration:String;
			var fontStyle:String;
			var fontWeight:String;
			var tempFormat:TextFormat
			fontDecoration = (inUnderline == "true") ? FONT_UNDERLINE : FONT_NONE;
			fontStyle = (inItalic == "true") ? FONT_ITALIC : FONT_NORMAL;
			fontWeight = (inBold == "true") ? FONT_BOLD : FONT_NORMAL;
			
			this.addStyle(	inNameStr,inColor, null, inFont, inSize, fontStyle, fontWeight, inKerning, inLeading, 
							inLetterSpacing, inLeftMargin, inRightMargin, inAlign, fontDecoration, inIndent);

			tempFormat = new TextFormat(inFont, inSize, inColor, inBold, inItalic, inUnderline, inUrl, 
										inTarget, inAlign, inLeftMargin, inRightMargin, inIndent, inLeading);
			tempFormat.kerning = inKerning;
			this.formatObj[inNameStr] = (this.formatObj[inNameStr] == null) ? new Object() : this.formatObj[inNameStr];
			this.formatObj[inNameStr].txtFormat = tempFormat;
		}

		/**
		*  name:  setStyleTextFormat
		*  @param inNameStr	String	Name of the format
		*  @param inFormat TextFormat Previously created text format
		*/
		public function setStyleTextFormat(	inNameStr:String, inFormat:TextFormat)
		{
			var fontDecoration:String;
			var fontStyle:String;
			var fontWeight:String;
			var tempFormat:TextFormat
			fontDecoration = (inFormat.underline == "true") ? FONT_UNDERLINE : FONT_NONE;
			fontStyle = (inFormat.italic == "true") ? FONT_ITALIC : FONT_NORMAL;
			fontWeight = (inFormat.bold == "true") ? FONT_BOLD : FONT_NORMAL;
			
			this.addStyle(	inNameStr,inFormat.color, null, inFormat.font, inFormat.size, fontStyle, fontWeight,
							inFormat.kerning, inFormat.leading, 
							inFormat.letterSpacing, inFormat.leftMargin, inFormat.rightMargin, inFormat.align, 
							fontDecoration, inFormat.indent);

			this.formatObj[inNameStr] = (this.formatObj[inNameStr]==null) ? new Object() : this.formatObj[inNameStr];
			this.formatObj[inNameStr].txtFormat = inFormat;
		}
		
		/**
		*  name:  getStyleTextFormat
		*  @param inNameStr	String	Name of the format
		*  @return  TextFormat Previously stored text format
		*/
		public function getStyleTextFormat(	inNameStr:String):TextFormat
		{
			if ((!this.hasStyle(inNameStr)) && (this.formatObj[inNameStr].style == null) && (this.formatObj[inNameStr].txtFormat == null))
			{
				throw new Error("Attempt to get a nonexistent TextFormat");
			}else if (this.hasStyle(inNameStr))
			{
				this.formatObj[inNameStr].txtFormat = this.transform(this.getStyle(inNameStr));
			} else if (this.formatObj[inNameStr].txtFormat != null)
			{
				this.formatObj[inNameStr].txtFormat =  super.transform(super.getStyle(inNameStr));
			}
			return this.formatObj[inNameStr].txtFormat;
		}
		
		/**
		*  name:  transform
		*  @param inOBj	Object	Name/Value format pairs
		*  @return  TextFormat Previously stored format
		*/
		public override function transform(inObj:Object):TextFormat
		{
			return super.transform(inObj);
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/

		public  function get count():int {
			return super.styleNames.length;
		}
		public  function set count(inCount:int):void {
			// Protected
		}
	}
}