package org.wsimpson.util
{
	// Adobe Classes
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.describeType;
	
	// Interfaces
	import org.wsimpson.interfaces.IDebugUtil;
	
	// Constants
	import org.wsimpson.util.DebugUtilConst;
	
	// Library items
	import org.wsimpson.ui.DebugWindow;
	
	public final class DebugUtil extends MovieClip implements IDebugUtil{
		private static var _instance:DebugUtil = new DebugUtil();

		// Private Constants
		public static const DEBUG_PREFIX = "	\\";	// printTree listing

		// Private Instance Variables
		private	var debug_String:String;							// Holds trace history
		private	var debug_State:String;								// Current debug state
		private	var prefixModifier:String;							// printTree
		private	var boolDebugTrace:Boolean;							// DebugState
		private	var boolDebugEventTrace:Boolean;					// DebugState
		private	var boolDebugFunctionTrace:Boolean;					// DebugState
		private	var boolDebugTimeStamped:Boolean;					// DebugState
		private	var debugWindow:DebugWindow;						// printTree */

		public static function getInstance():DebugUtil {
			return _instance;
		}
		
		public function DebugUtil() {
			if (_instance) 
			{
				throw new Error("Error: Instantiation failed: Use TextStyle.getInstance() instead of new.");
			}
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
	
		/**
		*  Name:  initialize
		*  Purpose:  Sets the display format for the debugger window text
		*  @param passed_txt_format	TextFormat	Assigns text formatting
		*/
		public function initialize():void {	
					
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			this.debugWindow = new DebugWindow();
							
			this.visible = false;
		}
		
		/**
		*  Name:  setforat
		*  Purpose:  Sets the display format for the debugger window text
		*  @param passed_txt_format	TextFormat	Assigns text formatting
		*/
		public function setformat(passed_txt_format:TextFormat):void {
			this.debugWindow.setformat(passed_txt_format);
		}

		/**
		*  Name:  printTree
		*  Purpose:  Outputs the contents of an object tree
		*  @param inObj		Object	The object to parse
		*  @param inPrefix	String	A prefix for the level
		*  @param inLevels	Number	The number of levels to parse to
		*/		
		public function printTree(inObj:Object, inLevels:Number = 3, inPrefix:String = ""):void {
			var tempLevel:Number;
			var tempPrefix:String;
			
			tempPrefix = "";
			
			this.prefixModifier = (inPrefix != "") ? inPrefix : DebugUtil.DEBUG_PREFIX;
			if (inLevels != 0)
			{
				this.wTrace(inPrefix + inObj.toString());
				tempPrefix = inPrefix + this.prefixModifier;
				tempLevel = inLevels-1;			
				for (var tempStr:String in inObj)
				{
					this.wTrace(tempPrefix+tempStr + ":");
					this.printTree(inObj[tempStr],tempLevel,tempPrefix);
				}
			}
		}
		
		/**
		*  Name:  printTypeXML
		*  Purpose:  Outputs the contents of an object definition
		*  @param inObj		Object	The object to parse
		*/		
		public function printTypeXML(inObj:Object):void {
			this.wTrace(describeType(inObj).toXMLString());
		}
				
		/**
		*  Name:  stackTrace
		*  Purpose:  Outputs the stackTrace
		*  @see	http://stackoverflow.com/questions/149073/stacktrace-in-flash-actionscript-3-0
		*/		
		public function stackTrace():void {
			var tempError:Error = new Error();

			this.wTrace("\n***** Stack Trace *****\n" + tempError.getStackTrace() + "\n");
		}
		
		/**
		*  Name:  wTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/		
		public function wTrace(received_string:String):void {
			if (this.boolDebugTrace)
			{
				this.updateDisplayString(received_string);
			}
		}

		/**
		*  Name:  functionTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/			
		public function functionTrace(received_string:String):void {
			if (this.boolDebugFunctionTrace)
			{
				this.updateDisplayString("@" + received_string);
			}
		}

		/**
		*  Name:  eventTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/		
		public function eventTrace(received_string:String) {
			if (this.boolDebugEventTrace)
			{
				this.updateDisplayString(received_string);
			}
		}

		/**
		*  Name:  warningTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/	
		public function warningTrace(received_string:String):void {
			this.updateDisplayString("\n## WARNING:  " + received_string + "\n");
			//this.show();
		}
		
		/**
		*  Name:  errorTrace
		*  Purpose:  Outputs recieved string to the debugger window
		*  @param received_string	String	String to output to the text window
		*/	
		public function errorTrace(received_string:String) {
			this.updateDisplayString("\n## ERRROR:  " + received_string + "\n");
			this.show();
		}

		//Clear trace history
		public function clear():void {
			this.debug_String = "";
		}

		/**
		*  Name:  assignDebugState
		*  Purpose:   Toggles the specified debug state, which controls what trace statement values are kept for display..  Except for DEBUB_ALL and DEBUG_NONE, which are global.
		*		Timestamp is always treated independently
		*  @param inState NumberUsing the public constants for debug states that can be toggled
		* <br/>
		* states supported:
		* <ul>
		* <li> DEBUG_ALL - Show all debugging statements<li/>
		* <li> DEBUG_TRACE -  Display trace statements<li/>
		* <li> DEBUG_TIMESTAMP -  Display timestamps<li/>
		* <li> DEBUG_FUNCTIONS - Display functions<li/>
		* <li> DEBUG_EVENTS - Display event trace statements<li/>
		* <li> DEUG_NONE - Turn off all debugging<li/>
		* </ul>
		*/	
		public function assignDebugState(inState:int):void {
			switch(inState)
			{
				case DebugUtilConst.DEBUG_ALL:
					boolDebugTrace = boolDebugEventTrace = boolDebugFunctionTrace = true;
				break;
				case DebugUtilConst.DEBUG_EVENTS:
					boolDebugEventTrace = !boolDebugEventTrace;
				break;
				case DebugUtilConst.DEBUG_TIMESTAMP:
					boolDebugTimeStamped = !boolDebugTimeStamped;
				break;
				case DebugUtilConst.DEBUG_FUNCTIONS:
					boolDebugFunctionTrace = !boolDebugFunctionTrace;
				break;
				case DebugUtilConst.DEBUG_TRACE:
					boolDebugTrace = !boolDebugTrace;
				break;
				case DebugUtilConst.DEBUG_NONE:
				default:
					boolDebugTrace = boolDebugTimeStamped = boolDebugEventTrace = boolDebugFunctionTrace = false;
				break;
			}
		}
		
 		// Hide the debug window
		public function hide():void {
			this.visible = false;
			this.debugWindow.hide();
		}

		// Hide the debug window
		public function show():void {
			this.visible = true;
			this.debugWindow.show(this.debug_String);
		} 
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/
				
		private function onEnterFrame(event:Event):void
		{
			if(framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				this.x = 62;
				this.y = 635;
				addChild(this.debugWindow);
			}
		}

		/******************************************************************************************************
		**  PRIVATE
		*******************************************************************************************************/

		/*
		*  Name:  updateDisplayString
		*  Purpose:  Outputs recieved string to the debugger window
		*/
		private function updateDisplayString(received_string:String):void {
			var tempStr:String;
			var timestamp:String;
			timestamp = (new Date()).toString();
			tempStr = (this.boolDebugTimeStamped) ? timestamp + ":  "+ received_string : received_string;
			this.debug_String = (this.debug_String == null) ? "" : this.debug_String;
			this.debug_String += tempStr + "<br/>";
			trace(tempStr);
			// if (ExternalInterface)
			// {
				// ExternalInterface.call("console.log",received_string);
			// }
			this.debugWindow.refresh(this.debug_String);
		}

	}
}