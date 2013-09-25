package org.wsimpson.util
/**
* @name		DispalyObjectContainerUtil.as
* Purpose	Utility functions related to the DisplayObjectContainerClass.
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{	
	// Adobe
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getQualifiedClassName;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;

	public class DispalyObjectContainerUtil
	{

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
 		/**
		*  Name:	traceDisplayList
		*  Purpose: Prints a list of the Qualified Class Names for each object on the display list
		*/
        public static function traceDisplayList(inDCO:DisplayObjectContainer):void {
			var tempDO:DisplayObject;
			for (var i:int = 0; i < inDCO.numChildren; i++)
			{
				tempDO = inDCO.getChildAt(i);
				(DebugUtil.getInstance()).wTrace("DispalyObjectContainerUtil.traceDisplayList -> : child " + i + "  = " + flash.utils.getQualifiedClassName(tempDO));
			}
		}

 		/**
		*  Name:	getMatchingChildren
		*  Purpose: Finds the child matching the provided pattern.
		*/		
		public static function getMatchingChildren(inDCO:DisplayObjectContainer,inPattern:RegExp):Array
		{
			var tempArr:Array;		// Aray of child objects
			var tempPattern:RegExp;	// Regular Expression for passed value

			tempArr = new Array();		
			tempPattern = inPattern;

			for (var i:uint = 0; i < inDCO.numChildren; i++)
			{
				var tempDO:Object;
				tempDO = inDCO.getChildAt(i);
				if (tempPattern.test(tempDO.name))
				{
					tempArr.push(tempDO);
				}
			}
			return tempArr;
		}
		
		public static function removeAllChildren(inDCO:DisplayObjectContainer):void
		{
			var i:int;
			i = inDCO.numChildren;
			// The "--" precedes the index to ensure that it is calculated first
			while(--i >= 0)
			{
				inDCO.removeChildAt(i);
			}
		}

	}
}