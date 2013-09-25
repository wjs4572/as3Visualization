package org.wsimpson.visualization.experiment
/**
* @name		ScreenManager.as
* Purpose	Manages access to the screens in a display file
* @author	William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Random Number Generator
	import com.gskinner.utils.Rndm;
	
	// Debugging
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.XMLUtil;
	
	// Enumeration
	import org.wsimpson.store.OrderStore;
	
	// Data Sources
	import org.wsimpson.visualization.experiment.ScreenModel;
	
	public class ScreenManager
	{
		// Static Error codes
		public static const FILE_NAME = "{SCREEN_DEF}";				// Requires substitution with the name of the file
		public static const ATTR_UID = "UID";						// Requires substitution with the name of the file
		public static const ATTR_RAND = "rand";						// Requires substitution with the name of the file
		public static const ATTR_SCREENS_UID = "screens_uid";		// Requires substitution with the name of the file
		public static const ATTR_ID = "id";							// Requires substitution with the name of the file
	
		// Instance Variables
		private	var _debugger:DebugUtil;							// Output and diagnostic window
		private	var displayScreens:XML;								// Imports XML Files
		private	var screenArr:Array;								// Imports XML Files
		private	var currentScreen:Number;							// Screen to show	
		private	var screenCount:Number;								// Screen to show
		private	var randomizer:Rndm;								// Random Number generator to randomize screen display
		private	var randSeed:Number;								// Seed the randomizer
		private	var randomBool:Boolean;								// Indicates whether the ordering is random
		private	var timeStamp:Date;									// TimeStamp of this load
		private var fileNamePattern:RegExp;							// Regular Expression for the content pattern		

		public function ScreenManager(inFile:XML)
		{
			this._debugger = DebugUtil.getInstance();
			this.displayScreens = inFile;
			
			// Get Random Number Generator Instance
			this.timeStamp = new Date();
			this.randomizer = Rndm.instance;
			this.randSeed = (Math.random() * (this.timeStamp.getMilliseconds()*this.timeStamp.getMilliseconds())) % 100;		
			this.randomizer.seed = this.randSeed;
			
			// Array of Screens to track their presentation
			this.screenArr = new Array();
			this.createScreenArr();
			
			// Randomize Screens if selected
			this.radomizeScreens();
			
			// Assign Screen reference formatting
			this.currentScreen = 0;
			
			// Substitution Pattern
			this.fileNamePattern = new RegExp(FILE_NAME);
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*	Returns either the XML for the current screen or XML for an errormessage
		*/
		public function getCurrentScreen():XML
		{
			var idStr:String;
			var uidStr:String;
			var tempList:XMLList;
			var tempBool:Boolean;
			var tempXML:XML;
			
			idStr = this.screenArr[this.currentScreen].id;
			uidStr = this.displayScreens.@UID + "_" + idStr;
			
			// Get Screen
			tempList = this.displayScreens..screen.(@index == idStr);
			tempBool = (tempList.length() == 1);
			
			// Create UID for individual screens based on the file's UID
			if (tempBool)
			{
				tempList.@[ATTR_UID] = uidStr;
			}
			return 	(tempBool) ? 	
					new XML(tempList.toString()) : 
					this.getErrorScreen(ScreenModel.DUPLICATE_SCREEN_IDS);
		}

		/**
		*	Updates current screen
		*/
		public function jumpToScreen(inNumber:Number):void
		{
			this.currentScreen = inNumber;
		}

		/**
		*	Confirm presence of Screen
		*/
		public function screenExists(inNumber:Number):Boolean
		{
			// var tempBool:Boolean;
			// tempBool = false;
			// if (0 <= inNumber <= this.screenArr.length){
				// tempBool = (this.screenArr[inNumber] != null);
			// }
			// return tempBool;
			return this.screenArr.hasOwnProperty(inNumber.toString());
		}		
		
		/**
		*	Updates current screen
		*/
		public function jumpToLastScreen():void
		{
			this.jumpToScreen(this.screenArr.length - 1);
		}

		// Indicates the presence of a previous screen
		public function hasPrevScreen():Boolean
		{
			return (this.currentScreen > 0);
		}

		// Inidcates the presence of a next screen
		public function hasNextScreen():Boolean
		{
			return (this.currentScreen <  (this.screenArr.length - 1));
		}
		
		// Should only return one element
		public function prevScreen():XML
		{
			this.currentScreen--;
			return getCurrentScreen();
		}
		
		// Should only return one element
		public function nextScreen():XML
		{
			this.currentScreen++;
			return getCurrentScreen();
		}
		
		/******************************************************************************************************
		** PRIVATE - Load Resources
		******************************************************************************************************/	
		
		private function getErrorScreen(inNum:Number):XML
		{
			var tempList:XML;
			var tempStr:String;
			tempList = (ScreenModel.getInstance()).retrieveErrorScreen(inNum);
			tempStr = tempList.toString();

			// Replace with file name
			tempStr.replace(this.fileNamePattern,"Must have file name");
			return new XML(tempStr);
		}
		
		// Should only return one element
		private function radomizeScreens():void
		{
			this.randomBool = (this.displayScreens.@randBool.toString() == "true");
			if (this.randomBool)
			{
				this.screenArr.sortOn("rand");		
			}	else
			{
				this.screenArr.sortOn("id");			
			}
		}

		// Should only return one element
		private function createScreenArr():void
		{
			var tempXMLList:XMLList;
			var tempObjStore:OrderStore;
			var tempUID:String;
			tempObjStore = new OrderStore();
			tempUID = this.screensUID();
			
			tempXMLList = this.retrieveScreens();
			this.screenCount = tempXMLList.length();
			for each (var screenNode:XML in tempXMLList)
			{
				tempObjStore.newObj();
				tempObjStore.addNameValue(ATTR_ID,screenNode.@index);
				tempObjStore.addNameValue(ATTR_SCREENS_UID,tempUID);
				tempObjStore.addNameValue(ATTR_RAND,this.randomizer.random());
				this.screenArr.push(tempObjStore.getObj());
			}
		}
		
		// Get the file UID
		private function screensUID():String
		{
			return this.displayScreens.@UID;
		}
		
		private function retrieveScreens():XMLList
		{
			return this.displayScreens..screen;
		}
		
		// Returns the total count of display screens
		private function countScreens():int
		{
			return this.screenCount;
		}
	}
}