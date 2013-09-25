package org.wsimpson.visualization.experiment.button

/*
** Title:	Rectangle.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.ui.ButtonBase;
	import org.wsimpson.ui.transforms.Orientation;
	
	// Adobe Classes
	import flash.display.MovieClip;
	
	public class Rectangle extends ButtonBase
	{
			
		// Private Instance Variables
        private var _debugger:DebugUtil;			// Creates trace statements both in debug window and output window
        private var flippedBool:Boolean;			// Creates trace statements both in debug window and output window
		private var default_label_y:Number;			// Retain for flipping
		private var default_label_offset_y:Number;	// Retain for flipping
		

		// Constructor
		public function Rectangle()
		{
			super();
			this._debugger = DebugUtil.getInstance();
			
			flippedBool = false;
			this.default_label_offset_y = 4;
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		
		/**
		*  Name:  	  flipHorizontal
		*  Purpose:  Reorients the MovieClip rotationally 180 degrees both horizontally and vertically
		*/		
		public function flipHorizontal():void {

			this.gotoAndStop(BUTTON_UP);

			Orientation.flipHorizontal(this);
			Orientation.flipHorizontal(this["labelStr"]);
			if (!flippedBool)
			{
				default_label_y = this["labelStr"].y;
				this["labelStr"].y -= this.default_label_offset_y;
			} else
			{
				this["labelStr"].y = default_label_y;
			}
			this.flippedBool != this.flippedBool;			
		}

		
		/******************************************************************************************************
		**  Paramters
		******************************************************************************************************/
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
    }
}