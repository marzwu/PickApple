package {

import com.greensock.plugins.TintPlugin;
import com.greensock.plugins.TweenPlugin;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.setTimeout;

import org.bellona.utils.UIUtils;

[SWF(width=800, height=600)]
public class Main extends Sprite {
    [Embed(source='assets/46-128.png')]
    private const APPLE:Class;

    [Embed(source='assets/basket.png')]
    private const BASKET:Class;

    [Embed(source='assets/undo.png')]
    private const RESET:Class;

    private const COUNT:int = 5;
    private const colors:Array = [0xff0000, 0x808000, 0x008000, 0x00ff00, 0x008080];

    private var apples:Array = [];
    private var baskets:Array = [];
    private var tf:TextField;
    private var pickedCount = 0;

    public function Main() {
        stage.scaleMode = StageScaleMode.NO_SCALE;

        TweenPlugin.activate([TintPlugin]);


        for (var i:int = 0; i < COUNT; i++) {
            createApple(i);
            createBasket(i);
        }

        var btnReset:Bitmap = new RESET;
        var s:Sprite = new Sprite();
        s.scaleX = s.scaleY = .5;
        s.x = 230;
        s.y = 500;
        s.addChild(btnReset);
        s.buttonMode = true;
        s.addEventListener(MouseEvent.CLICK, onResetClick);
        addChild(s);

        tf = new TextField();
        tf.selectable = false;
        tf.visible = false;
        tf.width = 500;
        tf.y = 270;
        tf.autoSize = TextFieldAutoSize.CENTER;
        addChild(tf);

        addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
        addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
        addEventListener(MouseEvent.MOUSE_UP, onMouse);
        addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
    }

    private function setTip(tip:String):void {
        tf.visible = true;
        tf.text = tip;
        setTimeout(function ():void {
                    tf.visible = false;
                },
                3000
        )
    }

    private function onResetClick(event:MouseEvent):void {
        reset();
    }

    private function onDoubleClick(event:MouseEvent):void {
        reset();
    }

    private function reset():void {
        for (var i:int = 0; i < apples.length; i++) {
            var target:Sprite = apples[i];
            target.x = 0;
            target.y = i * 110 + 30;
        }
        pickedCount = 0;
    }

    private function onMouse(e:MouseEvent):void {
        var target:Sprite = e.target as Sprite;
        if (!target)
            return;

        if (target.name.indexOf('apple') == -1) {
            return;
        }

        switch (e.type) {
            case MouseEvent.MOUSE_DOWN:
                target.parent.addChild(target);
                target.startDrag();
                break;
            case MouseEvent.MOUSE_MOVE:
                break;
            case MouseEvent.MOUSE_UP:
                target.stopDrag();
                var index:Number = parseInt(target.name.substr(target.name.length - 1));

                var dropTarget:DisplayObject = target.dropTarget;
                if (dropTarget is Bitmap)
                    dropTarget = dropTarget.parent;

                if (dropTarget && dropTarget.name.indexOf('basket') != -1 && target.name.substr(target.name.length - 1) == dropTarget.name.substr(dropTarget.name.length - 1)) {
                    target.parent.setChildIndex(target, 0);
                    UIUtils.centerToRect(target, dropTarget.getBounds(this));

                    pickedCount++;

                    if (pickedCount == COUNT) {
                        setTip('恭喜你，全部放到篮子里了');
                    } else {
                        setTip('成功放入了一个苹果');
                    }
                } else {
                    target.x = 0;
                    target.y = index * 110 + 30;

                    setTip('请把苹果放到对应的篮子里');
                }
                break;
        }
    }

    private function createBasket(index:int):void {
        var basketTemplate:Bitmap = new BASKET;

        var s:Sprite = new Sprite();
        s.mouseChildren = false;

        var bitmap:Bitmap = new Bitmap(basketTemplate.bitmapData);
        s.addChild(bitmap);

        var trans:ColorTransform = new ColorTransform();
        trans.redOffset = (colors[index] & 0xff0000) >> (8 + 8);
        trans.greenOffset = (colors[index] & 0x00ff00) >> ( 8);
        trans.blueOffset = (colors[index] & 0x0000ff) >> (0);
        s.transform.colorTransform = trans;
        addChild(s);

        s.name = 'basket' + index;
        s.x = 400;
        s.y = index * 110;

        baskets.push(s);
    }

    private function createApple(index:int):void {
        var appleTemplate:Bitmap = new APPLE;
        var appleBD:BitmapData = appleTemplate.bitmapData;

        var s:Sprite = new Sprite();
        s.mouseChildren = false;

        var bitmap:Bitmap = new Bitmap(appleBD);
        s.addChild(bitmap);
        s.scaleX = s.scaleY = .5;

        var trans:ColorTransform = new ColorTransform();
        trans.redOffset = (colors[index] & 0xff0000) >> (8 + 8);
        trans.greenOffset = (colors[index] & 0x00ff00) >> ( 8);
        trans.blueOffset = (colors[index] & 0x0000ff) >> (0);
        s.transform.colorTransform = trans;
        addChild(s);

        s.name = 'apple' + index;
        s.y = index * 110 + 30;
        s.buttonMode = true;

        apples.push(s);
    }
}
}
