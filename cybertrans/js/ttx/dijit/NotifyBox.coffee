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

    # usage
#    new Notify({
#      msg: "<b>Success:</b> In 5 seconds i'll be gone",
#      type: "success"
#    });
#    new Notify({
#      msg: "<b>Oops!</b> A wild error appeared!",
#      type: "error",
#      position: "center"
#    });
#    new Notify({
#      type: "warning",
#      msg: "<b>Warning:</b> Be patient my friend.",
#      position: "left"
#    });
#    new Notify({
#      type: "info",
#      msg: "<b>Info:</b> Some info here.",
#      width: "all",
#      height: 100,
#      position: "center"
#    });
#    new Notify({
#      type: "error",
#      msg: "This error will stay here until you click it.",
#      position: "center",
#      width: 500,
#      height: 60,
#      autohide: false
#    });
#    new Notify({
#      type: "warning",
#      msg: "Opacity is cool!",
#      position: "center",
#      opacity: 0.8
#    });
#    new Notify({
#      type: "info",
#      msg: "Testing a multiline text. Testing, one, two.. yep.",
#      position: "center",
#      width: 100,
#      autohide: false,
#      multiline: true
#    });
#    new Notify({
#      type: "success",
#      msg: "Fade mode activated.",
#      position: "right",
#      fade: true
#    });
#    new Notify({
#      msg: "Customize with your favourite color!",
#      position: "left",
#      bgcolor: "#294447",
#      color: "#F19C65"
#    });
#    new Notify({
#      msg: "Customize the timeout!",
#      position: "left",
#      time: 1000
#    });

        to: null # internal 引用

        width: 300
        height: 40
        position: 'right'
        autohide: true
        msg: ''
        opacity: 1
        type: 'default'
        types: {
            0: 'success'
            success: 'success',
            1: 'error'
            error: 'error',
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
            @type = @types[@type]
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

