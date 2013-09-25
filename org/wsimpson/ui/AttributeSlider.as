package org.wsimpson.ui

/*
** Title:	AttributeSlider.as
** Purpose: Used for updating the feature passed
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;	
  	import org.wsimpson.util.Positions;	 
    import fl.controls.Slider;
    import fl.controls.SliderDirection;	
    import fl.events.SliderEvent;
    import flash.display.Sprite;
    import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;	
	import flash.text.TextFormat;

	
	public class AttributeSlider extends Sprite
	{
		// Public Instance Variables
		public static var HORIZONTAL:String = SliderDirection.HORIZONTAL;	// A alt value is present
		public static var VERTICAL:String = SliderDirection.VERTICAL;		// A alt value is present
		
		// Private Instance Variables
        private var _debugger:DebugUtil			// Object interfacing with the debugger window and flash trace
		private var targetObj:Object;				// Object that will be affected by the slider
        private var attrPos:Positions;				// Maintains orientaiton of elements to each other.			
        private var slider:Slider;					// Flash Slider component
        private var orientationStr:String			// Orientation of the content
        private var featureName:String;				// The display name of the object feature
        private var featureProperty:String;			// The object's property name
		private var featureLabel:TextField;			// TextField displaying the display name of the object fature
		private var featureFormat:TextFormat;		// Format of the text fields
		private var featureValue:TextField;			// The current value of the object's property
        private var sMax:uint;						// Maximum allowed value
        private var sMin:uint;						// Minimum allowed value
        private var offsetX:uint;					// X alignment
        private var offsetY:uint;					// Y alignment		
        private var labelLength:uint;				// Ensures consistent label widths
        private var listener_array:Array;			// Notify listeners upon changes
		
		// Constructor
		public function AttributeSlider(inObject:Object,featureStr:String,featureLabelStr:String,inDirection:String,inMin:Number=0,inMax:Number=100,inValue:Number=100)
		{
			super();
			this.targetObj = inObject;
			this.featureProperty = featureStr;
			this.featureName = featureLabelStr;
			this.orientationStr = inDirection;
			this.sMax = inMax;
			this.sMin = inMin;
			this.targetObj[this.featureProperty] = inValue;
			//this._debugger = DebugUtil.getInstance();
			this.init();
		}
		
		public function hideSliders():void 
		{
			this.boolValueDisplay = false;
		}
		
		public function showSliders():void 
		{
			this.boolValueDisplay = true;
			positionSlider();
		}

		/************************************************************************************************************************************
		**  PARAMETERS
		************************************************************************************************************************************/
        public function get labelWidth():uint {
			//this._debugger.functionTrace("AttributeSlider.get labelWidth " + this.featureLabel.textWidth);
			return this.featureLabel.textWidth;
        }
        public function set labelWidth(inWidth:uint):void {
			//this._debugger.functionTrace("AttributeSlider.set labelWidth " + inWidth);
			this.labelLength = inWidth - this.featureLabel.textWidth;
			//this._debugger.functionTrace("AttributeSlider.set labelWidth " + this.labelLength);			
        }
		
        public function get boolValueDisplay():Boolean {
			return this.featureValue.visible;
        }		
        public function set boolValueDisplay(inBool:Boolean):void {
			this.featureValue.visible = inBool;
        }

        public function get label():String {
			return this.featureName;
        }		
        public function set label(inStr:String):void {
			this.featureName = inStr;
        }

        public function get property():String {
			return this.featureProperty;
        }		
        public function set property(inStr:String):void {
			this.featureProperty = inStr;
        }
		
		public function get value():Number {
			return this.slider.value;
        }		
        public function set value(inNum:Number):void {
			var boolRange:Boolean;
			var altText:String;
			boolRange = rangeCheck(this.featureName,inNum);
			this.slider.value = (boolRange) ? inNum : 0;
			altText = (inNum == -1) ? "N/A" : this.featureValue.text;
			this.featureValue.text = (boolRange) ? inNum.toString() : altText;
        }
		
		public function get orientation():String 
		{
			return this.orientationStr;
        }		
        public function set orientation(inDirection:String):void 
		{
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
			this.slider.direction = this.orientationStr;
			positionSlider();
        }

		/**
		*  name:  addSliderListner
		*  @param inFunction	Function	Event listner
		*/
		public function addSliderListener(inFunction:Function):void {
			//this._debugger.functionTrace("AttributeSlider.addEventListener");
			
			this.listener_array = (this.listener_array == null) ? new Array() : this.listener_array;
			this.listener_array.push(inFunction);
		}
		

		/************************************************************************************************************************************
		**  Event Handlers
		************************************************************************************************************************************/
		
		private function sliderChange(event:SliderEvent):void {
			//this._debugger.functionTrace("AttributeSlider.sliderChange");
			this.targetObj[this.featureProperty] = event.value;		
			this.value = this.targetObj[this.featureProperty];
			this.notifyListeners();
		}
		
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/

		private function rangeCheck(fieldStr:String,n:int):Boolean
		{
			var boolRange:Boolean;
			try {
				boolRange = NumberUtil.rangeCheck(n,this.sMin,this.sMax);
			} catch(error:RangeError) {
				this._debugger.wTrace("AttributeSlider: RangeError catch: ");
				this._debugger.wTrace("field: " + fieldStr);
				this._debugger.wTrace("error: " + error);
				this._debugger.errorTrace(error.getStackTrace());
			}
			return  boolRange;
		}		
		
		private function notifyListeners():void {
			//this._debugger.functionTrace("AttributeSlider.addEventListener");

			for (var i:Number = 0; i < this.listener_array.length; i++)
			{
				this.listener_array[i](this);
			}
		}
		
		private function createTextFormat():void {
			//this._debugger.functionTrace("AttributeSlider.createTextFormat");
			this.featureFormat = new TextFormat();
			this.featureFormat.font = "( Arial Unicode MS* )";
			this.featureFormat.bold = true;		
			this.featureFormat.size = 14;			
			this.featureFormat.align = TextFormatAlign.LEFT;
		}
		
		private function addLabel():void {
			//this._debugger.functionTrace("AttributeSlider.addLabel");
			this.featureLabel = new TextField();
			this.featureLabel.background = false;
			this.featureLabel.multiline = false;			
			this.featureLabel.height = 20;
			this.featureLabel.width = 40;
			this.featureLabel.autoSize = TextFieldAutoSize.LEFT;		
			this.featureLabel.text = this.featureName;			
			this.featureLabel.defaultTextFormat = this.featureFormat;
			this.featureLabel.setTextFormat(this.featureFormat);
			addChild(this.featureLabel);
		}
		
		private function addSlider():void {
			//this._debugger.functionTrace("AttributeSlider.addSlider");	
			this.slider = new Slider();
			this.slider.snapInterval = 1;
			this.slider.tickInterval = 10;
			this.slider.maximum = this.sMax;
			this.slider.minimum = this.sMin;
			this.slider.direction = this.orientationStr;
			this.slider.addEventListener(SliderEvent.CHANGE,sliderChange);
			addChild(this.slider);
		}

		
		private function addValueDisplay():void {
			//this._debugger.functionTrace("AttributeSlider.addValueDisplay");
			this.featureValue = new TextField();
			this.featureValue.background = false;
			this.featureValue.maxChars = this.sMax.toString().length;
			this.featureValue.multiline = false;
			this.featureValue.height = 20;
			this.featureValue.width = 30;
			this.featureValue.autoSize = TextFieldAutoSize.LEFT;	
			this.featureValue.defaultTextFormat = this.featureFormat;
			this.featureValue.setTextFormat(this.featureFormat);
			addChild(this.featureValue);
		}
		
		private function positionSlider()
		{
			//this._debugger.functionTrace("AttributeSlider.positionSlider");
			var tempOrientationStr:String;
			var offsetSliderX:uint;				// X alignment
			var offsetSliderY:uint;				// Y alignment
			var offsetValueY:uint;				// Y alignment			

			this.attrPos = new Positions();  // Replaces previous object, which only exists here and  should be garbage collected automatically
			
			switch(this.orientationStr)
			{
				case AttributeSlider.VERTICAL:
					tempOrientationStr = Positions.ROW;
					offsetSliderX = this.offsetX + 20;
					offsetSliderY = this.featureLabel.textHeight;
					offsetValueY = this.offsetY + 20 +  this.slider.width;
				break;
				case AttributeSlider.HORIZONTAL:
				default:
					tempOrientationStr = Positions.COLUMN;
					offsetSliderX = this.offsetX + this.labelLength;
					offsetSliderY = this.offsetY + 5;
					offsetValueY = this.offsetY;
				break;
			}	
			this.attrPos.addElement(this.featureLabel,tempOrientationStr,this.offsetX,this.offsetY);
			this.attrPos.addElement(this.slider,tempOrientationStr,offsetSliderX,offsetSliderY);	
			this.attrPos.addElement(this.featureValue,tempOrientationStr,this.offsetX,offsetValueY);
			this.attrPos.positionElements();
		}
		
		
        private function init():void {
			//this._debugger.functionTrace("AttributeSlider.init");
			this.offsetX = 8;
			this.offsetY = 10;
			
			createTextFormat();
			addLabel();
			addSlider();
			addValueDisplay();
			positionSlider();
			this.value = this.targetObj[this.featureProperty];
		}
    }
}