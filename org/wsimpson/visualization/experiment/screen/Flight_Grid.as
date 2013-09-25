package org.wsimpson.visualization.experiment.screen
/*
** Title:	Flight_Grid.as
** Purpose: Interactive for selecting data rows indicating flight values
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Utitlies
	import org.wsimpson.util.DebugUtil;
	
	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.screen.GlyphGrid;
	// import org.wsimpson.visualization.experiment.infoglyph.GlyphModel;
	// import org.wsimpson.visualization.experiment.ScreenModel;	
	import org.wsimpson.visualization.experiment.ScreenView;
	
	public class Flight_Grid extends GlyphGrid
	{
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window
		
		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a screen from the imported XML
		*
		*	@param inView ScreenView From design pattern, MVC, the View for UI
		*	@param screenXML XML XML definition for the screen to display
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function Flight_Grid(inView:ScreenView,screenXML:XML)
		{
			super(inView,screenXML);
			this._debugger = DebugUtil.getInstance();
	

		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
		 
		/******************************************************************************************************
		**  Private
		******************************************************************************************************/

	}			
}