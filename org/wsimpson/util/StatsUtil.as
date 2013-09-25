﻿package org.wsimpson.util
/**
* @name		StatUtil.as
* Purpose	Defines calculations on XMLList values
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Utilities
	import org.wsimpson.util.ArrayUtil;
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;	
	
	// Stores
	import org.wsimpson.store.OrderStore;

	public class StatsUtil
	{
		// Constants
		public static const SS_MAX:Number = 
			Math.sqrt(Number.MAX_VALUE);					// Statistics supported
		public static const VALUE_MIN = "min";				// Statistics supported
		public static const VALUE_MAX = "max";				// Statistics supported
		public static const VALUE_MEAN = "mean";			// Statistics supported
		public static const VALUE_MEDIAN = "median";		// Statistics supported
		public static const VALUE_MODE = "mode";			// Statistics supported
		public static const VALUE_RANGE = "range";			// Statistics supported
		public static const VALUE_DEGREES_OF_FREEDOM = 
			"df";											// Statistics supported
		public static const VALUE_SUM_OF_SQUARES = 
			"SS";											// Statistics supported
		public static const VALUE_VARIANCE = "variance";	// Statistics supported
		public static const VALUE_STANDARD_DEVIATION = 
			"standard_deviation";							// Statistics supported
		public static const VALUE_SCALE = 
			"scale_applied_to_SS";							// This scale is used when the sum of squares will exceed the Math.MAX_VALUE
		public static const VALUE_TOTAL = "total";			// Statistics supported
		public static const VALUE_Q2_LESS = 
			"mean_minus_second_quartile";					// Statistics supported
		public static const VALUE_Q2_PLUS = 
			"mean_plus_second_quartile";					// Statistics supported
		public static const VALUE_Q1_LESS = 
			"mean_minus_first_quartile";					// Statistics supported
		public static const VALUE_Q1_PLUS = 
			"mean_plus_first_quartile";						// Statistics supported
			
		// Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window 
		private var dataArr:Array;					// Raw data
		
		// Static Variables
		private static var orderStore:OrderStore = new OrderStore();	// Factory for creating objects containing name value pairs	

		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a order store of basic statistics for the array
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function StatsUtil()
		{
			// Do nothing
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		* name:  	getSS
		* purpose:	Calculates the Sum of Squares from an array of numbers and their mean	
		*
		*	Will return -1 if the number is larger than the 
		*  @param inArr Array Values to create Sum of Squares for
		*  @param inMean Number Mean
		*  @param inDeg uint Indicates the number of decimal postitions to include
		*  @return Number Sum of Squares
		*/	
		private static function getSS(inArr:Array,inMean:Number,inDeg:uint=2):Number
		{
			var calcSS:Number;
			calcSS = 0;
			
			for (var i:Number = 0; i < inArr.length; i++)
			{
				calcSS += NumberUtil.roundDec(Math.pow((inArr[i] - inMean),2),inDeg);
			}	
			return NumberUtil.roundDec(calcSS,inDeg);
		}

		/**
		* name:  	getSDV
		* purpose:	Calculates the Standard Deviation from an array of numbers and their mean	
		*
		*  @param inArr Array Values to create Sum of Squares for
		*  @param inMean Number Mean
		*  @param inDeg uint Indicates the number of decimal postitions to include
		*  @return Number SDV
		*/	
		private static function getSDV(inArr:Array,inMean:Number,inDeg:uint=2):Number
		{		
			var tempNum:Number;
			var tempSS:Number;
			var tempVariance:Number;
			var tempScale:Number;
			var tempArr:Array;
			tempArr = ArrayUtil.copyArray(inArr);
			tempArr.push(StatsUtil.SS_MAX);
			tempNum = NumberUtil.getMax(tempArr);
			
			// Determine if the factor has to be scaled to remain within the supported numeric range of the Number class
			// Note: Scaling function TBD, see NumberUtil
			tempScale = (tempNum == StatsUtil.SS_MAX) ? 1 : 1;
			inDeg = (tempScale > 1) ? 0 : inDeg;		
			
			// These values are scaled
			tempSS = StatsUtil.getSS(inArr,inMean,inDeg);
			tempVariance = NumberUtil.roundDec((tempSS/Number(orderStore.getValue(VALUE_DEGREES_OF_FREEDOM))),inDeg);
			
			orderStore.addNameValue(VALUE_SCALE, tempScale);
			orderStore.addNameValue(VALUE_SUM_OF_SQUARES, tempSS);
			orderStore.addNameValue(VALUE_VARIANCE, tempVariance);
			
			// The Standard Deviation is returned to original scale
			orderStore.addNameValue(VALUE_STANDARD_DEVIATION,NumberUtil.roundDec(Math.sqrt(tempVariance),inDeg) * tempScale);
			
			return Number(orderStore.getValue(VALUE_STANDARD_DEVIATION));
		}
		
		/**
		* name:  	getStats
		* purpose:	Create an object containing name/value pairs of the basic statistics	
		*
		*  @param inArr Array Values to create stats for
		*  @param inDeg int Indicates the number of decimal postitions to include
		*  @return Object Name/Value pairs of the fundamental statistic
		*/		
		public static function getStats(inArr:Array,inDeg:uint=2):Object
		{
			var medianIndex:int;
			var tempMin:Number;
			var tempMax:Number;
			var tempMean:Number;
			var tempMedian:Number;
			var tempDF:Number;
			var tempSS:Number;
			var tempSDV:Number;
			var tempVariance:Number;
			var tempTotal:Number;
			var estimatedMax:Number;
			var modeObj:Object;
			
			// Init values
			tempDF = inArr.length - 1;
			tempMin = tempMax = inArr[0];
			tempMean = tempTotal = 0;
			modeObj = new Object();
			
			// find datatypes
			if (ArrayUtil.isNumber(inArr))
			{
				inArr.sort(Array.NUMERIC);
			} else
			{
				inArr.sort();
			}
			
			// find median
			medianIndex = Math.round(inArr.length / 2);
			tempMedian =	(NumberUtil.isOdd(inArr.length)) ?  
							inArr[medianIndex] : 
							NumberUtil.roundDec(((inArr[medianIndex -1] + inArr[medianIndex])/2),inDeg);
							
			for (var i:Number = 0; i < inArr.length; i++)
			{
				var tempVal:Number;
				tempVal = inArr[i];
				modeObj[tempVal] = (modeObj[tempVal]) ? modeObj[tempVal] + 1 : 1;
				// The following is required because the Array sort treats the values as Strings
				tempMax = (tempMax < tempVal) ? tempVal : tempMax;
				tempMin = (tempMin > tempVal) ? tempVal : tempMin;
				tempTotal += tempVal;
			}			
			
			tempMean = NumberUtil.roundDec((tempTotal / inArr.length),inDeg);
			
			orderStore.newObj();
			orderStore.addNameValue(VALUE_MIN,tempMin);
			orderStore.addNameValue(VALUE_MAX, tempMax);
			orderStore.addNameValue(VALUE_MEAN, tempMean);
			orderStore.addNameValue(VALUE_MEDIAN, tempMedian);
			orderStore.addNameValue(VALUE_MODE, Number(getMode(modeObj)));
			orderStore.addNameValue(VALUE_RANGE, NumberUtil.getRange(tempMax,tempMin));
			orderStore.addNameValue(VALUE_DEGREES_OF_FREEDOM, tempDF);	
			
			tempSDV = StatsUtil.getSDV(inArr,tempMean,inDeg);
			
			orderStore.addNameValue(VALUE_Q2_LESS, (tempMean - (tempSDV * 2)));
			orderStore.addNameValue(VALUE_Q2_PLUS, (tempMean + (tempSDV * 2)));
			orderStore.addNameValue(VALUE_Q1_LESS, (tempMean - tempSDV));
			orderStore.addNameValue(VALUE_Q1_PLUS, (tempMean + tempSDV));
			orderStore.addNameValue(VALUE_TOTAL, NumberUtil.roundDec(tempTotal,inDeg));
			return orderStore.getObj();
		}

		/**
		* name:  	toXMLString
		* purpose:	returns an XML string of a stats object
		*
		*  @param inObj OBject Name/Value pairs
		*  @return String Name/Value pairs as XML
		*/		
		public static function toXMLString(inObj:Object):String
		{
			return orderStore.toXMLString(inObj);
		}
		
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
		
		/**
		* name:  	getMode
		* purpose:	Return the largest value found in an associative array
		* @param inObj Object The associative array
		* @return String Index of the higest value found
		// */
		public static function getMode(inObj:Object):String
		{
			var tempMax:Number;
			var indexStr:String;
			tempMax = 0;
			for (var tempStr:String in inObj)
			{
				if (tempMax < inObj[tempStr])
				{
					tempMax = inObj[tempStr];
					indexStr = tempStr;
				}
			}
			return indexStr;
		}
		
		private static function sendError(errorMsg:String):Boolean
		{
			throw new Error(errorMsg);	
		}	
		

	}
}