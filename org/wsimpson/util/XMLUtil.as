package org.wsimpson.util

/*
** Title:	XMLUtil.as
** Purpose: CXML Utility class
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// UI Components
	import org.wsimpson.util.DebugUtil;
		
	public class XMLUtil
	{
		// Private Instance Variables
        private var _debugger:DebugUtil;
		
		// Constructor
		public function XMLUtil()
		{
			//////this._debugger = DebugUtil.getInstance();
		}
		/******************************************************************************************************
		**  Public Statis Functions
		******************************************************************************************************/
		/**
		*  Name:  	hasAttribute
		*  Purpose:	Confirm existence of a particular attribute
		*  @param 	inXML	XML	Note to check for attributes
		*  @param 	inStr	String	Name of attribute being looked for
		*  @return 	Boolean	Attribute exists
		*/
		public static function hasAttribute(inXML:XML,inStr:String):Boolean
		{
			return (inXML.attribute(inStr).length() > 0);
		}		

    }
}