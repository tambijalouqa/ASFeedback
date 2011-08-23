package com.binaryinteractivestudios.ASFeedback 
{
	import flash.display.Sprite;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.*;
	import flash.utils.getTimer;	
	import flash.utils.ByteArray;
	import flash.net.*;
	import flash.events.NetStatusEvent;
	import com.adobe.images.*;
	import com.marston.utils.URLRequestWrapper;
	import flash.xml.*;
		
	/**
	 * ...
	 * @author tambi jalouqa
	 */
	public class ASFeedBack extends Sprite
	{
		private static const _instance:ASFeedBack = new ASFeedBack( SingletonLock );  
		
		private static var ci:ContextMenuItem;
		
		private static var stage:Stage;
		private static var context:InteractiveObject;
		
		private static var brush:Shape;
		private static var resultContainer:Sprite;
		
		private static var closeButton:Sprite;
		private static var saveButton:Sprite;
		
		private static var commentHolder:Sprite;
		
		private static var disabler:Sprite;
		
		private static var bd:BitmapData;
		private static var bdBrush:BitmapData;
		
		private static var snapshot:Bitmap;
		
		private static var mouseDown:Boolean = false;
		private static var feedbackMode:Boolean = false;
		
		private static var generalTextFormat:TextFormat;
		private static var commentTextFormat:TextFormat;
		
		private static var brushSize:Number = 5;
		
		private static var project:String = 'Undefined';
		
		private static var mySo:SharedObject;
		
		// Temp URL untill we know what technology to use for the backend. Im thinking google docs
		static private var tempURL:String = "http://www.binaryinteractivestudios.com/feedback/addFeedback.php";

		
		public static function get instance():ASFeedBack  
		{  
            return _instance;  
		} 
		public function ASFeedBack( lock:Class )  
		{  
			 // Verify that the lock is the correct class reference.  
			 if ( lock != SingletonLock )  
			 {  
				 throw new Error( "Invalid Singleton access.  Use Model.instance." );  
			 }  
		}	
		
		public static function init(stageInstance:Stage,originalContext:InteractiveObject,projectName:String):Boolean
		{
			if(context != null) return false;
			
			stage = stageInstance;
			context = originalContext;
			
			project = projectName;
			
			var cm : ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			ci = new ContextMenuItem("Send Feedback", true);
			ci.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSnapshot);
			cm.customItems = [ci];
			context.contextMenu = cm;
			
			brush = new Shape();
			resultContainer = new Sprite();
			closeButton = new Sprite();
			saveButton = new Sprite();
			commentHolder = new Sprite();
			disabler = new Sprite();
			
			generalTextFormat = new TextFormat();
			commentTextFormat = new TextFormat();
			
			mySo = SharedObject.getLocal("commentOwner");
			
			brush.graphics.beginFill(0xFF0000, 1);
			brush.graphics.drawCircle( brushSize, brushSize , brushSize);
			brush.graphics.endFill();
			
			closeButton.graphics.beginFill(0x000000, 1);
			closeButton.graphics.drawRoundRect(0, 0, 31, 31, 10, 10);
			closeButton.graphics.endFill();
			
			saveButton.graphics.lineStyle(0, 0xFFFFFF, .2);
			saveButton.graphics.beginFill(0x000000, 1);
			saveButton.graphics.drawRoundRect(0, 0, 100, 30, 10, 10);
			saveButton.graphics.endFill();
			
			commentHolder.graphics.lineStyle(0, 0xFFFFFF, .2);
			commentHolder.graphics.beginFill(0x000000, 1);
			commentHolder.graphics.drawRoundRect(0, 0, 300, 180, 10, 10);
			commentHolder.graphics.endFill();
			
			var disablerBG:Shape = new Shape();
			disabler.addChild(disablerBG);
			
			disablerBG.graphics.beginFill(0x000000, .8);
			disablerBG.graphics.drawRect(0, 0, 100, 100);
			disablerBG.graphics.endFill();
			
			var shape1:Shape = new Shape();
			shape1.graphics.beginFill(0xFFFFFF, 1);
			shape1.graphics.drawRoundRect(0, 0, 25, 6, 6, 6);
			shape1.graphics.endFill();
			
			var shape2:Shape = new Shape();
			shape2.graphics.beginFill(0xFFFFFF, 1);
			shape2.graphics.drawRoundRect(0, 0, 25, 6, 6, 6);
			shape2.graphics.endFill();
			
			
			generalTextFormat.size = 11;
			generalTextFormat.font = "Verdana";
			generalTextFormat.color = 0xFFFFFF;
			
			commentTextFormat.size = 11;
			commentTextFormat.font = "Verdana";
			commentTextFormat.color = 0x000000;
			
			var saveText:TextField = new TextField();
			saveText.defaultTextFormat = generalTextFormat;
			saveText.text = "Send Feedback";
			saveText.selectable = false;
			saveText.mouseEnabled = false;
			saveText.autoSize = "left";
			
			var commentTextField:TextField = new TextField();
			commentTextField.defaultTextFormat = commentTextFormat;
			commentTextField.text = "";
			commentTextField.width = 275;
			commentTextField.height = 95;
			commentTextField.type = TextFieldType.INPUT;
			commentTextField.multiline = true;
			commentTextField.wordWrap = true;
			commentTextField.backgroundColor = 0xFBFAE6;
			commentTextField.background = true;
			commentTextField.name = "comment";
			
			var ownerTextField:TextField = new TextField();
			ownerTextField.defaultTextFormat = commentTextFormat;
			ownerTextField.text = "";
			ownerTextField.width = 275;
			ownerTextField.height = 20;
			ownerTextField.type = TextFieldType.INPUT;
			ownerTextField.multiline = false;
			ownerTextField.wordWrap = false;
			ownerTextField.backgroundColor = 0xFBFAE6;
			ownerTextField.background = true;
			ownerTextField.name = "owner";
			
			var commentTitle:TextField = new TextField();
			commentTitle.defaultTextFormat = generalTextFormat;
			commentTitle.selectable = false;
			commentTitle.mouseEnabled = false;
			commentTitle.text = "Add your comments";
			commentTitle.type = TextFieldType.DYNAMIC;
			commentTitle.autoSize = "left";
			
			var ownerTitle:TextField = new TextField();
			ownerTitle.defaultTextFormat = generalTextFormat;
			ownerTitle.selectable = false;
			ownerTitle.mouseEnabled = false;
			ownerTitle.text = "Your name";
			ownerTitle.type = TextFieldType.DYNAMIC;
			ownerTitle.autoSize = "left";
			
			var loadingText:TextField = new TextField();
			loadingText.defaultTextFormat = generalTextFormat;
			loadingText.selectable = false;
			loadingText.mouseEnabled = false;
			loadingText.text = "Sending your feedback, it wont take long.";
			loadingText.type = TextFieldType.DYNAMIC;
			loadingText.autoSize = "left";
			
			ownerTextField.addEventListener(Event.CHANGE, onChangeOwner);

			
			shape1.rotation = 45;
			shape1.x = 9;
			shape1.y = 4;
			shape2.rotation = -45;
			
			shape2.y = 22;
			shape2.x = 5;
			
			saveText.x = 5;
			saveText.y = 6;
			
			commentTextField.x = 13;
			commentTextField.y = 70;
			
			ownerTextField.x = 13;
			ownerTextField.y = 25;
			
			commentTitle.x = 11;
			commentTitle.y = 50;
			
			ownerTitle.x = 11;
			ownerTitle.y = 5;
			
			closeButton.addChild(shape1);
			closeButton.addChild(shape2);
			
			saveButton.addChild(saveText);
			
			commentHolder.addChild(commentTextField);
			commentHolder.addChild(commentTitle);
			commentHolder.addChild(ownerTitle);
			commentHolder.addChild(ownerTextField);
			
			disabler.addChild(loadingText);
			
			closeButton.buttonMode = true;
			saveButton.buttonMode = true;
			
			ASFeedBack.instance.addChild(resultContainer);
			
			resultContainer.addChild(closeButton);
			resultContainer.addChild(saveButton);
			resultContainer.addChild(commentHolder);
			resultContainer.addChild(disabler);
			
			disabler.mouseEnabled = true;
			disabler.visible = false;
			
			
			closeButton.addEventListener(MouseEvent.CLICK, onClose);
			saveButton.addEventListener(MouseEvent.CLICK, onSave);
			
			return true;
		}
		
		private static function onSnapshot(e:ContextMenuEvent):Boolean
		{
			if (feedbackMode) return false;
			
			bd = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000);
			bd.draw(stage);
			
			bdBrush = new BitmapData(brush.width, brush.height,true,0x00FFFFFF);
			bdBrush.draw(brush);
			
			snapshot = new Bitmap(bd);
			
			resultContainer.addChildAt(snapshot,0);
			
			stage.addChild(ASFeedBack.instance);
			
			closeButton.x = snapshot.width - closeButton.width - 20;
			closeButton.y = 20;
			
			saveButton.x = Math.floor( snapshot.width * .5  - saveButton.width * .5 );
			saveButton.y = snapshot.height - saveButton.height - 20;
			
			commentHolder.x = 20;
			commentHolder.y = Math.floor( snapshot.height * .5 - commentHolder.height * .5 );
			
			disabler.getChildAt(0).width = snapshot.width;
			disabler.getChildAt(0).height = snapshot.height;
			
			disabler.getChildAt(1).x = Math.floor( snapshot.width * .5 - disabler.getChildAt(1).width * .5 )
			disabler.getChildAt(1).y = Math.floor( snapshot.height * .5 - disabler.getChildAt(1).height * .5 )
			
			var commentTextInstance:TextField = commentHolder.getChildByName('comment') as TextField;
			commentTextInstance.text = "";
			
			var ownerTextInstance:TextField = commentHolder.getChildByName('owner') as TextField;
			
			if (mySo.data.owner) {
				ownerTextInstance.text = mySo.data.owner;
			}

			feedbackMode = true;
			
			resultContainer.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			resultContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			return true;
		}
		private static function onChangeOwner(e:Event):void
		{
			mySo.data.owner = e.currentTarget.text;
		}
		private static function onMouseMove(e:MouseEvent):void
		{	
			if(mouseDown){
				bd.copyPixels(bdBrush, new Rectangle( 0, 0, brushSize << 1, brushSize << 1), new Point(resultContainer.mouseX - brushSize, resultContainer.mouseY - brushSize), null, null, true);
				e.updateAfterEvent();
			}
		}
		private static function onMouseDown(e:MouseEvent):void
		{
			mouseDown = true;
		}
		private static function onMouseUp(e:MouseEvent):void
		{
			mouseDown = false;
		}
		private static function onClose(e:MouseEvent):void
		{
			feedbackMode = false;
			
			resultContainer.removeChild(snapshot);
			snapshot = null;
			
			stage.removeChild(ASFeedBack.instance);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
		}
		private static function onSave(e:Event):void
		{
			disabler.visible = true;
			
			var commentTextInstance:TextField = commentHolder.getChildByName('comment') as TextField;
			var commentText:String = commentTextInstance.text;
			
			var ownerTextInstance:TextField = commentHolder.getChildByName('owner') as TextField;
			var ownerText:String = ownerTextInstance.text;
			
			var byteArray : ByteArray = new JPGEncoder( 50 ).encode( bd );
			
			var wrapper:URLRequestWrapper = new URLRequestWrapper(byteArray, "image" + Math.random() * 1000000 + ".jpg");
			wrapper.url = tempURL + "?project=" + project + "&comment=" 
			+ Base64.encode64String(commentText) + "&owner=" + ownerText;
			
			var ldr:URLLoader = new URLLoader();
			ldr.dataFormat = URLLoaderDataFormat.BINARY;
			ldr.addEventListener(Event.COMPLETE, onLoadSuccess);
			ldr.load(wrapper.request);
			
			commentTextInstance = null;
			commentText = null;
			
			ownerTextInstance = null;
			ownerText = null;
		}
		private static function onLoadSuccess(e:Event):void
		{
			feedbackMode = false;
			
			resultContainer.removeChild(snapshot);
			snapshot = null;
			
			stage.removeChild(ASFeedBack.instance);
			
			disabler.visible = false;
			
			
			trace(e.target.data);
		}
		private static function htmlEscape(str:String):String
		{
			return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}
	}
}
//Class lock
class SingletonLock {}
