package org.wsimpson.errors
/*
** Title:	RangeError
** Purpose: Error indicating that a value was outside the expected range
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	public class RangeError extends Error
	{
		// Constructor
		function RangeError(message:String = "Value received outside of expected range")
		{
			super(message);
		}

	}
}