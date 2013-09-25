package org.wsimpson.visualization.experiment.infoglyph.meter

/*
** Title:	Jet.as
** Purpose: Specific Type of Meter Class dependent on library shapes
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// UI
	import org.wsimpson.ui.Meter;
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class Jet extends Meter
	{
		
		// Constructor
		public function Jet()
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