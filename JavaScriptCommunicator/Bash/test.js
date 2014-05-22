var target = UIATarget.localTarget();
target.host().performTaskWithPathArgumentsTimeout("/bin/bash", ["/Users/JackRostron/Downloads/commobjc.sh"], 999);