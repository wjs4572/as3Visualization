package org.wsimpson.manager

/*
** Title:	GlyphManager.as
** Purpose: Manages the core glyphs to save rendering time.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	// Glyph
	import org.wsimpson.ui.Glyph;
	
	// Glyph Store
	import org.wsimpson.store.GlyphStore

	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class GlyphManager
	{
		// Private Instance Variables
		private	var _debugger:DebugUtil;	// Output and diagnostic window	
		protected var _store:GlyphStore;	// Glyph Store
		
		public function GlyphManager()
		{
			this._store = GlyphStore.getInstance();
		}

		/******************************************************************************************************
		**  Public
		******************************************************************************************************/
		
		/**
		*  Name:  getGlyph
		*  Purpose:	Returns a Glyph
		*  @param inGlyphIndex int The id of the glyph.
		*  @return 	Glyph	The retrieved Glyph
		*/
		public  function getGlyph(inGlyphIndex:int):Glyph {
			var tempGlyph:Glyph;
			tempGlyph = this._store.getGlyph(inGlyphIndex);
			if (tempGlyph == null) 
			{
				tempGlyph = new Glyph();
				this._store.setGlyph(inGlyphIndex,tempGlyph);
			}
			return tempGlyph;
		}
	}
}