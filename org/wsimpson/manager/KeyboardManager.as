package org.wsimpson.manager

/*
** Title:	KeyboardManager.as
** Purpose: 	Class used to maintain and listen for a list of keyboard shortcuts and their associated events.  Dispatching the associated event when it is encountered.
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
**---------------------------------------------------------------------------------------------------
**   Note:  	Any of the keys; control, alt or shift, start a new sting listening task
** 		In addition, if an unexpected key is struck the string is reset
**---------------------------------------------------------------------------------------------------
*/

{
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.events.KeyboardShortcutEvent;
	import org.wsimpson.interfaces.IKeyboardInputHandler;
	import org.wsimpson.listener.KeyboardListener;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;

	public class KeyboardManager  extends EventDispatcher implements org.wsimpson.interfaces.IKeyboardInputHandler
	{
		// Public Instance Variables
		public static var ALT_KEY:String = "_ALT_";				// A alt value is present
		public static var CTRL_KEY:String = "_CTRL_";			// A control value is present
		public static var SHIFT_KEY:String = "_SHIFT_";			// A shift value is present
		public static var NO_KEY:String = "_NONE_";				// no modifier key is present
		public static var SHORTCUT_ANTI_PATTER:RegExp = /!\W/;  // Matches "_" followed a word characterss followd by "_"
		
		// Private Instance Variables
		private	var _debugger:DebugUtil;			// Output and diagnostic window
		private	var keyListener:KeyboardListener;	// Class managing keyboard events
		private	var appStage:Object;				// References the active stage
		private	var inAlt:Boolean;					// Currrent String started with alt kkey
		private	var inCTRL:Object;					// Currrent String started with control key
		private	var inShift:Object;					// Currrent String started with shift key
		private	var listenList:Object;				// Two dimensional Associative array of strings listened for
		private	var listenObj:Object;				// Associative array containing strings for a specific key
		private	var listStr:String;					// Active lhortcut modifiers (keyStr)
		private	var indexStr:String;				// Active lhortcut modifiers
		
		// Constructor
		public function KeyboardManager(target:Object)
		{
			this.appStage = target;
			this.keyListener = new KeyboardListener(this,target);
			this._debugger = this.appStage.debugger;
			this.listenList = new Object();
			this.listStr = "";
			this.indexStr = "";
		}

		/**
		*  Name:  listenFor
		*  Purpose:  Adds to the list of keyboard shortcuts being listened for.
		*  @param inString	String	Keyboard shortcut to listen for
		*  @param inType		String	Event type to dispatch upon detectino
		*/
		public function listenFor(inString:String,inType:String):void
		{
			this._debugger.functionTrace("KeyboardManager.listenFor " + inString);
			var keyStr:String;
			var tempStr:String;

			keyStr = createKeyString(inString);
			tempStr = this.cleanString(inString);
			this.listenList[keyStr] = new Object();
			this.listenList[keyStr][tempStr] = inType;
		}

		public function printShortcuts():void
		{
			this._debugger.functionTrace("KeyboardManager.printShortcuts ");
			this._debugger.printTree(this.listenList);
		}
		
		public function keyHandler(event:KeyboardEvent):void
		{
			this._debugger.functionTrace("KeyboardManager.keyHandler ");
			var charStr:String;				// Character Received
			var typeStr:String;				// Type of event to dispatch 
			var boolShortCutChar:Boolean; 	// Indicates whether the keyCode matches a legal character for the shortcut
			var boolModifier:Boolean;  		// Indicates keyCode reported is a modifier
			
			if (event.type == KeyboardEvent.KEY_DOWN)
			{
				boolModifier = ((event.keyCode == 16) || (event.keyCode == 17) || (event.keyCode == 18));
	
				charStr = String.fromCharCode(event.charCode);
				boolShortCutChar = ((charStr.search(SHORTCUT_ANTI_PATTER) == -1) && !boolModifier);
				this.indexStr = (boolShortCutChar) ? (this.indexStr + charStr) : "";
				
				// If shortcut character check for event type
				typeStr = (boolShortCutChar) ? this.getKeyEvent(event) : "";

				// If found, dispatch the event
				if ((typeStr != "") && (typeStr != null))
				{
					dispatchEvent(new KeyboardShortcutEvent(typeStr));
				}
			}
		} // onKeyDown  

		
		/************************************************************************************************************************************
		**  PRIVATE
		************************************************************************************************************************************/

		// Get Event Type to from list
		private function getKeyEvent(event:KeyboardEvent):String
		{
			var typeStr:String;
			
			// Determine shortcut list to used based on modifier characters
			this.listStr = this.buildKeyString(event.altKey,event.ctrlKey,event.shiftKey);

			if (this.listenList[this.listStr] != undefined)
			{
				typeStr = (this.listenList[this.listStr][this.indexStr] != undefined ) ? this.listenList[this.listStr][this.indexStr] : ""; 
			}
			return typeStr;
		}
		
	
		// Removes string constants from the search string
		private function cleanString(inString:String):String
		{
			this._debugger.functionTrace("KeyboardManager.cleanString ");

			var modifierPattern:RegExp;
			modifierPattern = /^_\w+_/g;  // Matches "_" followed a word characterss followd by "_"
			
			return inString.replace(modifierPattern,"");
		}
		
		// Find the modifier keys used
		private function createKeyString(inString:String):String
		{
			this._debugger.functionTrace("KeyboardManager.createKeyString ");
			
			var modifierKey_Alt:Boolean;	// If true, indicates Alt key is a required modifier
			var modifierKey_Ctrl:Boolean;	// If true, inidates the Control key is a required modifier
			var modifierKey_Shift:Boolean;	// If true, indicates the Shift key is a required modifier

			// Identify required modifiers
			modifierKey_Alt = (inString.indexOf(ALT_KEY) >= 0);
			modifierKey_Ctrl = (inString.indexOf(CTRL_KEY) >= 0);
			modifierKey_Shift = (inString.indexOf(SHIFT_KEY) >= 0);

			return buildKeyString(modifierKey_Alt, modifierKey_Ctrl, modifierKey_Shift);
		}
		
		// Use Booleans to build the string
		private function buildKeyString(inModifierKey_Alt:Boolean, inModifierKey_Ctrl:Boolean, inModifierKey_Shift:Boolean):String
		{
			var keyStr:String;
			
			// Create string index
			keyStr = (inModifierKey_Ctrl) ? CTRL_KEY : "";
			keyStr += (inModifierKey_Alt) ? ALT_KEY : "";
			keyStr += (inModifierKey_Shift) ? SHIFT_KEY : "";
			keyStr = (keyStr == "") ? NO_KEY : keyStr;
			
			return keyStr;
		}
	}
}