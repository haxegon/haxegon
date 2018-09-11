package haxegon.starlingmods;

import openfl.display3D.Context3DCompareMode;
import openfl.display3D.Context3DTriangleFace;
import openfl.geom.Rectangle;
import openfl.geom.Vector3D;
import starling.core.Starling;
import starling.rendering.Painter;
import starling.rendering.RenderState;
import starling.textures.RenderTexture;
import starling.textures.Texture;

class HaxegonRenderTexture extends RenderTexture {
    private var haxegonpreviousRenderTarget:Texture;
    private var thisbundlepainer:Painter;
    private static var sClipRect:Rectangle = new Rectangle();

    public function bundlelock(antiAliasing:Int = 0, cameraPos:Vector3D=null):Void {   
        thisbundlepainer = Starling.current.painter;
        var state:RenderState = thisbundlepainer.state;

        if (!Starling.current.contextValid) return;

        // switch buffers
        if (isDoubleBuffered) {
            var tmpTexture:Texture = _activeTexture;
            _activeTexture = _bufferTexture;
            _bufferTexture = tmpTexture;
            _helperImage.texture = _bufferTexture;
        }

        thisbundlepainer.pushState();

        var rootTexture:Texture = _activeTexture.root;
        state.setProjectionMatrix(0, 0, rootTexture.width, rootTexture.height,
            width, height, cameraPos);

        // limit drawing to relevant area
        sClipRect.setTo(0, 0, _activeTexture.width, _activeTexture.height);

        state.clipRect = sClipRect;
        state.setRenderTarget(_activeTexture, true, antiAliasing);

        thisbundlepainer.prepareToDraw();
        thisbundlepainer.context.setStencilActions( // should not be necessary, but fixes mask issues
            Context3DTriangleFace.FRONT_AND_BACK, Context3DCompareMode.ALWAYS);

        if (isDoubleBuffered || !isPersistent || !_bufferReady)
            thisbundlepainer.clear();

        // draw buffer
        if (isDoubleBuffered && _bufferReady)
            _helperImage.render(thisbundlepainer);
        else
            _bufferReady = true;
        
        _drawing = true;
    }

    public function bundleunlock():Void {
        _drawing = false;
        thisbundlepainer.popState();
	}
}