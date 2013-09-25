package org.wsimpson.interfaces

/*
** Title:	IMeter.as
** Purpose: Interface class for all meter UI objects
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	public interface IMeter
	{
		
		/******************************************************************************************************
		**  PARAMETERS
		*******************************************************************************************************/
		/**
		*  Name:  	Maximum number of layovers defined in the glyph configuration
		*/
		function get max_value():Number;
		
		function set max_value(inMax:Number):void;
		
		/**
		*  Name:  	Indicates whether that rank should be used for percentage display
		*/
		function get useRank():Boolean;
		
		function set useRank(inRankBool:Boolean):void;
		
		/**
		*  Name:  	Indicates whether that value should be used for percentage display
		*/
		function get useValue():Boolean;
		
		function set useValue(inRankBool:Boolean):void;
		
		/******************************************************************************************************
		**  PUBLIC
		*******************************************************************************************************/
		
		// Hide the meter window
		function hideMeter():void ;

		// Hide the meter window
		function showMeter():void;

		/*
		*  Name:  	refresh
		*  Purpose:  Updates the display
		*/
		function refresh():void;

		/*
		*  Name:  	calculateArea
		*  Purpose: Determines the area occupied by the mask
		*
		*  @return Number Returns the total number of pixels used by the mask
		*/
		function calculateArea():Number;
		
		/*
		*  Name:  	calculatePercentArea
		*  Purpose: Determines the meter area occupied by the mask
		*
		*  @return Number Returns the percent of meter pixels occupied by the mask
		*/
		function calculatePercentArea():Number;
		
		/*
		*  Name:  	setDefaultColor
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inValue String Value The default color for the meter
		*/
		function setDefaultColor(inValue:String):void;

		/*
		*  Name:  	setColorArray
		*  Purpose: Assign a array of colors to the meter
		*
		*  @param inArray Array An array of colors
		*/
		function setColorArray(inArray:Array):void;
		
		/*
		*  Name:  	setPositionPercent
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inPercent Number The percent to move it.
		*/
		function setPositionPercent(inPercent:Number):void;
		
		/*
		*  Name:  	setRank
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inRank Number The rank to assign to move it.
		*/
		function setRank(inRank:Number):void;
		
		/*
		*  Name:  	setValue
		*  Purpose: Move the object so X percent shows.
		*
		*  @param inRank Number The rank to assign to move it.
		*/
		function setValue(inValue:Number):void;
		
		/*
		*  Name:  	assignValues
		*  Purpose: Defines the individual values used by the meter.
		*  @param inArr Array Array of value Objects.
		*/
		function assignValues(inArr:Array):void;

    }
}