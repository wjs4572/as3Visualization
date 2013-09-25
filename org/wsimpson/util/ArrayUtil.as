package org.wsimpson.util

/*
** Title:	ArrayUtil.as
** Purpose:	Misc Array functions
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// UI Components
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;
	import org.wsimpson.util.StringUtil;
		
	public class ArrayUtil
	{
		public static const UNKNOWN_TYPE = "Unknown";			// Statistics supported
		public static const MIXED_TYPES = "mixed";				// Statistics supported
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function ArrayUtil()
		{
			this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Statis Functions
		******************************************************************************************************/

		/**
		*  Name:  	mapNumbers
		*  Purpose:	Parses all input values to numbers
		*  @param 	inArr	Array Creates a new array that will have Numbers or NaN values
		*  @return  Number
		*/		
        public static function mapNumbers(inArr:Array):Array
		{
            var tempArr:Array;
			tempArr = ArrayUtil.copyArray(inArr);
			tempArr.map(NumberUtil.mapNumbers);
			return tempArr;
        }

		/**
		*  Name:  	copyArray
		*  Purpose:	Return the passed string as double quoted.
		*  @param 	inArr	In array of Strings
		*  @return 	Array	New Array with quoted String
		*/
		public static function copyArray(inArr:Array):Array
		{
			var tempArr:Array;
			tempArr = new Array();
			for (var i:uint=0; i < inArr.length; i++)
			{
				tempArr.push(inArr[i]);
			}
			return tempArr;
		}

		/**
		*  Name:  	mergeArray
		*  Purpose:	Creates new array that is a combination of the incoming array without duplicates
		*  @param 	inArr1	Array 	In array
		*  @param   inArr2	Array	In array
		*  @return 	Array	New Array with quoted String
		*/
		public static function mergeArray(inArr1:Array,inArr2:Array):Array
		{
			var tempArr:Array;
			tempArr = copyArray(inArr1);
			if (inArr2 != null)
			{
				for (var i:uint=0; i < inArr2.length; i++)
				{
					if (inArr1.indexOf(inArr2[i]) < 0)
					{
						tempArr.push(inArr2[i]);
					}
				}
			}
			return tempArr;
		}
		
		/**
		*  Name:  	doubeQuoteStr
		*  Purpose:	Return the passed string as double quoted.
		*  @param 	inArr	In array of Strings
		*  @return 	Array	New Array with quoted String
		*/
		public static function doubeQuoteStr(inArr:Array):Array
		{
			var tempArr:Array;
			tempArr = new Array();
			if (isStrings(inArr))
			{
				for (var i:uint=0; i < inArr.length; i++)
				{
					tempArr.push(StringUtil.doubeQuoteStr(inArr[i]));
				}
			}
			return tempArr;
		}
		
		/**
		*  Name:  	isStrings
		*  Purpose:	Determine if Array entries are all Strings
		*  @param 	inArr	In array of Strings
		*  @return 	Boolean	Indicating if all of the entries are Strings.
		*/
		public static function isStrings(inArr:Array):Boolean
		{
			var tempArr:Array;
			var isStringBool:Boolean;
			isStringBool = true;
			tempArr = new Array();
			for (var i:uint=0; i < inArr.length; i++)
			{
				isStringBool = ((typeof inArr[i] == "string") && isStringBool);
			}
			return isStringBool;
		}

		/**
		*  Name:  	isNumber
		*  Purpose:	Determine if Array entries are all Numbers (int, uint or number)
		*  @param 	inArr	In array of Number
		*  @return 	Boolean	Indicating if all of the entries are Numbers.
		*/
		public static function isNumber(inArr:Array):Boolean
		{
			var tempArr:Array;
			var isNumberBool:Boolean;
			isNumberBool = true;
			tempArr = new Array();
			for (var i:uint=0; i < inArr.length; i++)
			{
				isNumberBool = ((typeof inArr[i] == "number") && isNumberBool);
			}
			return isNumberBool;
		}
		
		/**
		*  Name:  	getDataType
		*  Purpose:	Determine the type of the Array Entries
		*  @param 	inArr	In array of Strings
		*  @return 	String The data type stored in the Array entries;
		*/
		public static function getDataType(inArr:Array):String
		{
			var dataType:String;
			dataType = (typeof inArr[0]);
			for (var i:uint=0; i < inArr.length; i++)
			{
				dataType = (typeof inArr[i] == dataType) ? dataType : MIXED_TYPES;
			}
			return dataType;
		}

    }
}