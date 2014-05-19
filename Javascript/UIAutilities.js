var UIA = {

	testStart: function(name){
		UIALogger.logMessage("Starting Test:" + name);
	},

	testFinish: function(){
		UIATarget.localTarget().deactivateAppForDuration(10);
	},

	tree: function(){
		UIATarget.localTarget().logElementTree();
	},

	waitTap: function(element){
		target.pushTimeout(30);
		if ( element.checkIsValid() ) {
			for (var i = 0; i < 60; i++) {
				try{
					element.tap()
					return;
				}catch (e) {}
				target.delay(0.5);
			}
		}
		target.popTimeout();
	},

	waitVisible: function(element){
		target.pushTimeout(30);
		if ( element.checkIsValid() ) {
			for (var i = 0; i < 60; i++) {
				try{
					element.isVisible();
					return;
				}catch (e) {}
				target.delay(0.5);
			}
		}
		target.popTimeout();
	}
	
}