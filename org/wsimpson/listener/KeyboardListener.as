package org.wsimpson.listener

/*
** Title:	KeyboardListener.as
** Purpose: Component for displaying a color using several color models
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/

{
	import org.wsimpson.interfaces.IKeyboardInputHandler;
	import flash.events.KeyboardEvent;
	import flash.display.Sprite;
	import flash.display.DisplayObject;

	public class KeyboardListener extends Sprite
	{
		private	var appStage:Object;		// References the active stage
		private	var keyManager:Object;		// References the keyboard manager
		
		public function KeyboardListener(handler:Object,target:Object)
		{
			this.appStage = target;
			this.keyManager = handler;
			
			this.appStage.addEventListener(KeyboardEvent.KEY_DOWN,keyListener,false);
			this.appStage.addEventListener(KeyboardEvent.KEY_UP,keyListener,false);
		}
	
		public function keyListener(e:KeyboardEvent):void
		{			
			(this.keyManager as IKeyboardInputHandler).keyHandler(e);
		}
    }
}