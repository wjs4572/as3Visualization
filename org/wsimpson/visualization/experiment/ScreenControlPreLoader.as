package org.wsimpson.visualization.experiment
/*
** Title:	ScreenControlPreLoader.as
** Purpose: Interactive for selecting color scales
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	import org.wsimpson.interfaces.IPreLoader;
	import org.wsimpson.loaders.PreLoader;	
	import org.wsimpson.visualization.experiment.ScreenControl;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.Font;
	
	public class ScreenControlPreLoader extends PreLoader implements IPreLoader
	{
		private	var controller:ScreenControl;	// The controller for the specific application
		
		// Constructor
		function ScreenControlPreLoader()
		{
			super();
		}
		
		/*******************************************************************************************************
		**  Public classes to override
		********************************************************************************************************/
		override public function progressBar():void
		{
			super.progressBar();
		}
		
		override public function init():void
		{
			super.init();
			Font.registerFont(Arial_Unicode_MS);
			this.x = this.y = 0;
			this.opaqueBackground = 0x000000; 
			controller = new ScreenControl(this);
			
			// Load Framework
            addChild(controller);
		}

	}
}