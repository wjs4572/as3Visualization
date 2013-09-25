package org.wsimpson.visualization.experiment.infoglyph.meter

/*
** Title:	Engine.as
** Purpose: Specific Type of Meter Class dependent on library shapes
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// UI
	import org.wsimpson.ui.Meter;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class Engine extends Meter
	{
		
		// Constructor
		public function Engine()
		{
			super();
			super.cell_mask = this.meter_mask;
			super.mask_outline = this.outline;
		}

		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
	}
}