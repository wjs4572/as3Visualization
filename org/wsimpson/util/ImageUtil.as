package org.wsimpson.util

/*
** Title:	ImageUtil.as
** Purpose:	Misc image functions  Utility class
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Classes
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;	

	// UI Components
	import org.wsimpson.util.ColorUtil;
	import org.wsimpson.util.DebugUtil;
		
	public class ImageUtil
	{
		// Private Constant Instance Values
		private static const PIXEL_BUFFER:uint = 1;
		
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function ImageUtil()
		{
			this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Static Functions
		******************************************************************************************************/
		/**
		*  Name:  	calcImageArea
		*  Purpose:	Return the passed string as double quoted.
		*  @param 	target	DisplayObject DisplayObject for which the area will be calculated
		*  @return 	Number	Calculated area
		* 
		*  @see http://stackoverflow.com/questions/1934674/actionscript-3-0-how-to-access-a-shapes-segments
		*  @see http://www.adobe.com/devnet/flash/articles/saving_flash_graphics.html
		*/
		public static function calcImageArea(targetDO:DisplayObject):Number
		{
			var relative:DisplayObject;
			var bmp:BitmapData
			var rect:Rectangle;
			var area:uint;
			var num_pixels:uint;
			
			relative = targetDO.parent;
			area = 0;

			// get target bounding rectangle
			rect = targetDO.getBounds(relative);
			
			// capture within bounding rectangle; add a 1-pixel buffer around the perimeter to ensure that all anti-aliasing is included
			bmp = new BitmapData(rect.width + PIXEL_BUFFER * 2, rect.height + PIXEL_BUFFER * 2,true,0);
			
			// capture the target into bitmapData
			//bmp.draw(relative, new Matrix(1, 0, 0, 1, -rect.x + PIXEL_BUFFER, -rect.y + PIXEL_BUFFER));
			bmp.draw(relative);
			
			num_pixels = bmp.width*bmp.height;
			
			for (var i:uint = 0; i<num_pixels; i++) {

				var pixelARGB:uint;

				pixelARGB = bmp.getPixel32(i%bmp.width, Math.floor(i/bmp.height));

				if (ColorUtil.extractAlpha(pixelARGB) > 0)
				{
					area++;
				}
			}
			return area;
		}
		
		
		// See http://tinyurl.com/28bjrvk
        public static function duplicateImage(original:Bitmap):Bitmap {
            var tempBitmap:BitmapData;
			// Create bitmap data with transparent background
            tempBitmap = new BitmapData(original.width,original.height,true,0x00FFFFFF);
			// Draw the data to a new bitmap;
            tempBitmap.draw(original.bitmapData.clone(),new Matrix());
			
            return new Bitmap(tempBitmap);
        }

    }
}