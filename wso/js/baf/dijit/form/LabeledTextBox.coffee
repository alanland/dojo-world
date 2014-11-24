define [
    'dojo/_base/declare'
    'dojo/dom-construct'
    'dijit/_WidgetBase'
    'dijit/_TemplatedMixin'
    'dijit/form/TextBox'
    'dojo/text!./templates/LabeledTextBox.html'
], (declare, domCons, _WidgetBase,_TemplateMixin, TextBox, template)->
    declare [_WidgetBase,_TemplateMixin],
        label: ''
        templateString: template
        postCreate: ->
            @inherited arguments
            domCons.place new TextBox().domNode, @domNode, 'last'

