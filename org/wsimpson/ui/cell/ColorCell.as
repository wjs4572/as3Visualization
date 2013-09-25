package org.wsimpson.ui.cell

/*
** Title:	ColorCell.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.ColorUtil;
	import org.wsimpson.ui.cell.Cell;
	
	public class ColorCell extends Cell
	{
        private var _debugger:DebugUtil;
        protected var bgColor:ColorUtil;

		// Constructor
		public function ColorCell()
		{
			super();
			this._debugger = DebugUtil.getInstance();

			this.bgColor = new ColorUtil();	
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  Name:  	getAffectedProperties
		*  Purpose:  The RGB color value of the data cell.
		*/
        public function getAffectedProperties(inStr:String):Object {
			return this.bgColor.getAffected(inStr);
		}
		
		/**
		*  Name:  	datacellRGB
		*  Purpose:  The RGB color value of the data cell.
		*/
        public function get datacellRGB():uint {
			return this.bgColor.color;
		}
		
        public function set datacellRGB(inColor:uint):void {
			//this._debugger.functionTrace("DataCell.datacellRGB");		
			var newColor:ColorUtil;
			newColor = new ColorUtil(inColor);
			this.bgColor.setTransitionSteps(1);
			this.bgColor.smoothColorChange(this,this.bgColor,newColor,0);
		}

		/**
		*  Name:  	assignRGB
		*  Purpose:  Used to assign an RGB color using decimal values from 0 to 255
		*
		*	@param inRed uint Red value defined using decimal values ranging from 0 to 255
		*	@param inGreen uint Red value defined using decimal values ranging from 0 to 255
		*	@param inBlue uint Red value defined using decimal values ranging from 0 to 255
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Use the Style Manager to manager multiple CSS files
		*/			
		public function assignRGB(inRed:uint,inGreen:uint,inBlue:uint):void {
			this.r = inRed;
			this.g = inGreen;
			this.b = inBlue;
        }

		
		/**
		*  Name:  	getRGB_CSS
		*  Purpose:  The RGB color value of the data cell.
		*/
        public function getRGB_CSS():String {
			return this.bgColor.getRGB_CSS();
		}
		
		/**
		*  Name:  	setRGB_CSS
		*  Purpose:  Used to assign an RGB color via a CSS style definition
		*
		*	@param inStr String RGB color string designated as single or double digit hexadecimal values for RGB.
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Use the Style Manager to manager multiple CSS files
		*/	
		public function setRGB_CSS(inStr:String):void {
			this.bgColor.setRGB_CSS(inStr);
            this.updateColor();
        }
		
		/**
		*  Name:  	CSS_to_RGB
		*  Purpose:  Convert a CSS defined color string to a RGB defined color string
		*
		*	@param inStr String RGB color string designated as single or double digit hexadecimal values for RGB.
		*	@return Number The CSS value as an RGB number
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext Use the Style Manager to manager multiple CSS files
		*/	
		public function CSS_to_RGB(inStr:String):Number {
			return this.bgColor.CSSToRGB(inStr);
        }
		
		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/

		// Magenta
        public function get m():uint {
			return this.bgColor.magenta;
        }

        public function set m(inMagenta:uint):void {
			this.bgColor.magenta = inMagenta;
            this.updateColor();
        }
		
		// Cyan
        public function get c():uint {
			return this.bgColor.cyan;
        }

        public function set c(inCyan:uint):void {
			this.bgColor.cyan = inCyan;
            this.updateColor();
        }
		
		// Yellow
        public function get ye():uint {
			return this.bgColor.yellow;
        }

        public function set ye(inYellow:uint):void {
			this.bgColor.yellow = inYellow;
            this.updateColor();
        }

		// RGB - red
        public function get r():uint {
			return this.bgColor.red;
        }

        public function set r(inRed:uint):void {
			this.bgColor.red = inRed;
			
            this.updateColor();
        }
		
		// RGB - green
        public function get g():uint {
			return this.bgColor.green;
        }

        public function set g(inGreen:uint):void {
			this.bgColor.green = inGreen;
            this.updateColor();
        }
		
		// RGB - blue
        public function get b():uint {
			return this.bgColor.blue;
        }

        public function set b(inBlue:uint):void {
			this.bgColor.blue = inBlue;
            this.updateColor();
        }		

		// HSV - H
        public function get h():int {
			return (this.bgColor.hue);
        }

        public function set h(inHue:int):void {
			this.bgColor.hue = inHue;
			this.updateColor();
        }

		// HSV - S
        public function get s():uint {
			return (this.bgColor.saturation);
        }

        public function set s(inSat:uint):void {
			this.bgColor.saturation = inSat;
			this.updateColor();
        }

		// HSV - V
        public function get v():uint {
			return (this.bgColor.value);
        }

        public function set v(inValue:uint):void {
			this.bgColor.value = inValue;
			this.updateColor();
        }
		
		// HSP - P
        public function get P():uint {
			return (this.bgColor.value);
        }

        public function set P(inPerceived:uint):void {
			this.bgColor.perceived = inPerceived;
			this.updateColor();
        }
		
		// Transparency - alpha
        public function get a():uint {
			return (this.bgColor.alpha * 100);
        }

        public function set a(inAlpha:uint):void {
			this.bgColor.alpha = (inAlpha / 100);
			this.updateColor();
        }

		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/

		public function updateColor():void {
            this.transform.colorTransform = this.bgColor;
        }
    }
}