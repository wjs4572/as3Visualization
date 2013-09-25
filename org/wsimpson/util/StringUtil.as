package org.wsimpson.util

/*
** Title:	StringUtil.as
** Purpose:	Misc sting functions  Utility class
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// UI Components
	import org.wsimpson.util.DebugUtil;
		
	public class StringUtil
	{
		public static const DOUBLE_QUOTE = "\"";							// Double quote within a String object
		public static const ENTITY_TAB = "{TAB}";							// Field to replace		
		public static const TAB = "\t";										// Value to replace	with	
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function StringUtil()
		{
			this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Statis Functions
		******************************************************************************************************/
		/**
		*  Name:  	repeatString
		*  Purpose:	Return concatenated String of N repeats
		*  @param 	inStr	In string to repeat
		*  @param	inNum   int of copies of string
		*  @return 	String	Concatenated String
		*/
		public static function repeatString(inStr:String,inNum:int):String
		{
			var tempStr:String;
			tempStr = inStr;
			for (var i:int=0;i < inNum; i++)
			{
				tempStr += inStr;
			}
			return tempStr;
		}
		
		/**
		*  Name:  	replaceTabs
		*  Purpose:	Return the passed string with tab entities replaced with \t substitution
		*  @param 	inStr	In string to quote
		*  @return 	String	Quoted String
		*/
		public static function replaceTabs(inStr:String):String
		{
			var tabStr:String;
			var tabPattern:RegExp;
			
			// Define Patterns
			tabPattern = new RegExp(ENTITY_TAB,"g");
			tabStr = inStr.replace(tabPattern,TAB);
			return tabStr;
		}

		/**
		*  Name:  	doubeQuoteStr
		*  Purpose:	Return the passed string as double quoted.
		*  @param 	inStr	In string to quote
		*  @return 	String	Quoted String
		*/
		public static function doubeQuoteStr(inStr:String):String
		{
			return (DOUBLE_QUOTE + inStr + DOUBLE_QUOTE);
		}
		
		/**
		*  Name:  	createXMLParent
		*  Purpose:	Return the passed string as double quoted.
		*  @param 	inParent	In parent element.
		*  @param 	inStr		In string to add
		*  @return 	String	New element
		*/
		public static function createXMLParent(inParent:String,inStr:String):String
		{
			return ("<" + inParent + ">\n" + StringUtil.indentXML(inStr) + "</" + inParent + ">" );
		}
		
		/**
		*  Name:  	isInteger
		*  Purpose:	Confirm that the value is numeric (0..9)
		*  @param 	inStr	In string to confirm
		*  @return 	Boolean Is numeric = true
		*/
		public static function isInteger(inStr:String):Boolean
		{
			var tempBool:Boolean;
			var tempStr:String;
			tempStr = trim(inStr);
			tempBool = true;
			for (var i:Number=0; i < tempStr.length; i++)
			{
				var tempBool2:Boolean;
				tempBool2 = NumberUtil.rangeCheck(tempStr.charCodeAt(i),48,57,false);
				tempBool = (tempBool && tempBool2);
				if ((!tempBool2) && !((i == 0) && (tempStr.charCodeAt(i) == 45)))
				{
					(DebugUtil.getInstance()).warningTrace("isInteger-> " + tempStr + ":\n\tInvalid Integer : character = '" + String.fromCharCode(tempStr.charCodeAt(i)) + "' charChode = " + tempStr.charCodeAt(i));
				}
			}
			return (tempBool && !(isNaN(parseInt(tempStr))));
		}
		
		/**
		*  Name:  	isNumber
		*  Purpose:	Confirm that the string received matches 
		*  @param 	inStr	In string to confirm
		*  @return 	Boolean Is numeric = true
		*/
		public static function isNumber(inStr:String):Boolean
		{
			var tempArr:Array;
			var tempArr2:Array;
			var commaPattern:RegExp;		// Regular Expression pattern 
			var digitPattern:RegExp;		// Regular Expression pattern
			//numericPattern = /(^\s\d{0,3}(,\d{3})*(\.)\d*\s/;			
			commaPattern = /^\s*[-+]?\d{1,3}(,\d{3})*(\.\d+)?\s*$/;			
			digitPattern = /^\s*[-+]?\d+(\.\d+)?\s*$/;			
			tempArr = inStr.match(commaPattern);
			tempArr2 = inStr.match(digitPattern);
			return ((tempArr != null) || (tempArr2 != null));
		}

		/**
		*  Name:  	isUSCurrency
		*  Purpose:	Confirm that the string received matches 
		*  @param 	inStr	In string to confirm
		*  @return 	Boolean Is numeric = true
		*/
		public static function isUSCurrency(inStr:String):Boolean
		{
			var tempArr:Array;
			var tempArr2:Array;
			var dollarPattern:RegExp;		// Regular Expression pattern
			var tempStr:String;
			tempStr = inStr.replace("$","");
			//numericPattern = /(^\s\d{0,3}(,\d{3})*(\.)\d*\s/;			
			dollarPattern = /^\s*\$?.*$/;					
			tempArr = inStr.match(dollarPattern);
			return (isNumber(tempStr) && (tempArr != null));
		}
		
		/**
		*  Name:  	isCurrency
		*  Purpose:	Confirm that the string received matches 
		*  @param 	inStr	In string to confirm
		*  @return 	Boolean Is numeric = true
		*/
		public static function isCurrency(inStr:String):Boolean
		{
			return isUSCurrency(inStr);
		}
		
		/**
		*  Name:  	stripReturns
		*  Purpose:	Removes the carriage returns to clean up formatting
		*  @param 	inStr	String	to clean
		*  @return 	String
		*/
		public static function stripReturns(inStr:String):String
		{
		
			var tempPattern:RegExp;
			var tempStr:String;
			tempPattern = new RegExp("\n","g");
			tempStr = inStr;
			tempStr = tempStr.replace(tempPattern,"");
			return tempStr;
		}
		
		/**
		*  Name:  	indentXML
		*  Purpose:	Replaces the carriage returns with carriage returns and tab
		*  @param 	inStr	String	to clean
		*  @return 	String
		*/
		public static function indentXML(inStr:String):String
		{
			return inStr.replace(/^(\s*)</mg,"\t$1<");
		}
		
		/**
		*  Name:  	stripPrettyPrinting
		*  Purpose:	Removes the carriage returns and leading tab used to pretty print tagged content
		*  @param 	inStr	String	to clean
		*  @return 	Boolean	Attribute exists
		*/
		public static function stripPrettyPrinting(inStr:String):String
		{
			return inStr.replace(/>\s+</sg,"><").replace(/\n\s*/sg,"");
		}
		
		/**
		*  Name:  	ltrim
		*  Purpose:	Left Trim
		*  @param 	inStr	String	to clean
		*  @return 	String Without leading white space
		*/		
		public static function ltrim( inStr:String ):String
		{
		  return inStr.replace( /^([\s]+)?(.*)/s, "$2" );
		}
		
		/**
		*  Name:  	rtrim
		*  Purpose:	Right Trim
		*  @param 	inStr	String	to clean
		*  @return 	String Without trailing white space
		*/		
		public static function rtrim( inStr:String ):String
		{
		  return inStr.replace( /(.*)([\s]+)?$/s, "$1" );
		}
		
		/**
		*  Name:  	trim
		*  Purpose:	Trim
		*  @param 	inStr	String	to clean
		*  @return 	String Without leading or trailing white space
		*/		
		public static function trim( inStr:String ):String
		{
		  return inStr.replace( /^([\s]+)?(.*)([\s]+)?$/s, "$2" );
		}

    }
}