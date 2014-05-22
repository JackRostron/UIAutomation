#!/bin/bash

instruments -t /Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate /Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app -e UIASCRIPT ./test.js -e UIARESULTSPATH '~/Desktop/Results/'
#>> ./raw_results.txt