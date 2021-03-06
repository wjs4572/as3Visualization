﻿package org.wsimpson.loaders
/*
** Title:	PreLoader.as
** Purpose: Interactive for selecting color scales
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{
	// Adobe Formatting
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageScaleMode;	
	import flash.events.Event;
	
	// Managers
	import org.wsimpson.manager.KeyboardManager;
	import org.wsimpson.events.KeyboardShortcutEvent;

	// Foundational, but not Abstract Class
	public class PreLoader extends MovieClip
	{
		private	var keyboardView:KeyboardManager;	// The keyboard input manager
		protected var _parameters:Object;			// Associative Array of parameters passed to the Flash Object
		
		// Constructor
		function PreLoader()
		{
			stop();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		/************************************************************************************************************************************
		**  Public classes to override
		************************************************************************************************************************************/
		
		/**
		*  Name:  progressBar
		*  Purpose:  Draws the loading progress bar
		*/
		public function progressBar():void
		{	
			var percent:Number;
			
			percent = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
			
			graphics.clear();
			graphics.beginFill(0);
			graphics.drawRect(0, stage.stageHeight / 2 - 10,
			stage.stageWidth * percent, 20);
			graphics.endFill();
		}

		/**
		*  Name:  addShortcut
		*  Purpose:  Draws the loading progress bar
		*  @param shortcutStr	String		Keyboard shortcut to listen for
		*  @param eventType		String		Event type generated by the shortcut
		*  @param inFunction	Function	Event Handler
		*/		
		public function addShortcut(shortcutStr:String,eventType:String,inFunction:Function):void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Create Keyboard Shortcut for program exit
			this.keyboardView = (this.keyboardView == null) ? new KeyboardManager(this) : this.keyboardView;
			this.keyboardView.listenFor(shortcutStr,eventType);
			this.keyboardView.addEventListener(eventType, inFunction);
		}

		/**
		*  Name:  init
		*  Purpose:  Generic initialization with creation of default shortcuts and stage configuration
		*/		
		public function init():void
		{
			// Initiate the application
		}

		/************************************************************************************************************************************
		** Parameters
		************************************************************************************************************************************/
		
		/*
		*  @param inObj Object The Flash Object parameters
		*/
		public function get parameters():Object
		{
			return this._parameters;
		}
		public function set parameters(inObj:Object):void 
		{
			// Do Nothing
		}
		/************************************************************************************************************************************
		** Event Listeners
		************************************************************************************************************************************/
		
		private function onEnterFrame(event:Event):void
		{
			if(framesLoaded == totalFrames)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
							
				// Process Flash Parameters
				this.setParameters();
				
				// Proceed to Content
				nextFrame();
				this.init();
			} else
			{
				this.progressBar();
			}
		}
		
		// Assigns the session paramters				
		private function setParameters():void
		{
			var tempInfo:LoaderInfo = (this.root.loaderInfo) ? this.root.loaderInfo as LoaderInfo : null;
			if (tempInfo)
			{
				this._parameters = (tempInfo.parameters) ? tempInfo.parameters : null;
			}
		}
		

	}
}