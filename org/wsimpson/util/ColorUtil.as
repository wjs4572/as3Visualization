package org.wsimpson.util
/*
** Title:	ColorUtil.as
** Purpose: Tool for managing color calculations
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
**
** Throws:  RangeError
*/

{
	
	// Adobe
	import fl.motion.Color;
    import flash.display.DisplayObject;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.geom.ColorTransform;

	// Util
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.NumberUtil;
	import org.wsimpson.errors.RangeError;
			
	// Formats
	import org.wsimpson.format.NumberFormat;	

	
	public class ColorUtil extends Color
	{
		// Constants
		public static const R_CONV = 0.241;				// HSP conversion for red
		public static const G_CONV = 0.691;				// HSP conversion for green
		public static const B_CONV = 0.068;				// HSP conversion for blue
						
		// Private Instance Variables
        private var _debugger:DebugUtil;			// The stage object used for trace output
        private var prevColor:Color;				// the previous Color used for the smoothColorChange
        private var nextColor:Color;				// the next Color used for the smoothColorChange
        private var transitionStage:Number;			// The stage in the transition used to colculate updates
        private var transitionSteps:Number;			// Number of steps used
        private var displayObj:DisplayObject;		// Holds the display object to be modified

		// Constructor
		function ColorUtil(	inRGB:uint = 0x000000)
		{
			super(0,0,0,0,0,0,0,255);
			this._debugger = DebugUtil.getInstance();
			this.color = inRGB;
			this.setTransitionSteps();
		}

		/*********************************************************************************************  HSP and RGB conversions		*******************************************************************************************/

		private function rangeCheck(fieldStr:String,n:int,inMin:int=0,inMax:int=255):Boolean
		{
			var boolRange:Boolean;
			try {
				boolRange = NumberUtil.rangeCheck(n,inMin,inMax);
			} catch(error:RangeError) {
				this._debugger.wTrace("ColorUtil: RangeError catch: ");
				this._debugger.wTrace("field: " + fieldStr);
				this._debugger.wTrace("error: " + error);
				this._debugger.errorTrace(error.getStackTrace());
			}
			return  boolRange;
		}
		
		private function rangeCheckRGB(inR:int, inG:int, inB:int):Boolean
		{
			// Confirm expected value ranges
			return rangeCheck("Red",inR) && rangeCheck("Green",inG) && rangeCheck("Blue",inB);
		}
		/*********************************************************************************************  HSP and RGB conversions		*******************************************************************************************/	
		/**
		*Name:  RGB_to_HSP
		*Purpose:  Derive HSP values from RGB
		*Reference:  http://alienryderflex.com/hsp.html
		*@param inR uint Interger from 0 to 255 for red
		*@param inG uint Interger from 0 to 255 for green
		*@param inB uint Interger from 0 to 255 for blue
		*@return > 0 converted value, < 0 error
		*/
		public function RGB_to_HSP(inR:int, inG:int, inB:int):Object
		{
			var tempObj:Object;
			tempObj = new Object();
			
			if (rangeCheckRGB(inR,inG,inB))
			{
				tempObj.r = inR / 255;
				tempObj.g = inG / 255;
				tempObj.b = inB / 255;
				
								
				tempObj.minRGB = NumberUtil.getMin([tempObj.r,tempObj.g,tempObj.b]);
				tempObj.maxRGB = NumberUtil.getMax([tempObj.r,tempObj.g,tempObj.b]);
				
				//  Calculate the Perceived brightness.				
				tempObj.P = Math.sqrt((Math.pow(tempObj.r,2) * R_CONV) + (Math.pow(tempObj.g,2) * G_CONV) + (Math.pow(tempObj.b,2) * B_CONV));
				

				//  Calculate the Hue and Saturation.  (This part works
				//  the same way as in the HSV/tempObj.b and HSL systems???.)
				if      (tempObj.r==tempObj.g && tempObj.r==tempObj.b) 
				{
					tempObj.h=0.; 
					tempObj.s=0.;
				} else {
					if  (tempObj.r == tempObj.maxRGB)
					{
						if (tempObj.b >= tempObj.g) 
						{
							tempObj.h = 6/6 - 1/6*(tempObj.b-tempObj.g)/(tempObj.r-tempObj.g); 
							tempObj.s = 1 - tempObj.g/tempObj.r;
						} else 
						{
							tempObj.h=0/6 + 1/6 * (tempObj.g-tempObj.b)/(tempObj.r-tempObj.b);
							tempObj.s= 1 - tempObj.b/tempObj.r; 
						}
					} else if (tempObj.g == tempObj.maxRGB) 
					{   
						if (tempObj.r >= tempObj.b)
						{
							tempObj.h = 2/6 - 1/6 * (tempObj.r-tempObj.b)/(tempObj.g-tempObj.b);
							tempObj.s = 1 - tempObj.b/tempObj.g;
						}
						else         
						{
							tempObj.h = 2/6 + 1/6 * (tempObj.b-tempObj.r)/(tempObj.g-tempObj.r);
							tempObj.s = 1 - tempObj.r/tempObj.g;
						}
					} else
					{
						if    (tempObj.g >= tempObj.r) 
						{
							tempObj.h=4 /6 -1 /6 *(tempObj.g-tempObj.r)/(tempObj.b-tempObj.r);
							tempObj.s=1 -tempObj.r/tempObj.b; 
						} else
						{
							tempObj.h = 4/6 + 1/6 * (tempObj.r-tempObj.g)/(tempObj.b-tempObj.g);
							tempObj.s = 1 - tempObj.g/tempObj.b;
						}
					}
				}
			}
			return tempObj;
		}
		
		private function hsp_conv(inObj:Object,inA:Number,inB:Number,inC:Number):Number
		{
			return (	inObj.P / 
						Math.sqrt(	inA / Math.pow(inObj.Mom,2) + 
									inB * Math.pow(inObj.part,2) + 
									inC
									)
					);
		}
		
		private function hsp_conv2(inObj:Object,inA:Number,inB:Number):Number
		{
			return Math.sqrt( Math.pow(inObj.P,2) / 
						(	inA + inB *
							Math.pow(inObj.h,2)
						)
					);
		}
		
		/**
		*Name:  HSP_to_RGB
		*Purpose:  Derive HSP values from RGB
		*Reference:  http://alienryderflex.com/hsp.html
		*@param inH Number Float from 0 to 360 for hue
		*@param inS Number Float from 0 to 1 for saturation
		*@param inP Number Float from 0 to 1 for percieved brightness
		*@return > 0 converted value, < 0 error
		*/
		public function HSP_to_RGB(inH:Number, inS:Number, inP:Number):Object
		{
			var tempObj:Object;
			tempObj = new Object();

			if (rangeCheck("Hue",inH,0,1) && rangeCheck("Saturation",inS,0,1) &&
				rangeCheck("Perceived Brightness",inP,0,1))
			{
				this._debugger.wTrace("testing HSP to RGB h = " + inH);
				this._debugger.wTrace("testing HSP to RGB s = " + inS);
				this._debugger.wTrace("testing HSP to RGB p = " + inP);

				tempObj.h = inH;
				tempObj.s = inS;
				tempObj.P = inP;
				tempObj.Pr = R_CONV;
				tempObj.Pg = G_CONV;
				tempObj.Pb = B_CONV;
				tempObj.Mom = 1 - tempObj.s; // MinOverMax

				if (tempObj.Mom > 0 )
				{
					if ( tempObj.h < 1/6 ) 
					{   
						//  R>G>B
						tempObj.h = 6 * ( tempObj.h - 0/6 ); 
						tempObj.part = 1  +tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.b = hsp_conv(tempObj,tempObj.Pr,tempObj.Pg,tempObj.Pb);
						tempObj.r = tempObj.b / tempObj.Mom; 
						tempObj.g = tempObj.b + tempObj.h * (tempObj.r-tempObj.b);
					}
					else if ( tempObj.h<2 /6 ) 
					{
					//  G>R>B
						tempObj.h = 6 * (-tempObj.h + 2/6 );
						tempObj.part =1 + tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.b = hsp_conv(tempObj,tempObj.Pg,tempObj.Pr,tempObj.Pb);
						tempObj.g = tempObj.b/tempObj.Mom;
						tempObj.r = tempObj.b + tempObj.h * (tempObj.g - tempObj.b); 
					}
					else if ( tempObj.h < 3/6 ) 
					{   
						//  G>B>R
						tempObj.h = 6 * ( tempObj.h - 2/6 ); 
						tempObj.part = 1 + tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.r = hsp_conv(tempObj,tempObj.Pg,tempObj.Pb,tempObj.Pr);
						tempObj.g = tempObj.r / tempObj.Mom; 
						tempObj.b = tempObj.r + tempObj.h * (tempObj.g - tempObj.r);
					}
					else if ( tempObj.h < 4/6 ) 
					{
						//  B>G>R
						tempObj.h = 6 * (- tempObj.h + 4/6 );
						tempObj.part = 1 + tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.r = hsp_conv(tempObj,tempObj.Pb,tempObj.Pg,tempObj.Pr);
						tempObj.b = tempObj.r / tempObj.Mom;
						tempObj.g = tempObj.r + tempObj.h * (tempObj.b - tempObj.r);
					}
					else if ( tempObj.h < 5/6 )
					{
						//  B>R>G
						tempObj.h = 6 * ( tempObj.h - 4/6 );
						tempObj.part = 1 + tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.g = hsp_conv(tempObj,tempObj.Pb,tempObj.Pr,tempObj.Pg);
						tempObj.b = tempObj.g / tempObj.Mom;
						tempObj.r = tempObj.g + tempObj.h * (tempObj.b - tempObj.g);
					}
					else
					{
						//  R>B>G
						tempObj.h = 6 * ( -tempObj.h+6/6 );
						tempObj.part = 1 + tempObj.h * ( 1/tempObj.Mom - 1 );

						tempObj.g = hsp_conv(tempObj,tempObj.Pr,tempObj.Pb,tempObj.Pg);
						tempObj.r = tempObj.g / tempObj.Mom;
						tempObj.b = tempObj.g + tempObj.h * (tempObj.r - tempObj.g);
					}
				}
				else
				{
					if ( tempObj.h<1 /6 ) 
					{   
						//  R>G>B
						tempObj.h = 6 *( tempObj.h - 0/6 );
						tempObj.r = hsp_conv2(tempObj,tempObj.Pr,tempObj.Pg);
						tempObj.g = tempObj.r * tempObj.h; 
						tempObj.b = 0; 
					}
					else if ( tempObj.h < 2/6 ) 
					{
						//  G>R>B
						tempObj.h = 6 * ( -tempObj.h + 2/6 );
						tempObj.g = hsp_conv2(tempObj,tempObj.Pg,tempObj.Pr);
						tempObj.r = tempObj.g * tempObj.h;
						tempObj.b = 0;
					}
					else if ( tempObj.h < 3/6 ) 
					{   
						//  G>B>R
						tempObj.h = 6 * ( tempObj.h - 2/6 ); 
						tempObj.g = hsp_conv2(tempObj,tempObj.Pg,tempObj.Pb);
						tempObj.b = tempObj.g * tempObj.h;
						tempObj.r = 0; 
					}
					else if ( tempObj.h < 4/6 )
					{
						//  B>G>R
						tempObj.h = 6 * ( -tempObj.h + 4/6 );
						tempObj.b = hsp_conv2(tempObj,tempObj.Pb,tempObj.Pg);
						tempObj.g = tempObj.b * tempObj.h;
						tempObj.r = 0 ;
					}
					else if ( tempObj.h < 5/6 )
					{
						//  B>R>G
						tempObj.h = 6 * ( tempObj.h - 4/6 );
						tempObj.b = hsp_conv2(tempObj,tempObj.Pb,tempObj.Pr);
						tempObj.r = tempObj.b * tempObj.h; 
						tempObj.g = 0;
					}
					else
					{
						//  R>B>G
						tempObj.h = 6 * ( -tempObj.h + 6/6 );
						tempObj.r = hsp_conv2(tempObj,tempObj.Pr,tempObj.Pb);
						tempObj.b = tempObj.r * tempObj.h;
						tempObj.g = 0;
					}
				}
				tempObj.r = int(tempObj.r * 255);
				tempObj.g = int(tempObj.g * 255);
				tempObj.b = int(tempObj.b * 255);
				this._debugger.wTrace("HSP to RGB R: " + tempObj.r);
				this._debugger.wTrace("HSP to RGB G: " + tempObj.g);
				this._debugger.wTrace("HSP to RGB B: " + tempObj.b);
			}
			return tempObj;
		}
		
		/**
		*Name:  HSV_to_RGB
		*Purpose:  Derive RGB from HSV
		*Reference:  http://www.cs.rit.edu/~ncs/color/t_convert.html
		*@param inH uint Interger from 0 to 360 for hue
		*@param inS uint Interger from 0 to 1 for satruation
		*@param inV uint Interger from 0 to 1 for brightness
		*/
		public function HSV_to_RGB(inH:Number, inS:Number, inV:Number):Object
		{		
			var tempObj:Object;
			tempObj = new Object();

				// this._debugger.wTrace("testing HSV to RGB h = " + inH);
				// this._debugger.wTrace("testing HSV to RGB s = " + inS);
				// this._debugger.wTrace("testing HSV to RGB v = " + inV);
				
			if (rangeCheck("Hue",inH,0,360) && rangeCheck("Saturation",inS,0,1) &&
				rangeCheck("Value",inV,0,1))
			{
				tempObj.h = inH;
				tempObj.s = inS;
				tempObj.v = inV;
				
				if (inS != 0)
				{
					// i = sector 0 to 5
					inH /= 60;	
					tempObj.i = Math.floor( inH );
					
					// factorial part of h	
					tempObj.f = inH - tempObj.i;
					tempObj.p = tempObj.v * ( 1 - tempObj.s );
					tempObj.q = tempObj.v * ( 1 - tempObj.s * tempObj.f );
					tempObj.t = tempObj.v * ( 1 - tempObj.s * ( 1 - tempObj.f ) );
					switch( tempObj.i ) {
						case 0:
							tempObj.r = inV;
							tempObj.g = tempObj.t;
							tempObj.b = tempObj.p;
							break;
						case 1:
							tempObj.r = tempObj.q;
							tempObj.g = inV;
							tempObj.b = tempObj.p;
							break;
						case 2:
							tempObj.r = tempObj.p;
							tempObj.g = inV;
							tempObj.b = tempObj.t;
							break;
						case 3:
							tempObj.r = tempObj.p;
							tempObj.g = tempObj.q;
							tempObj.b = inV;
							break;
						case 4:
							tempObj.r = tempObj.t;
							tempObj.g = tempObj.p;
							tempObj.b = inV;
							break;
						default:		// case 5
							tempObj.r = inV;
							tempObj.g = tempObj.p;
							tempObj.b = tempObj.q;
							break;
					}
					} else 
					{
						// Value is achromatic =: grey
						tempObj.r = tempObj.g = tempObj.b = inV;
					}
					tempObj.r = int(tempObj.r * 255);
					tempObj.g = int(tempObj.g * 255);
					tempObj.b = int(tempObj.b * 255);
					// this._debugger.wTrace("HSV to RGB R: " + tempObj.r);
					// this._debugger.wTrace("HSV to RGB G: " + tempObj.g);
					// this._debugger.wTrace("HSV to RGB B: " + tempObj.b);
			}
			return tempObj;
		}
		
		/**
		*Name:  RGB_to_HSV
		*Purpose:  Apply the HSV algorthm to RGB values to obtained the
		**			 hue of an RGB value.
		*Reference:  http://www.cs.rit.edu/~ncs/color/t_convert.html
		*@param inR uint Interger from 0 to 255 for red
		*@param inG uint Interger from 0 to 255 for green
		*@param inB uint Interger from 0 to 255 for blue
		*/
		public function RGB_to_HSV(inR:int, inG:int, inB:int):Object
		{		
			var tempObj:Object;
			tempObj = new Object();

		if (rangeCheckRGB(inR,inG,inB))
			{
				// r,g,b values are from 0 to 1
				// h = [0,360], s = [0,1], v = [0,1]
				//		if s == 0, then h = -1 (undefined)

				// Arithmetic representations
				tempObj.r = inR / 255;
				tempObj.g = inG / 255;
				tempObj.b = inB / 255;
				
				// this._debugger.wTrace("RGB_to_HSV R: " + tempObj.r);
				// this._debugger.wTrace("RGB_to_HSV G: " + tempObj.g);
				// this._debugger.wTrace("RGB_to_HSV B: " + tempObj.b);
				
				tempObj.minRGB = NumberUtil.getMin([tempObj.r,tempObj.g,tempObj.b]);
				tempObj.maxRGB = NumberUtil.getMax([tempObj.r,tempObj.g,tempObj.b]);
	
				tempObj.v = tempObj.maxRGB;
				tempObj.delta = tempObj.maxRGB - tempObj.minRGB;
				
				tempObj.s = (tempObj.maxRGB != 0) ? tempObj.delta / tempObj.maxRGB : 0;
				
				if (tempObj.s > 0)
				{
					if (tempObj.r == tempObj.maxRGB)
					{
						// between yellow & magenta
						tempObj.h = ( tempObj.g - tempObj.b ) / tempObj.delta;
					}
					else if(tempObj.g == tempObj.maxRGB)
					{
						// between cyan & yellow
						tempObj.h = 2 + ( tempObj.b - tempObj.r ) / tempObj.delta;
					}
					else 
					{
						// blue is max
						// between magenta & cyan
						tempObj.h = 4 + ( tempObj.r - tempObj.g ) / tempObj.delta;
					}
					tempObj.h *= 60;					// degrees
					tempObj.h += ( tempObj.h < 0 ) ? 360 : 0;
				} else 
				{
					tempObj.h = -1;
				}
			}
			// this._debugger.wTrace("RGB_to_HSV h: " + tempObj.h);
			// this._debugger.wTrace("RGB_to_HSV s: " + tempObj.s);
			// this._debugger.wTrace("RGB_to_HSV v: " + tempObj.v);
			return tempObj;
		}
		/*********************************************************************************************  PARAMETERs		*******************************************************************************************/
		
		/*
		** The following public functions are based on Pixel.as by Colin Moock
		** http://www.moock.org/eas3/examples/moock_eas3_examples/eas3_bitmap_pixelclass/src/Pixel.as
		*/

		public function set alpha (n:Number):void {
					;
			if (rangeCheck("Alpha",n,0,100))
			{
				this.alphaMultiplier = n;
				this.alphaOffset = 0;
			}
		}		

		public function set magenta (n:int):void {
			if (rangeCheck("Magenta",n)) 
			{	
			
				// set red			
				this.color &= (0x00FFFF);
				this.color |= (n<<16);

				// set blue
				this.color &= (0xFFFF00);
				this.color |= (n);
			}
		}

		public function set cyan (n:int):void {
			// Confirm expected value ranges
			if (rangeCheck("Cyan",n)) 
			{				
				// set green			
				this.color &= (0xFF00FF);
				this.color |= (n<<8);

				// set blue
				this.color &= (0xFFFF00);
				this.color |= (n);
			}
		}
		
		public function set yellow (n:int):void {
			// Confirm expected value ranges
			if (rangeCheck("Yellow",n))
			{
				// set green			
				this.color &= (0xFF00FF);
				this.color |= (n<<8);

				// set red			
				this.color &= (0x00FFFF);
				this.color |= (n<<16);
			}
		}	
		
		public function set red (n:int):void {
			// Confirm expected value ranges
			if (rangeCheck("Red",n))
			{
				this.color &= (0x00FFFF);
				this.color |= (n<<16);
			}
		}

		public function set green (n:int):void {
			// Confirm expected value ranges
			if (rangeCheck("Green",n))
			{				
				this.color &= (0xFF00FF);
				this.color |= (n<<8);
			}
		}

		public function set blue (n:int):void {
			// Confirm expected value ranges
			if (rangeCheck("Blue",n))
			{
				this.color &= (0xFFFF00);
				this.color |= (n);
			}
		}
		
		public function set hue (n:int):void {
			var satNum:Number;
			var valNum:Number;			

			// Confirm expected value ranges
			if (rangeCheck("Hue",n,0,360) && (saturation > 0))
			{
				valNum = (value == 0) ? 0 : (value /100);
				satNum = (saturation == 0) ? 0 : (saturation /100);			
				this.setColorHSV(n,satNum,valNum);		

			}
			this._debugger.wTrace("set hue n = " + n);
		}
		
		public function set saturation (n:int):void {
			var sNum:Number;
			var valNum:Number;
			
			// Confirm expected value ranges
			if (rangeCheck("Saturation",n,0,100))
			{
				sNum = (n == 0) ? 0 : (n /100);
				valNum = (value == 0) ? 0 : (value /100);

				this._debugger.wTrace("set saturation sNum = " + sNum);
				if (hue >= 0)
				{
					this.setColorHSV(hue,sNum,valNum);
				}
			}
			this._debugger.wTrace("set saturation n = " + n);
		}
		
		public function set value (n:int):void {
			var sNum:Number;
			var satNum:Number;
			// Confirm expected value ranges
			if (rangeCheck("Value",n,0,100))
			{
				sNum = (n == 0) ? 0 : (n /100);
				satNum = (saturation == 0) ? 0 : (saturation /100);
				if (hue >= 0)
				{
					this.setColorHSV(hue,satNum,sNum);
				} else 
				{
					var tempVal:uint;
					tempVal = 255 * sNum;
					this.setColorRGB(tempVal,tempVal,tempVal);
				}
			}
		}
		
		public function set perceived (n:int):void {
			var sNum:Number;
			var hspObj:Object;
			hspObj = RGB_to_HSP(red,green,blue);
			
			// Confirm expected value ranges
			if (rangeCheck("Perceived Brightness",n,0,100))
			{
				sNum = (n == 0) ? 0 : (n /100);
				this.setColorHSP(hspObj.h,hspObj.s,sNum);
			}
		}
		
		public function get alpha ():Number {
			return this.alphaMultiplier;
		}		

		public function get magenta ():int {
			return (this.red <= this.blue) ? this.red : this.blue;				
		}
		
		public function get cyan ():int {
			return (this.green <= this.blue) ? this.green : this.blue;			
		}

		public function get yellow ():int {
			return (this.green <= this.red) ? this.green : this.red;
		}		
				
		public function get red ():int {
			return (this.color >> 16) & 0xFF;
		}

		public function get green ():int {
			return (this.color >> 8) & 0xFF;
		}

		public function get blue ():int {
			return this.color & 0xFF;
		}
		
		public function get hue ():int {
			var hsvObj:Object;
			hsvObj = this.RGB_to_HSV(red,green,blue);
			return hsvObj.h;
		}

		public function get saturation ():int {
			var hsvObj:Object;
			hsvObj = this.RGB_to_HSV(red,green,blue);
			return hsvObj.s * 100;
		}

		public function get value ():int {
			var hsvObj:Object;
			hsvObj = this.RGB_to_HSV(red,green,blue);
			return hsvObj.v * 100;
		}
		
		public function get perceived ():int {
			var hspObj:Object;
			hspObj = this.RGB_to_HSP(red,green,blue);
			return hspObj.P * 100;
		}

		public function CSSToRGB(inStr:String):Number {
			var pattern:RegExp;
			var tempStr:String = "";
			pattern = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/; // See: http://tinyurl.com/26bhmhl
		
			if (pattern.test(inStr))
			{
				tempStr = "0x";
				if (inStr.length == 7)
				{
					tempStr += inStr.substring(1);
				} else
				{
					var rStr:String;
					var gStr:String;
					var bStr:String;
					rStr = inStr.substr(1,1);
					gStr = inStr.substr(2,1);
					bStr = inStr.substr(3,1);
					tempStr += rStr + rStr + gStr + gStr + bStr + bStr;

				}
			}
			return (tempStr != "") ? Number(tempStr) : -1;
		}
		
		public function setRGB_CSS(inStr:String) {
			var tempNum:Number = this.CSSToRGB(inStr);

			this.color = (tempNum >= 0) ? tempNum : this.color;
		}
		
		public function setColorRGB (r:uint, g:int=0, b:int=0) {
			if (arguments.length == 1) {
				this.color = r;
			} else {
				this.color = r<<16 | g<<8 | b
			}
		}
		
		public function setColorHSV (h:uint, s:Number=0, v:Number=0) {
			var hsvObj:Object;
			hsvObj = HSV_to_RGB(h,s,v);
			this.setColorRGB(hsvObj.r,hsvObj.g,hsvObj.b);
		}
		
		public function setColorHSP (h:uint, s:Number=0, P:Number=0) {
			var hspObj:Object;
			hspObj = HSP_to_RGB(h,s,P);
			this.setColorRGB(hspObj.r,hspObj.g,hspObj.b);
		}
		
		override public function toString ():String {
			return toStringRGB();
		}

		public function getRGB_CSS(radix:int = 16):String
		{
			var s:String;
			var tempNF:NumberFormat;
			tempNF = new NumberFormat('00');
			s = " #" + 
				tempNF.formatUINT(this.red,radix) +
				tempNF.formatUINT(this.green,radix) +
				tempNF.formatUINT(this.red,radix);
			return s;
		}
		public function toStringRGB (radix:int = 10):String {
			var s:String;
			s = 
				" R:" + ((this.color >> 16)&0xFF).toString(radix).toUpperCase()
			+ 	" G:" + ((this.color >> 8)&0xFF).toString(radix).toUpperCase()
			+ 	" B:" + (this.color&0xFF).toString(radix).toUpperCase();

			return s;
		}
		
		public function toStringHSV():String {
			var hsvObj:Object;
			hsvObj = this.RGB_to_HSV(red,green,blue);
			var s:String = 
				" H:" + ((hsvObj.h).toString().toUpperCase()
			+	" S:" + (hsvObj.s).toString().toUpperCase()
			+	" V:" + (hsvObj.v).toString().toUpperCase());
			this._debugger.wTrace("the HSV " + this.HSV_to_RGB(hsvObj.h,hsvObj.s,hsvObj.v));

			return s;
		}
		
		public function toStringHSP():String {
			var hspObj:Object;
			hspObj = this.RGB_to_HSP(red,green,blue);
			var s:String = 
				" H:" + ((hspObj.h).toString().toUpperCase()
			+	" S:" + (hspObj.s).toString().toUpperCase()
			+	" P:" + (hspObj.P).toString().toUpperCase());
			this.HSP_to_RGB(hspObj.h,hspObj.s,hspObj.P);

			return s;
		}

		public function toStringRed (radix:int = 10):String {
			var tempStr:String;
			tempStr = ((this.color >> 16)&0xFF).toString(radix).toUpperCase();
			return ((tempStr == "0") && (radix == 16)) ? "00" : tempStr;
		}

		public function toStringGreen (radix:int = 10):String {
			var tempStr:String;
			tempStr = ((this.color >> 8)&0xFF).toString(radix).toUpperCase();
			return ((tempStr == "0") && (radix == 16)) ? "00" : tempStr;			
		}

		public function toStringBlue (radix:int = 10):String {
			var tempStr:String;
			tempStr = (this.color&0xFF).toString(radix).toUpperCase();
			return ((tempStr == "0") && (radix == 16)) ? "00" : tempStr;
		}

		/************************************************************************************************************************************
		**  PUBLIC
		************************************************************************************************************************************/

		/**
		*  Name:  getAffected
		*  Purpose:  returns an object taht 
		*  @param inDebugger	DebugUtil	The dubugger to use for trace, error and worning messages
		*/		
		public function getAffected(inColor:String):Object {
			var tempObj;
			tempObj = new Object();
			tempObj["g"] = this.green;				
			tempObj["b"] = this.blue;
			tempObj["r"] = this.red;
			tempObj["m"] = this.magenta;					
			tempObj["c"] = this.cyan;
			tempObj["ye"] = this.yellow;
			switch(inColor)
			{
				case "v":
				case "value":
				case "brightness":
				case "P":
				case "perceived":
				case "b":
				case "blue":
				case "r":
				case "red":
				case "g":
				case "green":
				case "m":
				case "magenta":
				case "c":
				case "cyan":
				case "ye":
				case "yellow":
					tempObj["h"] = this.hue;
					tempObj["s"] = this.saturation;					
				break;
				case "h":
				case "hue":				
					tempObj["s"] = this.saturation;
				break;
				case "s":
				case "saturation":
					tempObj["h"] = this.hue;				
				break;
				case "a":
				case "alpha":
					// Do nothing;
				break;
				default:
					// Do nothing;				
				break;
			}
			return tempObj;
		}
		
		/**
		*  Name:  smoothColorChange
		*  Purpose:  Manages a delayed transition from one color to another
		*  @param inDisplayObj	DisplayObject	The Display Object for which the color will be changed
		*  @param inPrevColor	ColorUtil		color to change from
		*  @param inNextColor	ColorUtil		color to change to
		*  @param delayMS	Number		Milliseconds for 
		*/
		public function smoothColorChange(inDisplayObj:DisplayObject,inPrevColor:Color,inNextColor:Color,delayMS:Number):void {
			var newTimer:Timer;
			newTimer = new Timer(delayMS / this.transitionSteps,this.transitionSteps);
			this.displayObj = inDisplayObj;
			this.prevColor = (inPrevColor == null) ? this : inPrevColor;
			this.nextColor = inNextColor;
			this.transitionStage = 0; 
			newTimer.addEventListener(TimerEvent.TIMER,updateColorTransition);
			newTimer.start();

		}
		
		/**
		*  Name:  setTransitionSteps
		*  Purpose:  Adjusts the speed of color tranistion
		*  @param inDisplayObj	DisplayObject	The Display Object for which the color will be changed
		*  @param inPrevColor	ColorUtil		color to change from
		*  @param inNextColor	ColorUtil		color to change to
		*  @param delayMS	Number		Milliseconds for 
		*/
		public function setTransitionSteps(inTransitionNum:Number=50):void {
			this.transitionSteps = inTransitionNum;
		}	
		
		/************************************************************************************************************************************
		**  Static Functions
		************************************************************************************************************************************/
		/**
		*  Name:  extractAlpha
		*  Purpose:  Returns the Alpha value from a ARGB
		*  @param inARGB	uint	The Display Object for which the color will be changed
		*  @param delayMS	uint		Milliseconds for 
		*/
		public static function extractAlpha(inARGB:uint):uint {
			return (inARGB >> 24 & 0xFF);
		}
		
		/**
		*  Name:  extractRed
		*  Purpose:  Returns the Red value from a ARGB
		*  @param inARGB	uint	The Display Object for which the color will be changed
		*  @param delayMS	uint		Milliseconds for 
		*/
		public static function extractRed(inARGB:uint):uint {
			return (inARGB >> 16 & 0xFF);
		}
		
		/**
		*  Name:  extractGreen
		*  Purpose:  Returns the Green value from a ARGB
		*  @param inARGB	uint	The Display Object for which the color will be changed
		*  @param delayMS	uint		Milliseconds for 
		*/
		public static function extractGreen(inARGB:uint):uint {
			return (inARGB >> 8 & 0xFF);
		}

		/**
		*  Name:  extractBlue
		*  Purpose:  Returns the Green value from a ARGB
		*  @param inARGB	uint	The Display Object for which the color will be changed
		*  @param delayMS	uint		Milliseconds for 
		*/
		public static function extractBlue(inARGB:uint):uint {
			return (inARGB & 0xFF);
		}

		/**
		*  Name:  stringARGB
		*  Purpose:  Returns the Green value from a ARGB
		*  @param inARGB	uint	The Display Object for which the color will be changed
		*  @param delayMS	uint		Milliseconds for 
		*/
		public static function stringARGB(inARGB:uint):String {
			var tempStr:String;
			tempStr = "\n";
			tempStr += "Alpha = " + extractAlpha(inARGB).toString() + "\n";
			tempStr += "Red = " + extractRed(inARGB).toString() + "\n";
			tempStr += "Green = " + extractGreen(inARGB).toString() + "\n";
			tempStr += "Blue = " + extractBlue(inARGB).toString() + "\n";
			return tempStr;
		}					
				
		
		/************************************************************************************************************************************
		**  Event Handlers
		************************************************************************************************************************************/

		// Performcolor operation
		public function updateColorTransition(e:TimerEvent):void {
			var tempColor:ColorTransform;
			var percentNum:Number;
			
			//  The percentNum is the amount the transition has completed;
			this.transitionStage += 100 / this.transitionSteps;
			percentNum = this.transitionStage / 100;
			tempColor = Color.interpolateTransform(this.prevColor,this.nextColor,percentNum);
			this.displayObj.transform.colorTransform = tempColor;
		}
	}
}