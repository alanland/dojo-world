require([
    "dijit/layout/TabContainer",
    "dijit/layout/ContentPane"
], function (TabContainer,ContentPane) {
    tc = new TabContainer({
        style: "width: 500px; height: 200px;", tabPosition: "left-h",
        useMenu:true
    }, 'tabs');
    var cp1 = new ContentPane({title: "test pane 1", closable: true}),
        cp2 = new ContentPane({title: "test pane 2", href: "doc0.html"});

    tc.addChild(cp1);
    tc.addChild(cp2);
    tc.startup();
});