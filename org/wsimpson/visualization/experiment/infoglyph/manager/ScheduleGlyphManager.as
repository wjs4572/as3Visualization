package org.wsimpson.visualization.experiment.infoglyph.manager

/*
** Title:	ScheduleGlyphManager.as
** Purpose: Manages the core glyphs to save rendering time.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	// Glyph Manager
	import org.wsimpson.manager.GlyphManager;
	
	//ScheduleGlyph
	import org.wsimpson.ui.Glyph;
	import org.wsimpson.visualization.experiment.infoglyph.ScheduleGlyph;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class ScheduleGlyphManager extends GlyphManager
	{
		// Private Instance Variables
		private	var _debugger:DebugUtil;									// Output and diagnostic window		
		private var _glyphDef:XML;		// Definition

		public function ScheduleGlyphManager()
		{
			super();
			this._debugger = DebugUtil.getInstance();
		}

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/
		/**
		*  Name:  setDef
		*  Purpose:	Defines the Glyph parameters
		*  @param inXML XML	Defines the ScheduleGlyph orientation
		*/
		public function setDef(inXML:XML):void
		{
			this._glyphDef = inXML;
		}
		
		/**
		*  Name:  getGlyph
		*  Purpose:	Returns a Glyph
		*  @param inGlyphIndex int The id of the glyph.
		*  @return 	Glyph	The retrieved Glyph
		*/
		public override function getGlyph(inGlyphIndex:int):Glyph {
			var tempGlyph:Glyph;
			tempGlyph = this._store.getGlyph(inGlyphIndex);
			if (tempGlyph == null) 
			{
				tempGlyph = new ScheduleGlyph(this._glyphDef);
				this._store.setGlyph(inGlyphIndex,tempGlyph);
			}
			return tempGlyph;
		}
	}
}