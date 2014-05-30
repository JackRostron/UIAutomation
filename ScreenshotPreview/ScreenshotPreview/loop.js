var target = UIATarget.localTarget();
var app = target.frontMostApp().mainWindow();

var running = 0

var currentVersion = target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITEFILEUPDATEDBASHSCRIPT"], 90);
var loopVersion;
var command;

while ( running == 0 ) {
	//UIALogger.logMessage("looped");
	loopVersion = target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["IATSUITEFILEUPDATEDBASHSCRIPT"], 10);
	//UIALogger.logMessage(currentVersion.stdout);
	//UIALogger.logMessage(loopVersion.stdout);

	if ( parseInt(currentVersion.stdout) < parseInt(loopVersion.stdout) ){
		//UIALogger.logMessage("Triggered File Update")
		command = target.host().performTaskWithPathArgumentsTimeout("/bin/cat", ["IATSUITEIATUTILITIESJAVASCRIPT"], 10);
		//eval(command.stdout);
		UIALogger.logMessage(command.stdout);
		currentVersion = loopVersion;
	}

	target.delay(1);
}