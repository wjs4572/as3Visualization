package org.wsimpson.util

/*
** Title:	PointUtil.as
** Purpose: Used for coordinate calculations
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.DisplayObject;	
    import flash.display.DisplayObjectContainer;	
	import flash.geom.Point;
	
	// UI Components
	import org.wsimpson.util.DebugUtil;
		
	public class PointUtil
	{
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function PointUtil()
		{
			//////this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Statis Functions
		******************************************************************************************************/
		
		/**
		*  Name:  	fullScale
		*  Purpose:	Determines all scaling applied to an DisplayObject from self through its DisplayObjectContainers to the Stage.
		*  @param 	inDO	DisplayObject	The DisplayObject scaling is being determined for
		*  @return 	scaling	Object	The x and y scales {scaleX,scaleY);
		*  @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObject.html#parent
		*  @see http://www.actionscript.org/forums/showthread.php3?t=154569
		*/
		public static function fullScale(inDO:DisplayObject):Object
		{
			var tempObject:Object;
			var tempParent:DisplayObjectContainer;
			tempObject = new Object();
			tempObject.scaleX = 1 * inDO.scaleX;
			tempObject.scaleY = 1 * inDO.scaleY;
			do 
			{
				tempParent = (tempParent) ? tempParent.parent : inDO.parent;
				if (tempParent)
				{
					tempObject.scaleX *= tempParent.scaleX;
					tempObject.scaleY *= tempParent.scaleY;
				}
			} while ((tempParent) && (tempParent != inDO.root))
			return tempObject;
		}
		
		/**
		*  Name:  	globalToLocal
		*  Purpose:	Returns Point containing the local equivalent of the global x and y values
		*  @param 	from	DisplayObject	The DisplayObject with the original coordinates
		*  @return 	Point The point being returned.
		*/
		public static function globalToLocal(from:DisplayObject):Point
		{
			var inPoint:Point;
			
			// Assign Point
			inPoint = new Point(from.x,from.y);

			return from.globalToLocal(inPoint);
		}

		/**
		*  Name:  	localToGlobal
		*  Purpose:	Returns Point containing the global equivalent of the current x and y values
		*  @param 	from	DisplayObject	The DisplayObject with the original coordinates
		*  @return 	Point The point being returned.
		*  @tip	The localToGlobal refers to the containing object.
		*/
		public static function localToGlobal(from:DisplayObject):Point
		{
			var inPoint:Point;
			var fromPoint:Point;
			
			// Assign Point
			inPoint = new Point(from.x,from.y);
			
			// Get Global
			return from.localToGlobal(inPoint);
		}
		
		/**
		*  Name:  	localToLocal
		*  Purpose:	Modifed version of John Grden's coordinate conversion function.
		*  @param 	from	DisplayObject	The DisplayObject with the original coordinates
		*  @param 	to		DisplayObject	The DisplayObject the coordinates will be applied to.
		*  @return 	origin	Object	The point being converted.
		*  @see http://rockonflash.wordpress.com/2006/11/12/globaltolocal-localtoglobal-please-meet-localtolocal-and-be-done-with-it/
		*/
		public static function localToLocal(from:DisplayObject, to:DisplayObject, origin:Object=null):Point
		{
			var inPoint:Point;
			var fromPoint:Point;
			var toPoint:Point;
			var tempScale:Object;

			// Assign Point
			inPoint = (origin == null) ? new Point(0,0) : (origin as Point);

			// Get Global
			fromPoint = from.localToGlobal(inPoint);
			tempScale = PointUtil.fullScale(from);
			fromPoint.x /= tempScale.scaleX;
			fromPoint.y /= tempScale.scaleY;

			// Get Local
			toPoint = to.globalToLocal(fromPoint);
			tempScale = PointUtil.fullScale(to);
			toPoint.x *= tempScale.scaleX;
			toPoint.y *= tempScale.scaleY;
			return toPoint;
		}		

    }
}