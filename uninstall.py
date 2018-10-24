import os, getpass, shutil

user = getpass.getuser()
DIR = "/home/" + user + "/.setcpu"
FILE = DIR + "/config"
CPU = DIR + "/cpu"
rm = shutil.rmtree

if not os.path.exists(DIR):
    exit('setcpu is not installed\\nRun "bash setcpu -i" to install.')
else:
    u = str(input("uninstall setcpu? Y/n > "))
    if u == "y" or "Y":
        os.system('LLEHS=$(echo $SHELL|grep -oE "zsh|bash");if [ $LLEHS == bash ]; then rc=~/.bashrc;elif [ $LLEHS == zsh ]; then rc=~/.zshrc;fi;if grep -q "setcpu" $rc; then a=$(grep -n "setcpu" $rc|sed "s/:.*//");sed -i "$a"d $rc;fi')
        rm(DIR)
        print("done!")
    else:
        exit()
