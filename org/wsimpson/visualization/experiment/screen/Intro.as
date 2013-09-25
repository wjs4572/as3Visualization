package org.wsimpson.visualization.experiment.screen
/*
** Title:	Intro.as
** Purpose: Interactive for selecting color scales
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe UI
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize	

	// Style Definitions
	import org.wsimpson.styles.Style;	
	
	// Utitlies
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;
	import org.wsimpson.util.Positions;
	
	// UI Classes
	import org.wsimpson.ui.DisplayArea;
	import org.wsimpson.ui.screen.ExtendedScreen;	
	import org.wsimpson.ui.screen.Screen;

	// Visualization Application Classes
	import org.wsimpson.visualization.experiment.ScreenView;	
	
	public class Intro extends ExtendedScreen
	{
		// Protected Instance Variables
		protected var screen:XML;					// References the active stage
		protected var view:ScreenView;				// The View of MVC
		protected var textFields:Array;				// The textFields Created
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private var orientationStr:String;			// Supported orientations of the sliders		
		private var offsetX:uint;					// Creates the grid arrangement
        private var offsetY:uint;					// Creates the grid arrangement
        private var attrPos:Positions;				// Maintains orientation of elements to each other.	

		/**
		*  Name:  	Constructor
		*  Purpose:	Creates a screen from the imported XML
		*
		*	@param inView ScreenView From design pattern, MVC, the View for UI
		*	@param screenXML XML XML definition for the screen to display
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function Intro(inView:ScreenView,screenXML:XML)
		{
			super();
			this._debugger = DebugUtil.getInstance();
			
			// Set the stage
			this.view = inView;  // Need boundry object
			
			// Assign the display XML
			this.screen = screenXML;
			this.textFields = new Array();
			
			// Position manager
			this.attrPos = new Positions();
			this.offsetX = Number(this.screen.@x_offset);
			this.offsetY = Number(this.screen.@y_offset);
			this.orientationStr = Positions.ROW;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		private function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			// Initialize the display
			this.init();
		}
		
 		public override function leaveScreen():void
		{
			for (var targetStr:String in this.daObj)
			{
				this.daObj[targetStr].leaveStage();
				this.removeChild(this.daObj[targetStr]);
			}
		}
		 
		/******************************************************************************************************
		**  Protected
		******************************************************************************************************/

		// Returns the files contained here
		protected function init():void
		{
			var fileXMLList:XMLList;

			this.visible = true;
			
			fileXMLList = retrieveFiles();
			
			for each (var introFile:XML in fileXMLList)
			{
				var tempTF:TextField;	// TextField defined
				var defXML:XML; 		// definition for the display area
				var targetStr:String;	// Name of the target display area
				var tempDA:DisplayArea; // Display area 
				var contentStr:String;	// Content included by the file reference
				var tempStyle:Style; 	// Display area style
				
				// Create Textfield
				tempStyle = this.view.model.retrieveStyle(introFile.@style);
				contentStr = StringUtil.replaceTabs(this.view.model.retrieveFile(introFile.toString()).toString());
				tempTF = this.addTextField(contentStr,tempStyle);
				this.fileArr.push(tempTF);
				
				this.attrPos.addElement(tempTF,this.orientationStr,this.offsetX,this.offsetY);
				if ((introFile.@target != null) && (this.daObj[introFile.@target.toString()] == null))
				{
					// Target Display area
					targetStr = introFile.@target.toString();
					defXML = this.view.model.retrieveDef(targetStr);
					tempDA = new DisplayArea(defXML,tempTF.styleSheet.getStyle(targetStr.toLowerCase()),introFile.@desc.toString());
					this.daObj[targetStr] = tempDA;
					tempDA.showDisplayArea();
					this.addChild(tempDA);
					tempTF.width = this.daObj[targetStr].display_width();
					this.textFields.push(tempTF);
					tempDA.addDisplayObject(tempTF);
				} else if (introFile.@target == null)
				{
					throw new Error("Intro Screen Disply failed: Requires target display object definition");
				}
			}
			this.attrPos.positionElements();
			this.view.fadeInScreen();
		}

		/******************************************************************************************************
		**  Private
		******************************************************************************************************/
		
		// Returns the files contained here
		private function retrieveFiles():XMLList
		{
			return this.screen..file;
		}
		
	}
}