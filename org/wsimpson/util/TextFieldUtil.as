package org.wsimpson.util

/*
** Title:	TextFieldUtil.as
** Purpose:	Misc TextField functions Utility class
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Graphics
	import flash.geom.Rectangle;

	// Adobe UI
	import flash.text.StyleSheet;	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;

	// UI Components
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;
		
	public class TextFieldUtil
	{
		// Private Constant Instance Values
		private static const PIXEL_BUFFER:uint = 1;
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function TextFieldUtil()
		{
			this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Static Functions
		******************************************************************************************************/
		/**
		*  Name:  	newTextField
		*  Purpose:	Return a new TextField based on the content received
		*  @param 	inContent	String 		The text to display
		*  @param 	inStyle		StyleSheet 	Specifies the format of the  text
		*  @return 	TextField Newly created TextField
		*/	
		public static function newTextField(inContent:String, inStyle:StyleSheet):TextField
		{
			var tempTF:TextField;
			tempTF = new TextField();
			tempTF.styleSheet = inStyle;
			// tempTF.antiAliasType = AntiAliasType.ADVANCED; 
			// tempTF.gridFitType = GridFitType.PIXEL;
			// tempTF.sharpness = 200;			
			tempTF.selectable = false;
			tempTF.autoSize = TextFieldAutoSize.LEFT;
			tempTF.wordWrap = true;
			tempTF.multiline = true;		
			tempTF.htmlText = StringUtil.stripPrettyPrinting(inContent);
			return tempTF;
		}
		
		/**
		*  Name:  	getEnDashWidth
		*  Purpose:	Return the actual height of the passed TextField
		*  @param 	inName	String		Specifies the format of the  text
		*  @param 	inTF	TextFormat	Specifies the format of the  text
		*  @return 	uint	Calculated height
		*/		
		public static function getEnDashWidth(inTF:TextFormat):uint
		{
			return TextFieldUtil.getCharWidth("&#x2013;",inTF);
		}

		/**
		*  Name:  	getEmDashWidth
		*  Purpose:	Return the actual height of the passed TextField
		*  @param 	inName	Strnig Specifies the format of the  text
		*  @param 	inTF	TextFormat Specifies the format of the  text
		*  @return 	uint	Calculated height
		*/		
		public static function getEmDashWidth(inTF:TextFormat):uint
		{
			return TextFieldUtil.getCharWidth("&#x2014;",inTF);
		}
		
		/**
		*  Name:  	getCharWidth
		*  Purpose:	Return the actual height of the passed TextField
		*  @param 	inName	Strnig Specifies the format of the  text
		*  @param 	inTF	TextFormat Specifies the format of the  text
		*  @return 	uint	Calculated height
		*/		
		public static function getCharWidth(inChar,inTF:TextFormat):uint
		{
			var tempTF:TextField;
			tempTF = new TextField();
			tempTF.setTextFormat(inTF);
			tempTF.htmlText = inChar;
			return tempTF.textWidth;
		} 
		
		/**
		*  Name:  	calcActualHeight
		*  Purpose:	Return the actual height of the passed TextField
		*  @param 	targetTF	TextField The TextField to determine the actual height of.
		*  @return 	uint	Calculated height
		* 
		*  @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html
		*/
		public static function calcActualHeight(targetTF:TextField):uint
		{
			return (targetTF.textHeight + 4);
		}

		/**
		*  Name:  	calcActualWidth
		*  Purpose:	Return the actual width of the passed TextField
		*  @param 	targetTF	TextField The TextField to determine the actual width of.  This will be based on the widest text field.
		*  @return 	uint	Calculated width
		* 
		*  @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html
		*/
		public static function calcActualWidth(targetTF:TextField):uint
		{
			var tempFormat:TextFormat;
			var lineWidth:uint;
			var num_pixels:uint;
			var margin:uint;
			
			lineWidth = 0;
			tempFormat = targetTF.getTextFormat();
			margin = tempFormat.leftMargin + tempFormat.rightMargin;
			
			for (var i:uint = 0; i< targetTF.numLines; i++) {
				var tempWidth:uint;
				tempWidth = targetTF.getLineMetrics(i).width;
				lineWidth = (lineWidth < tempWidth) ? tempWidth : lineWidth;
			}
			
			// TextFields contain a 4 pixel gutter left to right, 2px per side
			return (lineWidth + margin + 4);
		}
		
		/**
		*  Name:  	diffActualWidth
		*  Purpose:	Return the difference of the reported width from the actual width.
		*  @param 	targetTF	TextField The TextField to determine the actual width of.  This will be based on the widest text field.
		*  @return 	int	Calculated difference
		* 
		*  @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html
		*/
		public static function diffActualWidth(targetTF:TextField):int
		{
			var rect:Rectangle;
			rect = targetTF.getBounds(targetTF);
			
			return (rect.width - TextFieldUtil.calcActualWidth(targetTF));
		}
		
		/**
		*  Name:  	resizeToActualWidth
		*  Purpose:	Resize the passed TextField to the actual width
		*  @param 	targetTF	TextField The TextField to determine the actual width of.  This will be based on the widest text field.
		* 
		*  @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html
		*/
		public static function resizeToActualWidth(targetTF:TextField):void
		{
			var tempWidth:int;
			tempWidth = TextFieldUtil.diffActualWidth(targetTF);
			if (tempWidth > 0)
			{
				targetTF.width -= tempWidth;
			}
		}

    }
}