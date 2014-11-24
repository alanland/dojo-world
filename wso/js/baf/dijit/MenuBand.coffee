define [
    'dojo/_base/declare',
    'dojo/_base/lang',
    'dojo/_base/array'
    'dijit/form/Button',
    'dijit/form/DropDownButton',
    'dijit/Toolbar',
    'dijit/ToolbarSeparator',
    'dijit/MenuItem',
    'dijit/MenuSeparator',
    'dijit/PopupMenuItem',
    'baf/command/commandType',
    'baf/dijit/Submenu'
], (declare, lang, array, Button, DropDownButton, Toolbar, ToolbarSeparator, #
    MenuItem, MenuSeparator, PopupMenuItem, commandType, Submenu)->
    declare Toolbar,
        constructor: (args)->
            this.commandItemStore = args.commandItemStore;
            this.menu = args.menu;
            this.sort = args.sort || (lhs, rhs) ->
                return lhs.order - rhs.order;

        postCreate: ->
            this.inherited(arguments);
            this._build();

        reset: (menu) ->
            this.menu = menu;
            this._build();

        destroy: ->
            dojo.forEach(this.getChildren(), (child) ->
                this.removeChild(child);
                child.destroy();
            , this);
            this.inherited(arguments);

        _prepareList: (menu) ->
            # summary:
            #       在把高层对象插入到工具条之前，先对其进行存储和分组，分割符号
            #       被自动的插入不同组之间
            contents = [];
            for p of menu when menu.hasOwnProperty(p)
                contents.push(this.commandItemStore.get(p));
            contents.sort(this.sort);

            result = [];
            if (contents.length)
                result = [contents[0]];
                group = contents[0].group;
                for i in [1..contents.length-1]
                    content = contents[i]
                    if content.group != group
                        result.push({id: "separator", type: commandType.separator})
                        group = content.group
                    result.push(content)
            result

        _build: ->
            contents = @_prepareList @menu
            @_publish ['beforeDisplay', this, contents]
            array.forEach contents, (commandItem)->
                @_publish ['beforeDisplayItem', this, commandItem]
                item = null
                switch commandItem.type
                    when commandType.command
                        item = new Button
                            label: commandItem.text
                            onClick: lang.hitch this, '_exec', commandItem
                    when commandType.separator
                        item = new ToolbarSeparator()
                    when commandType.submenu, commandType.menu
                        popup = new Submenu()
                        popup.onOpenSubmenu = lang.hitch(
                            @, @_onOpenDropDown,
                            @menu[commandItem.id], popup)
                        item = new DropDownButton {
                            label: commandItem.text
                            dropDown: popup
                        }
                    else break
                @addChild item if item
            , this

        _onOpenDropDown: (menuObject, menu)->
            contents = @_prepareList(menuObject)
            dojo.publish(["beforeDisplaySubmenu", this, contents])
            array.forEach contents, (commandItem)->
                dojo.publish(["beforeDisplayItem", this, commandItem])
                item = null
                switch commandItem.type
                    when commandType.command
                        item = new MenuItem
                            label: commandItem.text
                            onClick: lang.hitch @, '_exec', commandItem
                    when commandType.separator
                        item = new MenuSeparator()
                    when commandType.submenu,commandType.menu
                        popup = new Submenu()
                        popup.onOpenSubmenu = lang.hitch(
                            this,
                            this._onOpenDropDown,
                            menuObject[commandItem.id],
                            popup);
                        item = new PopupMenuItem({
                            label: commandItem.text,
                            popup: popup
                        })
                    else break
                menu.addChild item if item

        _exec: (commandItem)->
            @_publish ['execute', this, commandItem]

        _publish: (args)->
            dojo.publish 'baf.MenuBand', args


