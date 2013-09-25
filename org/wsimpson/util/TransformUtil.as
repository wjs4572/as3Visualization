package org.wsimpson.util
/**
* @name		TransformUtil.as
* Purpose	Utility functions related to the DisplayObjectContainerClass.
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{	
	// Adobe
	import flash.geom.Matrix;		
	import fl.motion.MatrixTransformer;
	import flash.display.DisplayObject;


	// Debugging
	import org.wsimpson.util.DebugUtil;

	public class TransformUtil
	{

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		public static function rotateDisplayObject(inDO:DisplayObject,inDeg:int,inX=0,inY=0):void
		{
			var tempMatrix:Matrix;	// Matrix of variables describing how to render the DisplayObject
			tempMatrix = inDO.transform.matrix.clone();
			MatrixTransformer.rotateAroundInternalPoint(tempMatrix,inX,
                                     inY,inDeg);
			inDO.transform.matrix = tempMatrix;
		}

	}
}