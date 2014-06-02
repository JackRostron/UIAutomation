var target = UIATarget.localTarget();
var app = target.frontMostApp().mainWindow();

var running = 0

var currentVersion = target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITEFILEUPDATEDBASHSCRIPT"], 90);
var loopVersion;
var command;

UIATarget.onAlert = function onAlert(alert) {
	return true;
}

var initialNotify = target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITESIMULATORLAUNCHCOMPLETE"], 10);

while (running == 0) {
    
    loopVersion = target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITEFILEUPDATEDBASHSCRIPT"], 10);
	
    if (parseInt(currentVersion.stdout) < parseInt(loopVersion.stdout)){
		//UIALogger.logMessage("Triggered File Update")
		command = target.host().performTaskWithPathArgumentsTimeout("/bin/cat", ["IATSUITEOUTPUTFILEPATH"], 10);
		//eval(command.stdout);
		UIALogger.logMessage(command.stdout);
        UIATarget.localTarget().logElementTree();
		currentVersion = loopVersion;
        
        target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITELISTTREECOMPLETE"], 10);
	}

	target.delay(1);
}