package org.wsimpson.ui

/*
** Title:	MeterConst.as
** Purpose: Shared Constants used by the Meter class, sublasses, and implementors of the IMeter interface.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import org.wsimpson.ui.Resizable;
	
	public class MeterConst extends Resizable
	{

		// Multidimensional Array
		public static const DATA_INDEX = 0;			// The field id of the data		
		public static const DATA_DISPLAY_VALUE = 1;	// The first value is formated data
		public static const DATA_RAW_VALUE = 2;		// The first value is the actual data
		public static const DATA_RANK = 3;			// Ranking implies ordered categories
		public static const DATA_PERCENTILE = 4;	// The second array is the colors used for field ranking 0-9
		public static const DATA_COLOR = 5;			// The second array is the colors used for field ranking 0-9
		public static const DATA_DEFAULT_COLOR = 6;	// The third value is the default color for the field
		public static const DATA_MAX_VALUE = 7;		// The fourth value is the maximum value allowed for the field
		public static const DATA_LABEL = 8;			// The label to display for the field

		// Initial Color
		public static const CELL_DEFAULT = "#f00";	// The initial color of all meters
  }
}