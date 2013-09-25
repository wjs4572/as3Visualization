package org.wsimpson.ui

/*
** Title:	GlyphConst.as
** Purpose: Shared Constants used by the Glyph class, sublasses, and implementors of the IGlyph interface.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Constants
	import org.wsimpson.ui.MeterConst;
	
	public class GlyphConst extends MeterConst
	{
		// PUBLIC Constants
		public static const BUTTON_PATTERN
			= "^glyphButton";													// Pattern for button
		public static const METER_PATTERN
			= "^meter_\d*";														// Pattern for meters
		public static const METER_LABEL	= "meter_";								// Get Labels
		public static const STYLE_NAME = ".style_";								// Style labels
		public static const GLYPH_ID = "id";									// Indicates that the value is invalid		
		public static const PIXELS = "px";										// Indicates that the margin is in pixels rather than percentage	

		// Multidimensional Array
		public static const DATA_INDEX = MeterConst.DATA_INDEX;					// The field id of the data
		public static const DATA_DISPLAY_VALUE = MeterConst.DATA_DISPLAY_VALUE;	// The first value is the actual data
		public static const DATA_RAW_VALUE = MeterConst.DATA_RAW_VALUE;			// The first value is the actual data
		public static const DATA_RANK = MeterConst.DATA_RANK;					// Ranking implies ordered categories
		public static const DATA_PERCENTILE = MeterConst.DATA_PERCENTILE;		// Percentile used to calculate the ranking
		public static const DATA_COLOR = MeterConst.DATA_COLOR;					// The second array is the colors used for field ranking 0-9
		public static const DATA_DEFAULT_COLOR = MeterConst.DATA_DEFAULT_COLOR;	// The third value is the default color for the field
		public static const DATA_MAX_VALUE = MeterConst.DATA_MAX_VALUE;			// The fourth value is the maximum value allowed for the field
		public static const DATA_LABEL = MeterConst.DATA_LABEL;					// The label used for this field
		
		// Axis orientation and positioning values
		public static const HORIZONTAL_START:String = "start";					// The glyph horizontal start position
		public static const HORIZONTAL_END:String = "end";						// The glyph horizontal end position
		
		// HTML Fields
		public static const GLYPHS_ID = "{ID}";									// Field to replace
		public static const GLYPHS_MSG = "{MESSAGE}";							// Field to replace	
		public static const GLYPHS_FIELD_INDEX = "{INDEX}";						// Field to replace
		public static const GLYPHS_FIELD_NAME = "{FIELD_{INDEX}}";				// Field to replace
		public static const GLYPHS_FIELD_COLOR = "{STYLE_{INDEX}}";				// Field to replace
		public static const GLYPHS_FIELD_VALUE = "{VALUE_{INDEX}}";				// Field to replace
		public static const GLYPHS_FIELD_RANK = "{RANK_{INDEX}}";				// Field to replace		
    }
}