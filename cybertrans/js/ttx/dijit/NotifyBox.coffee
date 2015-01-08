define [
    'dojo/_base/declare'
    'dojo/_base/lang'
    "dojo/_base/array",
    'dojo/_base/fx'
    "dojo/dom-class",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "dojo/dom-construct",
    "dojo/fx",
    "dojo/on"
    'dijit/_WidgetBase'
], (declare, lang, array, bfx, domClass, domStyle, geo, domConstruct, fx, onn, _WidgetBase)->
    declare [_WidgetBase], {
        to: null

        width: 400
        height: 60
        position: 'right'
        autohide: true
        msg: ''
        opacity: 1
        type: 'default'
#        @domNode.id: "notifyBox"
        types: {
            error: 'error',
            success: 'success',
            info: 'info',
            warning: 'warning',
            default: 'default'
        }

        _validateConfig: ()->
            if(array.indexOf(["right", "left", "center"], @position) < 0)
                @position = undefined;
            if(@width)
                if(@width == 'all')
                    @width = screen.width - 60;
            if(@height)
                if(@height >= 100 && @height <= 0)
                    @height = undefined;
            if(array.indexOf(['error', 'success', 'info', 'warning', 'default'], @type) < 0)
                @type = 'default'

        postCreate: (config)->
            @_validateConfig();

            div = "<div id='" + @domNode.id + "'><p>#{@msg}</p></div>";
            clearInterval(to);
            node = @domNode
            domConstruct.place("<p>#{@msg}</p>", @domNode);
            domConstruct.place node, document.body
            domStyle.set(node, 'top', '10px');
            domStyle.set(node, 'height', @height + 'px')
            domStyle.set(node, 'width', @width + 'px')
            domStyle.set(node, 'opacity', @opacity)
            domClass.add(node, "notifyBox #{@type}")

            domStyle.set(node.children[0], 'line-height', @height + 'px');

            geomMixin = {};
            switch @position
                when 'right'
                    domStyle.set(node, 'right', parseInt(0 - (@width * 2)) + 'px');
                    geomMixin = {l: window.innerWidth - 10 - @width};
                when 'center'
                    domStyle.set(node, 'top', parseInt(0 - (@height + 10)) + 'px');
                    domStyle.set(node, 'left', ((window.innerWidth / 2) - parseInt(@width / 2)) + 'px');
                    geomMixin = {t: 10};
                when 'left'
                    domStyle.set(node, 'left', parseInt(0 - (@width * 2)) + 'px');
                    geomMixin = {l: 10};
                else
                    domStyle.set(node, 'left', ((window.innerWidth) + @width) + 'px');
                    geomMixin = {l: window.innerWidth - 10 - @width};
                    break;
            fxGeom = lang.mixin({t: 10}, geo.getMarginBox(node), geomMixin, {node: node});
            fxGeom.left = fxGeom.l;
            fxGeom.top = fxGeom.t;
            fx.slideTo(fxGeom).play();

            it = @
            onn(node, 'click', lang.hitch(it, 'dismiss'))
            if(@autohide == true)
                to = setTimeout(()->
                    it.dismiss();
                , 2000)
        dismiss: ->
            it = @
            clearInterval(@to)
            @destroyRecursive()
    }

