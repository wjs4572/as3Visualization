package org.wsimpson.ui

/*
** Title:	ButtonBase.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe
	import flash.accessibility.AccessibilityProperties;	
    import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;

	// Utilities
	import org.wsimpson.util.DebugUtil;
	
	// ActionScript Tools
	import org.wsimpson.styles.Style;
	

	public class ButtonBase extends MovieClip
	{
		// Public Constants
		public static var BUTTON_UP:String = "up";				// A button state
		public static var BUTTON_DOWN:String = "down";			// A button state
		public static var BUTTON_OVER:String = "over";			// A button state
		public static var BUTTON_DISABLED:String = "disabled";	// A button state
		public static var BUTTON_HIDDEN:String = "hide";		// A button state
		
		// id is used as internal reference when multiple buttons have the same label
		public var id:String;

		// Protected Instance Variables
		protected var _buttonLabel:TextField;	// State dependent textfield
		
		// Private Instance Variables
        private var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window
        private var listener_array:Array;		// Notify listeners upon changes
        private var _buttonName:String;			// Button Label
        private var _style:Style;				// Button Style
        private var _active:Boolean;			// Button Active Boolean
        private var _desc:String;				// Button Description
        private var _state:String;				// the current state
 		
		// Constructor
		public function ButtonBase()
		{
			super();
			this._debugger = DebugUtil.getInstance();

			this.showButton();
			this.gotoAndStop(this._state);
			this._buttonName = "button";
			this._desc = "button";
			this.id = "";
			
			// Use existing TextField
			this._buttonLabel = this["labelStr"];

			this.listener_array = new Array();
			this.addEventListener(flash.events.MouseEvent.CLICK,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OVER,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_OUT,buttonChange,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_DOWN,down,false,0,true);
			this.addEventListener(flash.events.MouseEvent.MOUSE_UP,up,false,0,true);
			this.mouseChildren = false;
		}
		
		public function hideButton():void 
		{
			this._active = false;
			this.alpha = 0;
			this.visible = false;
			this.gotoAndStop(BUTTON_HIDDEN);
		}
		
		public function showButton():void 
		{
			this._active = true;
			this.visible = true;
			this.alpha = 100;
			this._state = BUTTON_UP;
			this.gotoAndStop(BUTTON_UP);
		}

		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/
				

		/**
		*  name:  makeAccessible
		*  @param inDesc	String	String describing the button
		*/		
        public function makeAccessible(inDesc:String = ""):void {
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.name = this._buttonName;
			this._desc = (inDesc == "") ? this._desc : inDesc;
			accessProps.description = inDesc;
			this.accessibilityProperties = accessProps;
        }
		
        public function get style():Style {
			return this._style;
        }		
        public function set style(inStyle:Style):void {
			this._style = inStyle;
			this._buttonLabel.styleSheet = this._style;
        }
		
        public function get buttonLabel():String {
			return this._buttonName;
        }		
        public function set buttonLabel(inStr:String):void {
			this._buttonName = inStr;
			this._buttonLabel.htmlText = this.button_label(this._state);
			this.makeAccessible();
			this.refresh();	
        }

        public function get state():String {
			return this._state;
        }		
        public function set state(inStr:String):void {
			this._state = inStr;
			switch(this._state)
			{	case BUTTON_DOWN:
					this.down(null);
				break;
				case BUTTON_OVER:
					this.rollOver(null);
				break;
				case BUTTON_DISABLED:
					this.disable();
				break;
				case BUTTON_HIDDEN:
					this.hideButton();
				break;
				case BUTTON_UP:
					this.showButton();
				default:
					this.up(null);
				break;
			}
			this.refresh();
        }

		/**
		*  name:  addButtonListener
		*  @param inFunction	Function	Event listner
		*/
		public function addButtonListener(inFunction:Function):void {
			this.listener_array = (this.listener_array == null) ? new Array() : this.listener_array;
			this.listener_array.push(inFunction);
		}

		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
				
		/**
		*  name:  Initialize
		*  @param inNameStr		String			The button label
		*/
		public function initialize(inNameStr:String)
		{
			this._buttonName = inNameStr;
		}
	
		/******************************************************************************************************
		**  Event Handlers
		******************************************************************************************************/
				
		
		public function buttonChange(event:MouseEvent):void {
			if (_active)
			{	
				switch(event.type)
				{
					case MouseEvent.MOUSE_OUT:
						this.rollOut(event);
					break;
					case MouseEvent.MOUSE_OVER:
						this.rollOver(event);
					break;
					default:
						// do nothing
					break;
				}
				this.notifyListeners(event);
			}			
		}
		
		public function down(event:MouseEvent):void {
			if (_active)
			{
				this.gotoAndStop(BUTTON_DOWN);
			}
			this._buttonLabel.htmlText = this.button_label(BUTTON_DOWN);
		}

		public function up(event:MouseEvent):void {
			if (_active)
			{
				this.gotoAndStop(BUTTON_UP);
			}
			this._buttonLabel.htmlText = this.button_label(BUTTON_UP);		
		}
		
		public function rollOut(event:MouseEvent):void {
			if (_active)
			{
				this.gotoAndStop(this._state);
			}
			this._buttonLabel.htmlText = this.button_label(this._state);		
		}

		public function rollOver(event:MouseEvent):void {
			if (_active)
			{
				this.gotoAndStop(BUTTON_OVER);
			}
			this._buttonLabel.htmlText = this.button_label(BUTTON_OVER);		
		}
		
		public function disable():void {
			if (_active)
			{
				this.gotoAndStop(BUTTON_DISABLED);
			}
		}

		public function refresh():void {
			this.up(null);
		}
		
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
		
		private function button_label(stateStr:String):String {
			var tempStr:String;
			var tempStyle:String;
			var initiateStyle:Object;
			tempStyle = 	this._buttonName.toLowerCase() + "_" + stateStr;
			tempStr = 	"<" + tempStyle + ">" + this._buttonName +"</" + tempStyle + ">" ;
			if (this._style.hasStyle(tempStyle))
			{
				initiateStyle =  this._style.getStyle(tempStyle);
			} else
			{
				this._debugger.warningTrace("ButtonBase.buttonLabel -> name " + this._buttonLabel.htmlText);
				this._debugger.warningTrace("ButtonBase.button_label -> style " + tempStyle);
				this._style.fileContents();
			}

			return tempStr;
		}		
		
		private function notifyListeners(event:MouseEvent):void {
			for (var i:Number = 0; i < this.listener_array.length; i++)
			{
				this.listener_array[i](this,event);
			}
		}
		
    }
}