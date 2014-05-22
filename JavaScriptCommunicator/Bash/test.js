var target = UIATarget.localTarget();

//Communicate to Objective-C
//target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["/Users/JackRostron/Downloads/commobjc.sh"], 999);

//Listen back from Objective-C
var file_contents = target.host().performTaskWithPathArgumentsTimeout("/bin/cat", ["./wibble.txt"], 90);

if (file_contents.stderr) {
	UIALogger.logMessage("ERROR");
} else {
	UIALogger.logMessage(file_contents.stdout);
}

if (file_contents.stdout == "ListTree") {
	target.logElementTree();
	target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["/Users/JackRostron/Downloads/commobjc.sh"], 3);
}