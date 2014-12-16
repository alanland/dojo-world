define [
    'dojo/_base/declare',
    'dojo/_base/array',
    'dijit/Menu'
], (declare, array, Menu) ->
    declare Menu,
        onOpen: ->
            this.onOpenSubmenu();
            this.inherited(arguments);
        onClose: ->
            this.inherited(arguments);
            array.forEach(this.getChildren(), (child) ->
                this.removeChild(child);
                child.destroy();
            , this);

