require([
    "dijit/form/TextBox"
], function (TextBox) {
    document.body.appendChild(new TextBox({value:'abc'}).domNode);
});