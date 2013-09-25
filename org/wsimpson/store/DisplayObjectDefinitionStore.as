package org.wsimpson.store

/*
** Title:	StyleStore.as
** Purpose: A Repository class for managing the textformats used within a project.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	
	// ActionScript Tools
	import org.wsimpson.styles.Style;
   
	public final class StyleStore {
		// Private Instance Variables required for Singleton Creation
		private static var instance:StyleStore = new StyleStore();	// Tracks the instantiated class
		
		// Private Instance Variables
		private var styleObj:Object;									// An Associative array of StyleSheets

		/******************************************************************************************************
		**  SINGLETON CONSTUCTOR METHODS
		**	This started as a modified version of the Singleton Design Pattern
		** 		  http://www.gskinner.com/blog/archives/2006/07/as3_singletons.html
		**  Found issues so went with:
		**  	  http://life.neophi.com/danielr/2006/10/singleton_pattern_in_as3.html
		******************************************************************************************************/
		
		public function StyleStore() {
			if (instance) 
			{
				throw new Error("Instantiation failed: Use StyleStore.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():StyleStore {
			return instance;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		public  function listStyles():void {
			for (var tempName:String in this.styleObj)
			{
				trace("Style ID:  " + tempName);
				this.styleObj[tempName].listFiles();				
				this.styleObj[tempName].fileContents();				
			}
		}
		
		/**
		*  name:  getCustomStyle
		*  @param inStyleName	String	Name of the Style
		*  @return Style Previously created Style
		*/
		public function getCustomStyle(inStyleName):Style
		{
			return this.styleObj[inStyleName];
		}

		/**
		*  name:  setCustomStyle
		*  @param inStyleName	String name of the Style
		*  @param inStyle Style Previously created Style
		*/
		public function setCustomStyle(inStyleName, inStyle:Style):void
		{
			this.styleObj = (this.styleObj == null) ? new Object() : this.styleObj;
			this.styleObj[inStyleName] = inStyle;
		}

		/**
		*  name:  hasStyle
		*  @param inStyleName	String name of the Style
		*/
		public function hasStyle(inStyleName):Boolean
		{
			return (this.styleObj[inStyleName] != null);
		}
		
		/**
		*  name:  addStyle
		*  @param inStyleName	String name of the Style
		*/
		public function addStyle(inStyleName):void
		{
			var tempStyle:Style;
			this.styleObj = (this.styleObj == null) ? new Object() : this.styleObj;
			if (this.styleObj[inStyleName] != null) 
			{
				throw new Error("Add Style Failure:  Attempt to add existing object.");
			} else 
			{
				tempStyle = new Style();
				this.styleObj[inStyleName] = tempStyle;
			}
		}
		
		/**
		*  name:  setStyleCSS
		*  @param inStyleName	String	Name of the Style
		*  @param inCSS String CSS File
		*/
		public function setStyleCSS(inStyleName, inCSS:String):void
		{
			var tempStyle:Style;
			tempStyle = new Style();
			tempStyle.parseCSS(inCSS);
			this.styleObj = (this.styleObj == null) ? new Object() : this.styleObj;			
			this.styleObj[inStyleName] = tempStyle;
		}

	}
}