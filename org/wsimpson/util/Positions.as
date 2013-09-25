package org.wsimpson.util

/*
** Title:	Positions.as
** Purpose: Container class.  Add to class in the order objects should be displayed
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	public class Positions
	{	
		// Public Instance Constants
		public static var ROW:String = "row";
		public static var COLUMN:String = "column";	
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
        private var containerArr:Array;	
        private var columnInd:uint;	
        private var rowInd:uint;
		
		// Public Properties
		public var sizeX:uint;		// Based on "setOffsets" allowed size
		public var sizeY:uint;		// Based on "setOffsets" allowed size
		public var countRow:uint;	// Based on "setOffsets" allowed number in a row
		public var countCol:uint;	// Based on "setOffsets" allowed number in a col
		
		// Constructor
		public function Positions()
		{
			this._debugger = DebugUtil.getInstance();
			this.init();
		}
		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/
		/**
		*  Name:  	  findGridSize
		*  Purpose: Determines appropriate display size
		*  @param 	inDisplay	Object	Object display area
		*  @param 	inCount		uint	Desired count of elements
		*  @return Array	Matrix rows and columns
		*/
		public static function findGridSize(inDisplay:Object,inCount:uint):Array
		{
			var ratio:uint;				// Aspect ratio to match
			var tempIndex:uint;			// Index indicating the last entry
			var factors:Array;			// factors of the element count
			var pairs:Array;			// row and column count
			var ratioMatch:Array;		// Ratios of the count factors that most closely match the display area
			var matchingProduct:Array;	// Row and Column for grid large enough to contain the count
			var bestMatch:Array;		// Final selection
			
			ratio = inDisplay.width / inDisplay.height;
			
			factors = NumberUtil.factorNumber(inCount);
			
			// Create pairs from the possible combinations of factors
			pairs = NumberUtil.getPairs(factors);
			
			// Find pairs with ratios matching the display area
			ratioMatch = NumberUtil.findClosestRatio(pairs,ratio);
			
			// If possible find matching product
			matchingProduct = NumberUtil.findClosestProductCeil(ratioMatch, inCount);
			
			// If found set return value
			if (matchingProduct)
			{
				bestMatch = matchingProduct;
			}
			
			tempIndex = ratioMatch.length - 1;
			
			// if not found increase largest matching ratio until it is large enough
			for (var i:uint = 0; (!bestMatch); i++)
			{
				var product:uint;
				// Increase grid size while retainin aspect ratio.
				product = (ratioMatch[tempIndex][0] + i) * (ratioMatch[tempIndex][1] + i);
				if (product >= inCount)
				{
					ratioMatch[tempIndex][0] += i;
					ratioMatch[tempIndex][1] += i;
					bestMatch = ratioMatch[tempIndex];
				}
			}
			return bestMatch;
		}
		
		/**
		*  Name:  	getOffsets
		*  Purpose: Determines appropriate offsets and size display size
		*  @param 	inDisplay	Object	Object display area
		*  @param 	inArr		Array	Grid Size
		*  @return Array	Array of row and column offsets
		*  @note  Assumes elements of equal size are used
		*/
		public static function getOffsets(inDisplay:Object,inArr:Array):Array
		{
			var tempArr:Array;
			tempArr = new Array();
			tempArr[0] = inDisplay.width % inArr[0];
			tempArr[1] = inDisplay.height % inArr[1];
			return tempArr;
		}
		
		/**
		*  Name:  	getElementArea
		*  Purpose: Determines appropriate pixel size for elements in a grid of specified size.
		*  @param 	inDisplay	Object	Object display area
		*  @param 	inArr		Array	Grid Size
		*  @return Array	Array of row and column element sizes
		*  @note  Assumes elements of equal size are used
		*/
		public static function getElementArea(inDisplay:Object,inArr:Array):Array
		{
			var tempArr:Array;
			var tempOffsets:Array;
			tempArr = new Array();
			tempOffsets = getOffsets(inDisplay,inArr);
			tempArr[0] = (inDisplay.width - tempOffsets[0]) / inArr[0];
			tempArr[1] = (inDisplay.height - tempOffsets[1]) / inArr[1];
			return tempArr;
		}
		
		/**
		*  Name:  	  addElement
		*  Purpose: 	Add Elements to the display.  Adding as COLUMN adds to the existing row.  Adding to ROW adds a  new row and resets column to the left.
		*  @param 	inElement		Object	Object to be added to the display
		*  @param 	inElementPos	String	Object position (row or column)
		*  @param 	offsetX		uint		Object property display name
		*  @param 	offsetY		uint		Object property display name
		*/
		public function addElement(inElement:Object,inElementPos:String,offsetX:uint=0,offsetY:uint=0):void
		{
			//this._debugger.functionTrace("Position.addElement");		
			var elementObj:Object;
			elementObj = new Object();
			elementObj.element = inElement;
			elementObj.offsetX = offsetX;
			elementObj.offsetY = offsetY;
			if (inElementPos == Positions.ROW)
			{
				this.columnInd = 0;	
				this.rowInd++;
				this.containerArr[this.rowInd] = new Array();
			}
			this.containerArr[this.rowInd][this.columnInd] = elementObj;
			this.columnInd++;
		}
		
		/**
		*  Name:  	  positionElements
		*  Purpose: 	 Update the position of the passed elements based on their assigned positions
		*/
		public function positionElements():void
		{
			//this._debugger.functionTrace("Position.positionElements");
			var tempX:uint; // The current x poistion
			var tempY:uint;	//  The current y position
			tempY = 0;
			for (var positionRow:uint = 0; positionRow < this.containerArr.length; positionRow++)
			{
				tempX = 0;
				var tempHeight:uint;
				tempHeight = 0;
				for (var positionColumn:uint = 0; positionColumn < this.containerArr[positionRow].length; positionColumn++)
				{
					var elementObj:Object;
					elementObj = this.containerArr[positionRow][positionColumn];
					elementObj.element.x = tempX + elementObj.offsetX;
					tempX = elementObj.element.x + elementObj.element.width;
					elementObj.element.y = tempY + elementObj.offsetY;				
					tempHeight = ((elementObj.element.height + elementObj.offsetY) > tempHeight) ? (elementObj.element.height + elementObj.offsetY) : tempHeight;
				}
				tempY += tempHeight;
			}
		}
				
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/

		private function init():void {
			//this._debugger.functionTrace("Position.init");
	
			this.containerArr = new Array();	
			this.columnInd = 0;	
			this.rowInd = 0;
			this.containerArr[this.columnInd] = new Array();				
		}
    }
}