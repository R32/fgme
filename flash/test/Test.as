package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	import Gme;
	
	/**
	 * Copyright hycro ( http://wonderfl.net/user/hycro )
	 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
	 * Downloaded from: http://wonderfl.net/c/5ddY
	 */
	
	//----------------------------------
	// Music by "SHW"(http://shw.in/)
	//----------------------------------
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;	
	import flash.events.IOErrorEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[SWF(width=465,height=465,backgroundColor=0x000000,frameRate=30)]
	
	public class Test extends Sprite
	{
		
		[Embed(source="../../test/batman.nsf",mimeType="application/octet-stream")]
		private var Byte_batman:Class;
		
		private var _leftBars:Vector.<Bar>;
		private var _rightBars:Vector.<Bar>;		
		private var _canvas:Bitmap;
		private var _colorTransform:ColorTransform = new ColorTransform(.9, .9, .9);
		private var _filter:BitmapFilter = new BlurFilter(8, 4);
		
		
		
		private var gme:Gme;
		
		public function Test(){
			super();	
			// 左右のバーを作成
			_leftBars = new Vector.<Bar>();
			_rightBars = new Vector.<Bar>();
			var bar:Bar;
			for (var i:uint = 0; i < 64; i++){
				// 左
				bar = new Bar(0xffffff, false);
				bar.y = i * (Bar.LENGTH + Bar.MARGIN) + Bar.LENGTH + 10; // 回転後にずれるため Bar.LENGTH だけ足す
				bar.x = (Bar.LENGTH + Bar.MARGIN) * Bar.NUM_RECT;
				_leftBars.unshift(bar);
				
				// 右
				bar = new Bar(0xffffff, false);
				bar.y = i * (Bar.LENGTH + Bar.MARGIN) + 10;
				bar.x = Math.floor(stage.stageWidth / 2) + 1;
				_rightBars.unshift(bar);
			}
			// 描画用Bitmapの作成
			_canvas = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0xff000000));
			addChild(_canvas);
			
			
			gme = new Gme();
			gme.init("nsf");
			gme.load(new Byte_batman());		
			gme.track = 1;
			gme.play();
			
			var info:Object = gme.trackInfo(20);
			trace("track count: " + gme.trackCount);
			for(var k:String in info){
				trace(k + "--> " + info[k]);
			}
			true && addEventListener(Event.ENTER_FRAME, loop);
		}
		
		/**
		 * メインループ
		 *
		 * @private
		 */
		private function loop(evt:Event):void
		{
			var data:ByteArray = new ByteArray();
			var matrix:Matrix;
			var rect:Rectangle = new Rectangle(0, 0, _canvas.width, _canvas.height);
			var dp:Point = new Point(0, 0);
			
			_canvas.bitmapData.lock();
			
			// スペクトラムの取得
			SoundMixer.computeSpectrum(data, true);
			
			// 色調整
			var d:Number = Math.max(gme.sndChannel.rightPeak, gme.sndChannel.leftPeak) * .02;
			_colorTransform.redMultiplier += (.5 - Math.random()) * d;
			_colorTransform.blueMultiplier += (.5 - Math.random()) * d;
			_colorTransform.greenMultiplier += (.5 - Math.random()) * d;
			_colorTransform.redMultiplier = Math.min(Math.max(_colorTransform.redMultiplier, .8), 1);
			_colorTransform.blueMultiplier = Math.min(Math.max(_colorTransform.blueMultiplier, .8), 1);
			_colorTransform.greenMultiplier = Math.min(Math.max(_colorTransform.greenMultiplier, .8), 1);
			_canvas.bitmapData.colorTransform(rect, _colorTransform);
			
			// ぼかしフィルター
			_canvas.bitmapData.applyFilter(_canvas.bitmapData, rect, dp, _filter);
			
			// 左チャンネルの描画
			for (var i:uint = 0; i < 64; i++)
			{
				_leftBars[i].setLevel(Math.sqrt((data.readFloat() + data.readFloat() + data.readFloat() + data.readFloat()) / 4));
				matrix = new Matrix();
				matrix.rotate(Math.PI)
				matrix.translate(_leftBars[i].x, _leftBars[i].y);
				_canvas.bitmapData.draw(_leftBars[i], matrix);
			}
			
			// 右チャンネルの描画
			for (i = 0; i < 64; i++)
			{
				_rightBars[i].setLevel(Math.sqrt((data.readFloat() + data.readFloat() + data.readFloat() + data.readFloat()) / 4));
				matrix = new Matrix();
				matrix.translate(_rightBars[i].x, _rightBars[i].y);
				_canvas.bitmapData.draw(_rightBars[i], matrix);
			}
			
			_canvas.bitmapData.unlock();
		}
	}

}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

class Bar extends Sprite
{
	// 四角の数
	public static const NUM_RECT:uint = 33;
	// 四角の大きさ
	public static const LENGTH:uint = 5;
	// マージン
	public static const MARGIN:uint = 2;
	// 最大時の長さ
	public static const MAX_LENGTH:uint = (LENGTH + MARGIN) * NUM_RECT - MARGIN;
	
	// Bar を構成する四角形
	private var _rects:Vector.<Bitmap>;
	
	/**
	 * コンストラクタ
	 */
	public function Bar(color:uint = 0xffffff, gradient:Boolean = false)
	{
		var r:uint = (color & 0x00ff0000) >> 16;
		var g:uint = (color & 0x0000ff00) >> 8;
		var b:uint = (color & 0x000000ff);
		
		_rects = new Vector.<Bitmap>;
		for (var i:uint = 0; i < NUM_RECT; i++)
		{
			var grad:Number = Math.min(Math.sqrt((i + 1) / NUM_RECT + .4), 1)
			var c:uint = (r * grad << 16) | (g * grad << 8) | b * grad;
			var bmp:Bitmap = new Bitmap(new BitmapData(LENGTH, LENGTH, false, gradient ? c : color));
			
			bmp.x = i * (LENGTH + MARGIN);
			_rects[i] = bmp;
			addChild(bmp);
			bmp.visible = false;
		}
	}
	
	/**
	 * レベルを設定
	 *
	 * @param level 0〜1の範囲の実数値
	 */
	public function setLevel(level:Number):void
	{
		level = Math.min(NUM_RECT, Math.floor(NUM_RECT * level));
		
		for (var i:uint = 0; i < NUM_RECT; i++)
		{
			_rects[i].visible = i < level;
		}
	}
}