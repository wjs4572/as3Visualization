package org.wsimpson.ui.datagrid

/*
** Title:	ColRenderer
** Purpose: Manages the basic formatting
** Author:  William Simpson
** Basic Premise illustrated here:  http://blogs.adobe.com/pdehaan/2007/06/alternating_background_colors.html
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
   import fl.controls.listClasses.CellRenderer;
   import fl.controls.listClasses.ICellRenderer;

	// Utilities
	import org.wsimpson.util.DebugUtil;

	public class ColRenderer extends CellRenderer implements ICellRenderer 
	{
		
		// Private Instance Variables
        private var _debugger:DebugUtil;			// Creates trace statements both in debug window and output window
 		
		// Constructor
		public function ColRenderer()
		{
			super();
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		
        public static function getStyleDefinition():Object {
            return CellRenderer.getStyleDefinition();
        }

        override protected function drawBackground():void {
		    if (_listData.column % 2 == 0) {
                setStyle("upSkin", CellRenderer_upSkin_LightGray);
            } else {
                setStyle("upSkin", CellRenderer_upSkin_DarkGray);
            }
            super.drawBackground();
        }
		
    }
}