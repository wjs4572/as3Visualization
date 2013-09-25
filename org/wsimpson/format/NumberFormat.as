package org.wsimpson.format

/*
** Title:	NumberFormat.as
** Purpose: Provides numeric formats.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
		
	// Utilities
	import org.wsimpson.util.DebugUtil;	
	
	public class NumberFormat
	{	
		// Private Instance Variables
        private var _debugger:DebugUtil;
		private var _mask:String;
		
		// Constructor
		public function NumberFormat(inMask:String)
		{
			//this._debugger = DebugUtil.getInstance();
			_mask = inMask;
		}

		/*********************************************************************************************************
		**  Parameters																							**
		**********************************************************************************************************/
				
		/**
		*  Get and set the mask for the formatting. The mask can consist of 0's, #'s,
		*  commas, and dots.
		*/
		public function get mask():String {
			return _mask;
		}

		public function set mask(inMask:String):void {
			_mask = inMask;
		}

		/*********************************************************************************************************
		**  Private																								**
		**********************************************************************************************************/

		
		/*********************************************************************************************************
		**  PUBLIC																								**
		**********************************************************************************************************/
		/**
		*  Name:  	formatUINT
		*  Purpose:	Create a number stringmatching the mask
		*  @param 	n	uint	The number to format	
		*  @param 	inRadix	uint	The numeric base
		*/
		public function formatUINT(n:uint,inRadix:uint=10):String
		{
			var tempStr:String;
			var numArr:Array;
			var maskArr:Array;
			var tempStrArr:Array;
			var tempNum:uint;
			var numIndex:uint;
			numIndex = 0;
			
			tempStrArr = new Array();
			tempNum = Math.floor(n);
			tempStr = tempNum.toString(inRadix);			
			numArr = tempStr.split("");
			maskArr = this.mask.split("");
			numArr.reverse();
			maskArr.reverse();
			for (var i:Number = 0; i < maskArr.length; i++)
			{
				var tempChar:String;
				switch(maskArr[i])
				{
					case "0":
						tempChar = (numIndex < numArr.length) ? numArr[numIndex] : "0";
						numIndex++;
					break;
					case "#":
						tempChar = (numIndex < numArr.length) ? numArr[numIndex] : " ";
						numIndex++;					
					break;
					default:
						tempChar = maskArr[i];
					break;
				}
				tempStrArr.push(tempChar);
			}

			return tempStrArr.reverse().join("");
		}
    }
}