package org.wsimpson.ui

/*
** Title:	AttributeSliderBox.as
** Purpose: Container for multiple attribute sliders.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.ui.AttributeSlider;
	import org.wsimpson.util.Positions;
    import fl.controls.SliderDirection;		
    import flash.display.DisplayObject;
    import flash.display.Sprite;
	
	public class AttributeSliderBox extends Sprite
	{	
		// Private Instance Variables
        private var _debugger:DebugUtil;
        private var boolShowValues:Object;			// Show the values 
        private var sliderObj:Object;				// Container for associative array of attribute sliders
        private var sliderArr:Array;				// Container for associative array of attribute sliders
        private var orientationStr:String;			// Supported orientations of the sliders
        private var lengthLabel:uint;				// The length of the slider label
        private var offsetX:uint;					// Creates the grid arrangement
        private var offsetY:uint;					// Creates the grid arrangement
        private var attrPos:Positions;				// Maintains orientation of elements to each other.	

		// Constructor
		public function AttributeSliderBox()
		{
			super();
			//this._debugger = DebugUtil.getInstance();
			this.init();
		}
		
		/************************************************************************************************************************************
		**  PARAMETERS
		************************************************************************************************************************************/

        public function get orienation():String 
		{
			return this.orientationStr;
        }		
        public function set orientation(inDirection:String):void 
		{
			////this._debugger.functionTrace("AttributeSliderBox.orientation " + inDirection);
			switch(inDirection)
			{
				case AttributeSlider.VERTICAL:
				case AttributeSlider.HORIZONTAL:
					this.orientationStr = inDirection;
				break
				default:
					this.orientationStr = AttributeSlider.HORIZONTAL;				
				break;
			}
			updateOrientation();
        }
		
		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/
		/**
		*  Name:  addSlider
		*  Purpose:  Adds a attibute slider to the AttributeSliderBox
		*  @param inObject	Object		Object whose feature is modified by the slider
		*  @param featureStr	String		Object property name
		*  @param featureLabel	String		Object property display name
		*  @param inDirection	String		Supported orientations of the sliders
		*  @param inMin		Number		Minimum value allowed
		*  @param inMax		Number		Maximum value allowed
		*/
		public function addSlider(inObject:Object,featureStr:String,featureLabel:String,inMin:Number,inMax:Number,inValue:Number)
		{
			////this._debugger.functionTrace("AttributeSliderBox.addSlider");
			this.sliderArr = (this.sliderArr == null) ? new Array() : this.sliderArr;
			this.sliderObj = (this.sliderObj == null) ? new Object() : this.sliderObj;
			this.sliderObj[featureStr] = new AttributeSlider(inObject,featureStr,featureLabel,this.orientationStr,inMin,inMax,inValue);
			this.sliderArr.push(this.sliderObj[featureStr]);
			this.addChild(this.sliderObj[featureStr]);
		}
		
		/**
		*  Name:  	displaySliders
		*  Purpose: Posiions the sliders and updates them
		*/
		public function displaySliders()
		{
			this.positionElements();
			this.showSliders();
		}
		
		public function hideSliders():void 
		{
			for (var slider:String in this.sliderObj)
			{
				this.sliderObj[slider].hideSliders();
			}
        }
		
        public function showSliders():void
		{
			for (var slider:String in this.sliderObj)
			{
				this.sliderObj[slider].showSliders();
			}
        }
		
		public function addSliderListener(inFunction:Function):void
		{
			for (var feature:String in this.sliderObj)
			{
				this.sliderObj[feature].addSliderListener(inFunction);
			}
        }
		
		public function updateSlider(inFeature:String, inValue:uint):void
		{
			if (this.sliderObj[inFeature] != undefined)
			{
				this.sliderObj[inFeature].value = inValue;
			}
        }
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/

		private function updateOrientation()
		{
			////this._debugger.functionTrace("AttributeSliderBox.updateOrientation " + this.orientationStr);
			for (var slider:String in this.sliderObj)
			{
				this.sliderObj[slider].orientation = this.orientationStr;
			}
		}	
		
		private function determineLongestLabel():uint
		{
			////this._debugger.functionTrace("AttributeSliderBox.determineLongestLabel");
			var tempLength:uint;
			tempLength = 0;
			for (var slider:String in this.sliderObj)
			{
				var tempNum:uint;
				tempNum = this.sliderObj[slider].labelWidth;
				tempLength = (tempNum > tempLength) ? tempNum : tempLength;
			}
			return tempLength;
		}
		
		private function positionElements()
		{
			////this._debugger.functionTrace("AttributeSliderBox.positionElements");
			
			this.lengthLabel = this.determineLongestLabel();
			this.attrPos = new Positions();			
			for (var i:Number = 0; i < this.sliderArr.length; i++ )
			{
				var tempOrientationStr:String;
				switch(this.orientationStr)
				{
					case AttributeSlider.VERTICAL:
						tempOrientationStr = Positions.COLUMN;
					break;
					case AttributeSlider.HORIZONTAL:
					default:
						this.sliderArr[i].labelWidth = this.lengthLabel;
						tempOrientationStr = Positions.ROW;
					break;
				}
				this.attrPos.addElement(this.sliderArr[i],tempOrientationStr,this.offsetX,this.offsetY);				
			}
			this.attrPos.positionElements();			
		}
		
        private function init():void {
			////this._debugger.functionTrace("AttributeSliderBox.init");

			//this.orientationStr = AttributeSlider.HORIZONTAL;
			this.orientationStr = AttributeSlider.VERTICAL;
			this.offsetX = 0;
			this.offsetY = 5;
		}
    }
}