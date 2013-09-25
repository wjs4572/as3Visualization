package org.wsimpson.visualization.experiment.button

/*
** Title:	Glyph.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.ui.ButtonBase;
	
	// Adobe Classes
	import flash.display.MovieClip;
	
	public class Glyph extends ButtonBase
	{
			
		// Private Instance Variables
        private var _debugger:DebugUtil;			// Creates trace statements both in debug window and output window
		private var default_label_y:Number;			// Retain for flipping
		private var default_label_offset_y:Number;	// Retain for flipping
		

		// Constructor
		public function Glyph()
		{
			super();
			this._debugger = DebugUtil.getInstance();
			
			this.default_label_offset_y = 4;
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/		
		/******************************************************************************************************
		**  Paramters
		******************************************************************************************************/
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
    }
}