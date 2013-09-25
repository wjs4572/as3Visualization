package org.wsimpson.store

/*
** Title:	OrderStore.as
** Purpose: A tool for creating objects containing name value pairs that are printable
** Author:  William Simpson
** Copyright (c) 2011 William J Simpson - All Rights Reserved
*/
{

	// Utitlies
	import org.wsimpson.util.DebugUtil;
	import org.wsimpson.util.StringUtil;
   
	public final class OrderStore {
	
		// XML Template		
		protected static const TEMPLATE_STORE =
			"<store>{STORE}</store>";		
		protected static const STORE = "{STORE}";							// Field to replace

		// Regex
		protected static const storePattern:RegExp = new RegExp(STORE);	// Regular Expression pattern

		// Private Instance Variables
		private var _debugger:DebugUtil;
		private var _enumObject:Object;

		public function OrderStore() {
			this._debugger = DebugUtil.getInstance();
		}
		
		/******************************************************************************************************
		**  PUBLIC
		******************************************************************************************************/

		/**
		*  name:  	importXMLList
		*  Purpose: Converts XMLList of elements with "name" and "value" attributes to object store
		*  @param inXML List
		*/
		public function importXMLList(inList:XMLList):void
		{
			this.newObj();
			for each (var item:XML in inList)
			{
				this.addNameValue(item.@name,item.@value);
			}
		}
		
		/**
		*  name:  	storeArrayXMLStr
		*  Purpose: Converts the Field Rule values to an XML String
		*  @param inArray Array	Array containing objects with name value pairs
		*  @return String The field rule values as XML.
		*/
		public function storeArrayXMLStr(inArray:Array):String
		{
			var tempObj:Object;
			var tempStr:String;
			tempStr = "";
			for (var i:int = 0; i < inArray.length; i++)
			{
				var tempPos:String;
				tempPos = TEMPLATE_STORE;
				tempObj = convertNameValue(inArray[i]);
				tempPos =  tempPos.replace(storePattern,toXMLString(tempObj));
				tempStr += tempPos;
			}
			return tempStr;
		}
		
		/**
		* Name: 	newObj
		* Purpose: 	create a new instance of the enumerated object
		*/
		public  function newObj():void 
		{
			this._enumObject = new Object();
			this._enumObject.valueArr = new Array();
			this._enumObject.toString = function toString():String
				{
					var tempStr:String = "";
					for (var i:Number = 0; i < this.valueArr.length; i++)
					{
						var nameStr:String;
						nameStr = this.valueArr[i];
						tempStr += nameStr + " = " + this[nameStr] + "\n";
					}
					return tempStr;
				}
		}


		/**
		* Name: 	addNameValue
		* Purpose: 	Facilited the creation of enumerated objects
		* @param nameStr String Name of the value pair
		* @param valueObj Object Value to store
		* @return Boolean Indicates succes
		*/
		public  function addNameValue(nameStr:String,valueObj:Object):Boolean 
		{
			var tempBool:Boolean;
			// Confirm enumerable object exists, if not create it.
			if (this._enumObject == null)
			{
				this.newObj();
			}
			// If object doesn't exist add it.
			tempBool = (this._enumObject[nameStr] == null);
			if (tempBool)
			{
				this._enumObject[nameStr] = valueObj;
				this._enumObject.valueArr.push(nameStr);
			}
			return tempBool;
		}
		
		/**
		* Name: 	toXMLString
		* Purpose: 	Convert an enumerated object to an XMLList
		* @param inObj Object Object containing name value pairs
		* @return String  The name/value pairs as XML String
		*/
		public function toXMLString(inObj:Object=""):String
		{
			inObj = (inObj == "") ? this._enumObject : inObj;

			return OrderStore.createXMLString(inObj);
		}
		
		/**
		* Name: 	toString
		* Purpose: 	Convert an enumerated object an XMLList
		* @return String  The name/value pairs as XML String
		*/
		public function toString():String
		{
			return this.toXMLString();
		}
		
		
		
		/**
		* Name: 	createString
		* Purpose: 	Convert an enumerated object an XMLList
		* @param inObj Object Object containing name value pairs
		* @return String Indicates succes
		*/
		public static function createXMLString(inObj:Object=""):String
		{
			var tempStr:String;
			tempStr = "";
			
			for (var i:int=0;i < inObj.valueArr.length;i++)
			{
				tempStr += 	"<unit name=" + 
									StringUtil.doubeQuoteStr(inObj.valueArr[i]) + 
									" value=" +
									StringUtil.doubeQuoteStr(inObj[inObj.valueArr[i]]) + 
							"></unit>\n";
			}
			return tempStr;
		}
		
		/**
		*  name:  hasValue
		* @param inStr String The name of the value stored
		* @return Boolean Exists
		*/
		public function hasValue(inStr:String):Boolean
		{
			return this._enumObject[inStr];
		}
		
		/**
		*  name:  getValue
		* @param inStr String The name of the value stored
		* @return Object Value
		*/
		public function getValue(inStr:String):Object
		{
			return this._enumObject[inStr];
		}
		
		/**
		*  name:  setValue
		* @param inStr String The name of the value stored
		* @param inObj Object Update the value stored
		*/
		public function setValue(inStr:String,valueObj:Object):void
		{
			this._enumObject[inStr] = valueObj;
		}
		
		/**
		*  name:  convertNameValue
		* @param inObj Convert a name value object to a enumerated object usable by OrderStore
		* @return Object Enumerated Object
		*/
		public function convertNameValue(inObj:Object):Object
		{
			return OrderStore.transformNameValue(inObj);
		}

		/**
		*  name:  transformNameValue
		* @param inObj Convert a name value object to a enumerated object usable by OrderStore
		* @return Object Enumerated Object
		*/
		public static function transformNameValue(inObj:Object):Object
		{
			var tempArr:Array;
			tempArr =  new Array();
			for (var nameStr:String in inObj)
			{
				tempArr.push(nameStr);
			}
			inObj.valueArr = tempArr;
			return inObj;
		}
		
		/**
		*  name:  objectToXMLString
		* @param inObj Create an XML String from a name / value object
		* @return Object Enumerated Object
		*/
		public static function objectToXMLString(inObj:Object):Object
		{
			return OrderStore.createXMLString(OrderStore.transformNameValue(inObj));
		}
		
		/**
		*  name:  getObj
		*/
		public function getObj():Object
		{
			return this._enumObject;
		}

	}
}