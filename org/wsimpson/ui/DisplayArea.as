package org.wsimpson.ui

/*
** Title:	DisplayArea.as
** Purpose: Manages the basic events
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
**
** 	@langversion ActionScript 3.0
**	@playerversion Flash 10.0
**	@tiptext http://tinyurl.com/2dt7vjr
*/
{
	// Adobe
	import flash.events.Event;
	import flash.accessibility.AccessibilityProperties;
	import flash.accessibility.Accessibility;
	import flash.system.Capabilities;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import fl.containers.ScrollPane;	
	
	// Utilities
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.XMLUtil;

	// UI
	import org.wsimpson.ui.cell.GradientCell;
	
	public class DisplayArea extends GradientCell
	{
		// Parameters
		public const propArr = ["x","y","width","height","scrollable"];
		public const SCROLL_WIDTH = 30;

		// Protected Instance Variables
        protected var _definition:XML;			// Display  properties defined
		
		// Private Instance Variables
        private var _debugger:DebugUtil;		// Creates trace statements both in debug window and output window		
        private var _style:Object;				// Display Area Style Object
        private var _description:String;		// The accessiblity description of the display area
        private var _scrollableBool:Boolean;	// Indicates the contents of this display area should be scrollable.
		private var _scrollPane:ScrollPane;		// Scrollpane if required
		private var _scrollWidth:uint;			// Scrollpane if width
		private var _scrollHeight:uint;			// Scrollpane if height
		private var _targetArea:Sprite;			// Display area of the Display Object
		private var _contentArr:Array;			// Array of text content displayed
		
		// Constructor
		/**
		*  name:  DisplayArea
		*  @param inDef		XML	Contains the parameters defined 
		*  @param inStyle	Object	Defined stylesheet for the parent object
		*  @param inDesc	String	Accessbility description of what the display area is for
		*
		* 	@langversion ActionScript 3.0
		*	@playerversion Flash 10.0
		*	@tiptext
		*/
		public function DisplayArea(inDef:XML,inStyle:Object,inDesc:String)
		{
			super();
			this._debugger = DebugUtil.getInstance();
			
			// Assign he Display Area Definition
			this._definition = inDef;
			this._style = inStyle;		
			this._description = inDesc;
			this._scrollableBool = false;
			this._contentArr = new Array();

			// Define the content area
			this._targetArea = new Sprite();
			this._targetArea.x = this._targetArea.y = 0;
			
			// Initialize the display
			this.applyProp();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/******************************************************************************************************
		** Events
		*******************************************************************************************************/

		public function leaveStage():void
		{
			for (var i:Number= 0; i < this._contentArr.length; i++)
			{
				this.removeDAChild(this._targetArea,this._contentArr[i]);
			}
			if (this._scrollableBool)
			{		
				this.removeDAChild(this,this._scrollPane);
			} else
			{		
				this.removeDAChild(this,this._targetArea);
			}
		}
		
		/******************************************************************************************************
		**  PARAMETERS
		******************************************************************************************************/

		/**
		*  Name:  	display_width
		*  Purpose:  The width of the area for the scroll is limited by the width of the scroll bar
		*/
		public function display_width():uint {
			return 	(this._scrollableBool) ? (this.cell_width - SCROLL_WIDTH) : this.cell_width;
		}

		/**
		*  Name:  	getDAStyle
		*  Purpose:  Return the style object assigned to the display area
		*/
		public function getDAStyle():Object {
			return 	this._style;
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/
		public function addDisplayObject(inObj:DisplayObject):void {
			inObj.visible = true;
			this._contentArr.push(inObj);	
		}

		public function addStackedDisplayObject(inObj:DisplayObject):void {
			var tempIndex:uint;
			var tempHeight:uint;

			tempIndex = (this._contentArr.length == 0) ? 0 : this._contentArr.length - 1;
			tempHeight = 	(this._contentArr[tempIndex]) ? 
							(this._contentArr[tempIndex].y + this._contentArr[tempIndex].height) : 0;

			inObj.x = 0;
			inObj.y = tempHeight;
			inObj.visible = true;
			this._contentArr.push(inObj);	
		}
		
		public function hideDisplayArea():void 
		{
			this.visible = false;
		}
		
		public function showDisplayArea():void 
		{
			this.visible = true;
		}

			
		/******************************************************************************************************
		**  PRIVATE
		******************************************************************************************************/
				
		private function onEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			// Initialize the display
			this.init();
		}
				
		private function removeDAChild(inParent:DisplayObjectContainer, inChild:DisplayObject):void
		{
			if ((inParent != null) && (inChild != null))
			{				
				if (inParent.contains(inChild))
				{
					inParent.removeChild(inChild);
				} else if (inChild.parent != null)
				{			
					inChild.parent.removeChild(inChild);
				}
			}
		}
		
		private function applyProp():void {
			for (var i:uint; i < propArr.length; i++)
			{
				switch(propArr[i])
				{ 
					case "x":
					case "y":
						this[propArr[i]] = Number(this._definition.@[propArr[i]].toString());
					break;						
					case "width":
						this.cell_width = Number(this._definition.@[propArr[i]].toString());
					break;						
					case "height":
						this.cell_height = Number(this._definition.@[propArr[i]].toString());
					break;
					case "scrollable":
						this._scrollableBool = Boolean(this._definition.@[propArr[i]].toString() == "true");
					break;
					default:
						this._debugger.warningTrace("Unexpected property display area object definition:  " +
													propArr[i] + " = " + 
													this._definition.@[propArr[i]].toString());
					break;
				}
			}
		}

		private function assignColor():void {
			if (this._style.hasOwnProperty("color"))
			{
				this.bgColor.setRGB_CSS(this._style.color);
				this.backgroundColor = this.bgColor.color;
			} else
			{
				this._debugger.errorTrace("Expecting CSS defined color for the display area");
			}
		}
		
		// see http://tinyurl.com/2fnol38
		private function assignAccessibility():void {
			var accessProps:AccessibilityProperties;
			
			accessProps = new AccessibilityProperties();
			accessProps.name = "Display Area";
			accessProps.description = this._description;
			this.accessibilityProperties = accessProps;
			
			if (Capabilities.hasAccessibility) {
				Accessibility.updateProperties();
			}
		}
		
		private function assignScrollPane():void {
			if (this._scrollableBool)
			{
				var newSkinClip:Sprite;
				this._scrollPane = new ScrollPane();
				this._scrollPane.setSize(this.width, this.height);
				this._scrollPane.source = this._targetArea;
				newSkinClip = new Sprite();
				this._scrollPane.setStyle( "upSkin", newSkinClip );
				addChild(this._scrollPane);
				this._scrollPane.visible = true;				
			} else
			{
				addChild(this._targetArea);
			}
		}

		private function addContent() {
		
			for (var i:Number= 0; i < this._contentArr.length; i++)
			{
				this._targetArea.addChild(this._contentArr[i]);
			}
		}
		
		private function init():void {

			// background
			this.assignColor();	
			this.drawRect();
			
			this.assignAccessibility();			
			this.addContent();

			// Add scrollpane
			this.assignScrollPane();
		}		
			
    }
}