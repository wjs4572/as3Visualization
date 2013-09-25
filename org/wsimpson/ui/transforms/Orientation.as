package org.wsimpson.ui.transforms

/*
** Title:	Orientation.as
** Purpose: Collection of routines for tranforming the orientation of a DisplayObject
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Classes
	import flash.display.DisplayObject;
	
	public class Orientation
	{

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  Name:  	  flipHorizontal
		*  Purpose:  Reorients the DisplayObject rotationally 180 degrees both horizontally and vertically
		* @param inDO DisplayObject DisplayObject to flip
		*/		
		public static function flipHorizontal(inDO:DisplayObject):void {
			// flip vertical
			inDO.scaleY *= -1;
			inDO.x += inDO.width

			// flip horizontal
			inDO.scaleX *= -1;
			inDO.y += inDO.height;
		}
		

	}
}