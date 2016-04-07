function SUCCESS = checkAndDelete_dir(dirName);
[SUCCESS,MESSAGE,MESSAGEID] = rmdir(dirName,'s');