package feathers.tests
{
	import feathers.controls.ImageLoader;
	import feathers.utils.textures.TextureCache;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	import starling.events.Event;

	public class ImageLoaderTests
	{
		private var _loader:ImageLoader;

		[Before]
		public function prepare():void
		{
			this._loader = new ImageLoader();
			TestFeathers.starlingRoot.addChild(this._loader);
			this._loader.validate();
		}

		[After]
		public function cleanup():void
		{
			this._loader.removeFromParent(true);
			this._loader = null;

			Assert.assertStrictlyEquals("Child not removed from Starling root on cleanup.", 0, TestFeathers.starlingRoot.numChildren);
		}

		[Test(async)]
		public function testCompleteEvent():void
		{
			var completeDispatched:Boolean = false;
			this._loader.addEventListener(Event.COMPLETE, function():void
			{
				completeDispatched = true;
			});
			this._loader.source = "fixtures/red100x100.png";
			this._loader.validate();
			Async.delayCall(this, function():void
			{
				Assert.assertTrue("Event.COMPLETE not dispatched by ImageLoader after loading valid URL.", completeDispatched);
			}, 200);
		}

		[Test(async)]
		public function testIOErrorEvent():void
		{
			var ioErrorDispatched:Boolean = false;
			this._loader.addEventListener(Event.IO_ERROR, function():void
			{
				ioErrorDispatched = true;
			});
			this._loader.source = "fixtures/fake.png";
			this._loader.validate();
			Async.delayCall(this, function():void
			{
				Assert.assertTrue("Event.IO_ERROR not dispatched by ImageLoader after loading invalid URL.", ioErrorDispatched);
			}, 200);
		}

		[Test(async)]
		public function testResize():void
		{
			var resizeDispatched:Boolean = false;
			var loader:ImageLoader = this._loader;
			loader.addEventListener(Event.RESIZE, function():void
			{
				resizeDispatched = true;
			});
			loader.source = "fixtures/red100x100.png";
			loader.validate();
			Async.delayCall(this, function():void
			{
				Assert.assertTrue("Event.RESIZE not dispatched by ImageLoader after loading URL.", resizeDispatched);
				Assert.assertStrictlyEquals("ImageLoader width property not changed after loading URL.", 100, loader.width);
				Assert.assertStrictlyEquals("ImageLoader height property not changed after loading URL.", 100, loader.height);
				Assert.assertStrictlyEquals("ImageLoader minWidth property not changed after loading URL.", 100, loader.minWidth);
				Assert.assertStrictlyEquals("ImageLoader minHeight property not changed after loading URL.", 100, loader.minHeight);
			}, 200);
		}

		[Test(async)]
		public function testResizeWithNewSource():void
		{
			var loader:ImageLoader = this._loader;
			loader.addEventListener(Event.COMPLETE, function():void
			{
				loader.removeEventListener(Event.COMPLETE, arguments.callee);
				loader.source = "fixtures/green200x200.png";
				loader.validate();
			});
			loader.source = "fixtures/red100x100.png";
			loader.validate();
			Async.delayCall(this, function():void
			{
				Assert.assertStrictlyEquals("ImageLoader width property not changed after loading second URL.", 200, loader.width);
				Assert.assertStrictlyEquals("ImageLoader height property not changed after loading second URL.", 200, loader.height);
				Assert.assertStrictlyEquals("ImageLoader minWidth property not changed after loading second URL.", 200, loader.minWidth);
				Assert.assertStrictlyEquals("ImageLoader minHeight property not changed after loading second URL.", 200, loader.minHeight);
			}, 200);
		}

		[Test(async)]
		public function testScaleFactor():void
		{
			var loader:ImageLoader = this._loader;
			loader.scaleFactor = 2;
			loader.source = "fixtures/green200x200.png";
			loader.validate();
			Async.delayCall(this, function():void
			{
				Assert.assertStrictlyEquals("ImageLoader originalSourceWidth property not changed after loading URL.", 200, loader.originalSourceWidth);
				Assert.assertStrictlyEquals("ImageLoader originalSourceHeight property not changed after loading URL.", 200, loader.originalSourceHeight);
				Assert.assertStrictlyEquals("ImageLoader width property not changed after loading URL.", 100, loader.width);
				Assert.assertStrictlyEquals("ImageLoader height property not changed after loading URL.", 100, loader.height);
				Assert.assertStrictlyEquals("ImageLoader minWidth property not changed after loading URL.", 100, loader.minWidth);
				Assert.assertStrictlyEquals("ImageLoader minHeight property not changed after loading URL.", 100, loader.minHeight);
			}, 200);
		}

		[Test(async)]
		public function testCacheRetainCountOnComplete():void
		{
			var textureCache:TextureCache = new TextureCache(2);
			var source:String = "fixtures/green200x200.png";
			var loader:ImageLoader = this._loader;
			loader.source = source;
			loader.textureCache = textureCache;
			var retainCount:int = 0;
			loader.addEventListener(Event.COMPLETE, function():void
			{
				retainCount = textureCache.getRetainCount(source);
			});
			loader.validate();
			Async.delayCall(this, function():void
			{
				textureCache.dispose();
				Assert.assertStrictlyEquals("ImageLoader textureCache retain count incorrect after load complete.", 1, retainCount);
			}, 200);
		}

		[Test(async)]
		public function testReleaseTextureFromCacheAfterSetSourceToNull():void
		{
			var textureCache:TextureCache = new TextureCache(2);
			var source:String = "fixtures/green200x200.png";
			var loader:ImageLoader = this._loader;
			loader.source = source;
			loader.textureCache = textureCache;
			loader.validate();
			Async.delayCall(this, function():void
			{
				loader.source = null;
				var retainCount:int = textureCache.getRetainCount(source);
				textureCache.dispose();
				Assert.assertStrictlyEquals("ImageLoader textureCache retain count incorrect after set source to null.", 0, retainCount);
			}, 200);
		}
	}
}
