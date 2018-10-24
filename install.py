import os, getpass, shutil

user = getpass.getuser()
DIR = "/home/" + user + "/.setcpu"
FILE = DIR + "/config"
CPU = DIR + "/cpu"
rm = shutil.rmtree

if not os.path.exists("/usr/bin/cpupower"):
    os.system("sudo pacman -S cpupower")
if not os.path.exists(DIR):
    print('Installing setcpu...')
    os.mkdir(DIR)
    with open(FILE, "x+") as configfile:
        configfile.write('alias powersave="setcpu -g powersave"\nalias conservative="setcpu -g conservative"\nalias ondemand="setcpu -g ondemand"\nalias performance="setcpu -g performance"\nalias schedutil="setcpu -g schedutil"')
    with open(CPU, "x+") as cpulist:
        cpulist.write('ls /sys/devices/system/cpu/ | grep "cpu[0-9]"')
    os.system('LLEHS=$(echo $SHELL|grep -oE "zsh|bash");if [ $LLEHS == bash ];then echo "source ' + FILE + ';alias setcpu=\"bash ' + DIR + '/setcpu\"" >> ~/.bashrc;source ~/.bashrc;elif [ $LLEHS == zsh ]; then echo "source ' + FILE + ';alias setcpu=\"bash ' + DIR + '/setcpu\"" >> ~/.zshrc;source ~/.zshrc;fi')
    print('Done!')
