package org.wsimpson.ui

/**
* @name	BrightnessSelect.as
* @purpose 	Component for displaying a color using several color models
* @author 	William Simpson
* @version	0.1
* @date		April 2010
* Copyright (c) 2010 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.ui.cell.ColorCell;
	import org.wsimpson.ui.cell.GradientCell;
    import flash.display.DisplayObject;
    import flash.display.Sprite;

	
	public class BrightnessSelect extends Sprite
	{
        private var _debugger:DebugUtil;
        private var dataCells:Array;
        private var gradientCells:Array;
        private var offsetx:uint;
        private var offsety:uint;

		// Constructor
		public function BrightnessSelect()
		{
			super();
		}

		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/
	
		/**
		*  Name:  setDebugger
		*  Purpose:  Assigns the debugger class
		*/
        public function setDebugger():void {
			//this._debugger = DebugUtil.getInstance();		
		}


		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/
		
        public function shell():void {
			// code here
        }
		
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/
		
		// Sets default positioning
		private function updatePosition(inCell:DisplayObject)
		{
		    var tempIndexNum:uint;
			tempIndexNum = ((this.datacells.length > 0) ? this.datacells.length : 0) - 1 ;
			inCell.x = (tempIndexNum >= 0) ? (tempIndexNum * this.offsetx) : 0;
			inCell.y = (tempIndexNum >= 0) ? (tempIndexNum * this.offsety) : 0;
		}
		
		private function addCell()
		{
		    var dataCell:ColorCell;
			dataCell = new ColorCell(this._debugger);
			dataCell.size = 100;
			dataCell.drawCircle();
			updatePosition(updatePosition);
			dataCell.setDebugger(this._debugger);
			dataCell.datacellRGB = 0x00FFFF;
			addChild(dataCell);
			this.dataCells.push(dataCell);
		}
		
		private function addGradientCell()
		{
		    var dataCell:GradientCell;		
			dataCell = new GradientCell();
			dataCell.size = 100;
			dataCell.drawGradientRect();
			updatePosition(updatePosition);
			dataCell.setDebugger(this._debugger);
			dataCell.datacellRGB = 0x00FFFF;
			addChild(dataCell);
			this.gradientCells.push(dataCell);
		}
		
        private function init():void {
			this.addCell();
			this.addGradientCell();
			this._debugger = null;
			this.offsetx = 100;
			this.offsety = 100;
		}
    }
}