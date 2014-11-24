define ->
    wsoDefinition: [
        {
            tid: 1,
#            require: []
            children: [
                ['baf/dijit/form/LabeledTextBox', {
#                    value: 'testvalue'
                    placeHolder: "type in your name"
                    name: 'thename'
                    label: 'Name'
                }]
                ['baf/dijit/form/LabeledTextBox', {
#                    value: 'testvalue'
                    placeHolder: "type in your name"
                    name: 'thename'
                    label: 'Name'
                }]
                ['baf/dijit/form/LabeledTextBox', {
#                    value: 'testvalue'
                    placeHolder: "type in your name"
                    name: 'thename'
                    label: 'Name'
                }]
                ['baf/dijit/form/LabeledTextBox', {
#                    value: 'testvalue'
                    placeHolder: "type in your name"
                    name: 'thename'
                    label: 'Name'
                }]
            ]
        },
        {
            tid: 11,
            size: ["51em", "25em"],
            "class": "crf",
#            require: ["baf/dijit/StaticText"],
            children:
                tl: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "tl",
                    text: "1top-left"
                }],
                tc: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "tc",
                    text: "top-center"
                }],
                tr: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "tr",
                    text: "top-right"
                }],
                cl: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "cl",
                    text: "center-left"
                }],
                cc: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "cc",
                    text: "center-center"
                }],
                cr: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "cr",
                    text: "center-right"
                }],
                bl: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "bl",
                    text: "bottom-left"
                }],
                bc: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "bc",
                    text: "bottom-center"
                }],
                br: ["baf/dijit/StaticText", {
                    style: "background-color: #D0D0D0;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "br",
                    text: "bottom-right"
                }]
        },
        {
            tid: 2,
            size: ["51em", "25em"],
            "class": "crf",
            children:
                tl: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "tl",
                    text: "2top-left"
                }],
                tc: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "tc",
                    text: "top-center"
                }],
                tr: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "tr",
                    text: "top-right"
                }],
                cl: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "cl",
                    text: "center-left"
                }],
                cc: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "cc",
                    text: "center-center"
                }],
                cr: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "cr",
                    text: "center-right"
                }],
                bl: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "1em",
                        w: "10em"
                    q: "bl",
                    text: "bottom-left"
                }],
                bc: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "12em",
                        w: "10em"
                    q: "bc",
                    text: "bottom-center"
                }],
                br: ["baf/dijit/StaticText", {
                    style: "border: 1px solid black;",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "23em",
                        w: "10em"
                    q: "br",
                    text: "bottom-right"
                }]
        },
        {
            tid: 3,
            size: ["51em", "25em"],
            "class": "crf",
            children:
                tl: ["baf/dijit/StaticText", {
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "1em",
                        w: "13em"
                    "class": "s1",
                    q: "tl",
                    text: "3top-left"
                }]
        },
        {
            tid: 4,
            size: ["64em", "25em"],
            "class": "crf",
            children:
                tl: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "1em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "tl-major",
                    minor: "tl-minor",
                    majorQ: "tl",
                    minorQ: "tl"
                }],
                tc: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "22em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "tc-major",
                    minor: "tc-minor",
                    majorQ: "tc",
                    minorQ: "tc"
                }],
                tr: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "1em",
                        h: "5em",
                        l: "43em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "tr-major",
                    minor: "tr-minor",
                    majorQ: "tr",
                    minorQ: "tr"
                }],
                cl: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "1em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "cl-major",
                    minor: "cl-minor",
                    majorQ: "cl",
                    minorQ: "cl"
                }],
                cc: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "22em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "cc-major",
                    minor: "cc-minor",
                    majorQ: "cc",
                    minorQ: "cc"
                }],
                cr: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "7em",
                        h: "5em",
                        l: "43em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "cr-major",
                    minor: "cr-minor",
                    majorQ: "cr",
                    minorQ: "cr"
                }],
                bl: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "1em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "bl-major",
                    minor: "bl-minor",
                    majorQ: "bl",
                    minorQ: "bl"
                }],
                bc: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "22em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "bc-major",
                    minor: "bc-minor",
                    majorQ: "bc",
                    minorQ: "bc"
                }],
                br: ["baf/dijit/Pair", {
                    style: "border: 1px solid black",
                    posit:
                        t: "13em",
                        h: "5em",
                        l: "43em",
                        w: "20em"
                    stack: "h",
                    minorSize: "11em",
                    splitborder: "1px solid black",
                    major: "br-major",
                    minor: "br-minor",
                    majorQ: "br",
                    minorQ: "br"
                }]
        }
    ]