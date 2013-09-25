package org.wsimpson.interfaces

/*
** Title:	Glyph.as
** Purpose: Base class for all glyph UI objects
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
		
	// Style Definitions
	import org.wsimpson.styles.Style;
	
	public interface IGlyph
	{
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/
		/*
		*  @param inStr New Button Label
		*/
		function get rolloverStr():String;
		function set rolloverStr(inStr:String):void;

		/*
		*  @param inStr Glyph Unique Indentification Value
		*/
		function get id():String;
		function set id(inStr:String):void ;

		/*
		*  @param inStr New Button Label
		*/
		function get label():String		
		function set label(inStr:String):void;

		/*
		*  @param inStr New Button Style
		*/
		function get style():Style;
		function set style(inStyle:Style):void ;

		/*
		*  @return String 
		*  @param inStr New Button Label
		*/
		function get margin():String ;
		function set margin(inMargin:String):void ;

		/*
		*  Name:  	maxSize
		*  Purpose: Size and reposition the object so X percent shows.
		*
		*  @param inArr Array The max size available for this glyph
		*/
		function get maxSize():Array ;		
		function set maxSize(inArr:Array):void;
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		/**
		*  name:  makeAccessible
		*  @param inDesc	String	String describing the button
		*/		
        function makeAccessible(inDesc:String = "glyph"):void;
		
		function hideGlyph():void;

		function showGlyph():void;

		/*
		*  Name:  	refresh
		*  Purpose:  Updates the display
		*/
		function refresh():void

		/*
		*  Name:  	calculateArea
		*  Purpose: Determines the area occupied by the mask
		*
		*  @return Number Returns the total number of pixels used by the mask
		*/
 		function calculateArea():Number
		
		/*
		*  Name:  	calculatePercentArea
		*  Purpose: Determines the meter area occupied by the mask
		*
		*  @return Number Returns the percent of meter pixels occupied by the mask
		*/
 		function calculatePercentArea():Number;

		/*
		*  Name:  	assignMeters
		*  Purpose: Assign the values to the Meters.
		*  @note 	Expects 2 dimensional array where the rows contain two values the rank and the colorScale
		*  @param inArr Array Color Array and value for each of the meters
		*/
		function assignMeters(inArr:Array):void;

		/*
		*  Name:  	addGlyphListener
		*  Purpose: Captures the button click
		*  @param inFunc Function Callback Listener
		*/
		function addGlyphListener(inFunc:Function):void;
	}
}