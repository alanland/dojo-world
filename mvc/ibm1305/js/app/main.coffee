define [
    'dijit/layout/TabContainer'
    'dojox/layout/ContentPane'
    'dojo/domReady!'
], (TabContainer, ContentPane)->
    tc = new TabContainer
        style: "height: 500px; width: 100%;"
        tabPosition: "left-h"
        'container'

    tc.addChild new ContentPane title: "AllInOne", href: "AllInOne.html"
    tc.addChild new ContentPane title: "simpleView",href: "simpleView.html"
    tc.addChild new ContentPane title: "at", href: "at.html"
    tc.addChild new ContentPane title: "ModelRefController", href: "ModelRefController.html"
    tc.addChild new ContentPane title: "EditModelRefController", href: "EditModelRefController.html"
    tc.addChild new ContentPane title: "StoreRefController", href: "StoreRefController.html"
    tc.addChild new ContentPane title: "EditStoreRefController", href: "EditStoreRefController.html"
    tc.addChild new ContentPane title: "EditModelRefController", href: "EditModelRefController.html"

    tc.startup();

