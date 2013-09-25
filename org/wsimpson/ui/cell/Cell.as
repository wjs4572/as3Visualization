package org.wsimpson.ui.cell

/*
** Title:	Cell.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;


	
	public class Cell extends Sprite
	{
		// Public Instance Variables
		public var borderSize:uint;
		public var cornerRadius:uint;
		
		// Private Instance Variables
		private var backgroundCellColor:uint;
		private var _debugger:DebugUtil;
		private var borderColor:uint;
		private var cellSize:uint;
		protected var cellWidth:uint;
		protected var cellHeight:uint;
		protected var cellLineStyle:uint;
		protected var cellLineAlpha:Number;
		
		// Constructor
		public function Cell()
		{
			super();
			this._debugger = DebugUtil.getInstance();
			this.cellLineAlpha = .01;
			this.init();
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/

		/**
		*  Name:  	size
		*  Purpose:  Update the shape size and shold be called before a draw function
		*/
		public function get size():uint {
			return this.cellWidth;
		}
		
		public function set size(inSize:uint):void {
			//this._debugger.functionTrace("Cell.set size");
			this.cellWidth = inSize; 
			this.cellHeight = inSize;
		}
		
		public function get cell_height():int {
			return this.cellHeight;
		}
		
		public function set cell_height(inHeight:int):void {
			this.cellHeight = ((inHeight) > (inHeight > 0)) ? inHeight : this.cellHeight;
			this.cellHeight = (!this.cellHeight) ? 100 : this.cellHeight;	
		}
			
		public function get cell_width():int {
			return this.cellWidth;
		}
		
		public function set cell_width(inWidth:int):void {
			this.cellWidth = ((inWidth) && (inWidth > 0 )) ? inWidth : this.cellWidth; 
			this.cellWidth = (!this.cellWidth) ? 100 : this.cellWidth;		
		}
		/**
		*  Name:  	color
		*/
		public function get backgroundColor():uint {
			return this.backgroundCellColor;
		}
		
		public function set backgroundColor(inColor:uint):void {
			this.backgroundCellColor = inColor; 
		}
		/**
		*  Name:  	lineThickness
		*/
		public function get lineThickness():uint {
			return this.cellLineStyle;
		}
		
		public function set lineThickness(inStyle:uint):void {
			this.cellLineStyle = inStyle; 
		}
		/**
		*  Name:  	lineAlpha
		*/
		public function get lineFade():Number {
			return this.cellLineAlpha;
		}
		
		public function set lineFade(inStyle:Number):void {
			this.cellLineAlpha = inStyle; 
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  Name:  	 childCount
		*  Purpose:  The number of children
		*/		
		public function get childCount():int {
			return this.numChildren;
		}
		public function set childCount(inInt:int):void
		{
			// do nothing
		}
		
		/**
		*  Name:  	  initStage
		*  Purpose:  Initializes the stage size
		*/		
		public function initStage():void {
			this.drawSquare(100);
		}

		
		/**
		*  Name:  	clear
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Clears the screen of the default graphic before drawing.
		*/	
		public function clear():void
		{
			this.graphics.clear();
		}

		/**
		*  Name:  	drawLine
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*
		*	@param inX int The x coordinate of the desired end position
		*	@param inY int The y coordinate of the desired end position
		*	@param inMoveX int The x coordinate of the desired start position
		*	@param inMoveY int The y coordinate of the desired start position
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Not providing these values will allow the object to default to the current size.
		*   @see http://snipplr.com/view/2814/as3-drawing-api-line-drawing-and-dropshadow/
		*/	
		public function drawLine(inX:int=int.MIN_VALUE,inY:int=int.MIN_VALUE,inMoveX:int=int.MIN_VALUE,inMoveY:int=int.MIN_VALUE):void {
			this.graphics.lineStyle(this.cellLineStyle,this.backgroundCellColor,this.cellLineAlpha);
			if (inMoveX > int.MIN_VALUE)
			{
				this.graphics.moveTo(inMoveX, inMoveY);
			}
			if (inX > int.MIN_VALUE)
			{
				this.graphics.lineTo(inX, inY);
			}
		}
		
		/**
		*  Name:  	drawCircle
		*  Purpose:  Based off Adobe LiveDocs Graphics descriptiondescription
		*
		*	@param inRadius int The desired radius of the drawn circle.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Not providing these values will allow the object to default to the current size.
		*/	
		public function drawCircle(inRadius:int=-1):void {	
			var diameter:uint
			diameter = Math.round(inRadius * 2);		
			this.drawEllipse(diameter, diameter);
		}
		
		/**
		*  Name:  	drawEllipse
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*
		*	@param inWidth int The desired width of the drawn ellipse.
		*	@param inHeight int The desired height of the draws ellipse.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Not providing these values will allow the object to default to the current size.
		*/	
		public function drawEllipse(inWidth:int=-1,inHeight:int=-1):void {	
			this.cell_height = inHeight;
			this.cell_width = inWidth;
			this.graphics.clear();
			this.graphics.beginFill(this.backgroundCellColor);
			this.graphics.drawEllipse(0, 0, this.cellWidth, this.cellHeight);
			this.graphics.endFill();
			this.refreshLayout();
		}
		
		/**
		*  Name:  	drawRoundRect
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*
		*	@param inWidth int The desired width of the drawn rectangle.
		*	@param inHeight int The desired height of the draws rectable.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Not providing these values will allow the object to default to the current size.
		*/	
		public function drawRoundRect(inWidth:int=-1,inHeight:int=-1):void {	
			this.cell_height = inHeight;
			this.cell_width = inWidth;
			this.graphics.clear();
			this.graphics.beginFill(this.backgroundCellColor);
			this.graphics.drawRoundRect(0, 0, this.cellWidth, this.cellHeight, this.cornerRadius);
			this.graphics.endFill();
			this.refreshLayout();
		}
		
		/**
		*  Name:  	drawRect
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*
		*	@param inWidth int The desired width of the drawn rectangle.
		*	@param inHeight int The desired height of the draws rectable.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Not providing these values will allow the object to default to the current size.
		*/	
		public function drawRect(inWidth:int=-1,inHeight:int=-1):void {	
			this.cell_height = inHeight;
			this.cell_width = inWidth;
			this.graphics.clear();
			this.graphics.beginFill(this.backgroundCellColor);
			this.graphics.drawRect(0, 0, this.cellWidth, this.cellHeight);
			this.graphics.endFill();
			this.refreshLayout();
		}

		/**
		*  Name:  	refreshLayout
		*  Purpose:  Update the display
		*/
		public function refreshLayout():void 
		{
			this.visible = true;
		}

		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/

		/**
		*  Name:  	initCell
		*  Purpose:  Based off Adobe LiveDocs Graphics description
		*/	
		public function drawSquare(squareSize:uint):void {
			//this._debugger.functionTrace("Cell.drawSquare");
			
			this.graphics.beginFill(this.backgroundCellColor,0);
			this.graphics.drawRect(0, 0, squareSize, squareSize);
			this.graphics.endFill();

			this.refreshLayout();
		}
		
		private function init():void {
			this.backgroundCellColor	= 0xFF0000;
			this.borderColor			= 0x000000;
			this.borderSize				= 0;
			this.cornerRadius			= 9;
			this.cellLineStyle			= 0;
			this.initStage();
			this.refreshLayout();
		}

	}
}