package org.wsimpson.ui

/*
** Title:	EditCellAttributes.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.Positions;
	import org.wsimpson.ui.AttributeSliderBox;
	import org.wsimpson.ui.cell.ColorCell;
	import org.wsimpson.ui.cell.GradientCell;
    import flash.display.DisplayObject;
    import flash.display.Sprite;

	
	public class EditCellAttributes extends Sprite
	{
		// Public Instance Constants
		public const TEXT:String = "text";			// Payload type
		public const GRAPHIC:String = "graphic";	// Payload type
		public const NUMERIC:String = "numeric";	// Payload type
		public const CELL:String = "cell";			// Payload type
		public const DEFAULT_SIZE = 60;				// Cell Size
		public const UNCHANGED_VALUE = -1;			// Ensure initial slider value doesn't change initial datacell value
		
        private var _debugger:DebugUtil;
        private var sliderBox:AttributeSliderBox;
        private var dataCell:ColorCell;
        private var gradientCell:GradientCell;
        private var attrPos:Positions;					// Maintains orientaiton of elements to each other.  Supports up to 9
        private var orientationStr:String;	
        private var offsetX:uint;	
        private var offsetY:uint;
        private var attributes_arr:Array;

		// Constructor
		public function EditCellAttributes()
		{
			super();
			//this._debugger = DebugUtil.getInstance();
			this.init();
		}

		/**
		*Name:  setCellRGB
		*Purpose:  Update the datacell with a new color
		*@param inRed uint Integer from 0 to 255 for red
		*@param inGreen uint Integer from 0 to 255 for green
		*@param inBlue uint Integer from 0 to 255 for blue
		*/
		public function setCellRGB(inRed:uint,inGreen:uint,inBlue:uint):void {
			if (this.dataCell != null)
			{
				this.dataCell.assignRGB(inRed,inGreen,inBlue);
			}
        }
		/****************************************************************************************************************
		** Events
		****************************************************************************************************************/

		private function sliderChange(inSliderObj:Object):void {
			this.updateSliders(inSliderObj.property);
		}
		
		/****************************************************************************************************************
		** Private
		****************************************************************************************************************/

		private function updateSliders(inFeature:String)
		{
			//this._debugger.functionTrace("EditCellAttributes.updateSliders");
			var tempObj:Object;
			tempObj = this.dataCell.getAffectedProperties(inFeature);
			for (var feature:String in tempObj)
			{
				this._debugger.wTrace("testing slider feature " + feature + " = " +tempObj[feature]);
				this.sliderBox.updateSlider(feature,tempObj[feature]);
			}
		}
		
		private function addCell()
		{
			this.dataCell = new ColorCell();
			this.dataCell.size = DEFAULT_SIZE;
			this.dataCell.drawCircle();
			addChild(this.dataCell);
		}
		
		private function addGradientCell()
		{
			this.gradientCell = new GradientCell();
			this.gradientCell.size = DEFAULT_SIZE;
			this.gradientCell.drawGradientRect();
			this.gradientCell.datacellRGB = 0xFFFFFF;
			addChild(this.gradientCell);
		}
		
		/**
		* Function:  addSlider
		* Purpose:	Adds a slider graphic for manipulating the passed value
		* param inAttr String Attribute name
		* param inLabel String Attribute display label
		* param inMin Number Minimum value supported
		* param inMax Number Maximum value supported
		* param ininInit Number Initial value supported
		*/
		private function addSlider(inAttr:String,inLabel:String,inMin:Number,inMax:Number,inInit:Number)
		{
			this.sliderBox = (this.sliderBox == null) ? new AttributeSliderBox() : this.sliderBox;
			this.sliderBox.addSlider(this.dataCell,inAttr,inLabel,inMin,inMax,inInit);
			this.sliderBox.orientation = this.orientationStr;
			this.dataCell[inAttr] = inInit;
			addChild(this.sliderBox);
		}
		
		private function positionElements()
		{
			var cellOffsetX:uint;
			var sliderBoxOffsetY:uint;
			cellOffsetX = this.offsetX  + 10 +  ((this.sliderBox.width - this.dataCell.width) / 2);
			sliderBoxOffsetY = this.offsetY;
			this.attrPos.addElement(this.dataCell,Positions.ROW,cellOffsetX,this.offsetY);
			this.attrPos.addElement(this.sliderBox,Positions.ROW,this.offsetX,sliderBoxOffsetY);
			this.attrPos.positionElements();

		}

        private function init():void {
			
			this.attributes_arr = ["r","g","b","a","m","c","ye","h"];
			this.attrPos = new Positions();
			this.orientationStr	= AttributeSlider.HORIZONTAL;
			this.offsetX = 0;	
			this.offsetY = 0;
			
			addCell();
			
			setCellRGB(122,122,122);
			
			// Set values
			addSlider("r","Red",0,255,UNCHANGED_VALUE);
			addSlider("g","Green",0,255,UNCHANGED_VALUE);
			addSlider("b","Blue",0,255,UNCHANGED_VALUE);
			addSlider("a","Alpha",0,100,100);
			
			// Use RGB values already defined
			// addSlider("m","Magenta",0,255,this.dataCell.m);	
			// addSlider("c","Cyan",0,255,this.dataCell.c);	
			// addSlider("ye","Yellow",0,255,this.dataCell.ye);
			addSlider("h","Hue",0,360,UNCHANGED_VALUE);
			addSlider("s","Saturation",0,100,UNCHANGED_VALUE);

			addSlider("P","Perceived",0,100,UNCHANGED_VALUE);
			addSlider("v","Value",0,100,UNCHANGED_VALUE);			
			// After all have been added initialize the display
			this.sliderBox.displaySliders();
			
			// Ensure this object is notified when sliders change
			this.sliderBox.addSliderListener(sliderChange);

			//this.gradientCell.visible = true;
			positionElements();
		}
    }
}