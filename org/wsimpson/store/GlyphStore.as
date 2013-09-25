package org.wsimpson.store

/*
** Title:	GlyphStore.as
** Purpose: Manages the core glyphs to save rendering time.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	// Glyph
	import org.wsimpson.ui.Glyph;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	public class GlyphStore
	{
	
		// Private Instance Variables required for Singleton Creation
		protected static var instance:GlyphStore = new GlyphStore();	// Tracks the instantiated class
		
		// Protected Instance Variables
		protected var _glyphArray:Array;									// Array of Glyph

		// Private Instance Variables
		private	var _debugger:DebugUtil;									// Output and diagnostic window		
		
		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		**		  http://www.munkiihouse.com/?page_id=2
		******************************************************************************************************/
		
		public function GlyphStore()
		{
			if (instance) 
			{
				throw new Error("Instantiation failed: Use GlyphStore.getInstance() instead of new.");
			} else
			{
				this._debugger = DebugUtil.getInstance();
				this._glyphArray = new Array();
			}
		}
		
		public static function getInstance():GlyphStore {
			return instance;
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
			return (this._glyphArray[inGlyphIndex]) ? this._glyphArray[inGlyphIndex] : null;
		}
		
		/**
		*  Name:  setGlyph
		*  Purpose:	Returns a Glyph
		*  @param inGlyph Glyph Glyph to store
		*  @param inGlyphIndex int The id of the glyph.
		*/
		public  function setGlyph(inGlyphIndex:int,inGlyph:Glyph):void {
			this._glyphArray[inGlyphIndex] = inGlyph;
		}
	}
}