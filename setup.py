from os import system as sys, path, mkdir, chdir, remove;import getpass
user = getpass.getuser();gitDIR = '/home/' + user + '/git'
home = '/home/' + user;zshrc = home + '/.zshrc'
gitssh = '/home/' + user + '/.ssh/id_rsa.pub'
setup = '/home/' + user + '/.setup';cursors = home + '/.curs'
name = "looneytkp"; email = 'sgm4kv@gmail.com'
token = 'fa981fd9704d8f8c0dbd3b66601cde87b123314e'
pacman = 'sudo pacman -Syy && sudo pacman -S --needed git zsh powerline-fonts youtube-dl android-tools telegram-desktop gedit-code-assistance gedit-plugins shellcheck python-pip'

#git
def git():
    def createSSH():
        sys('git config --global user.name ' + name + '; git config --global user.email ' + email + '; ssh-keygen -t rsa -b 4096 -C ' + email + '; $(ssh-agent -s); ssh-add ~/.ssh/id_rsa')
        with open(gitssh, 'r') as ssh:
            ssh = ssh.read().replace('\n', '')
            sys('curl -s -u ' + name + ':' + token + ' -H "Accept: application/vnd.github.v3+json" -H "Content-Type: application/json" -d \'{"title": "arch", "key": "' + ssh + '" }\' -X POST https://api.github.com/user/keys -o .gitOUT.txt || echo "\nNo internet connection"')

    if "git" in open(setup).read():
        print('git is already set up')
    else:
        if not path.exists(gitDIR):
            mkdir(gitDIR);chdir(gitDIR)
            sys('git init;curl -is -u "' + name + ':' + token + '" -H "Accept: application/json" -H "Content-Type: application/json" -X GET https://api.github.com/user/keys -o .gitOUT.txt || echo "\nNo internet connection"')
        if "Bad credentials" in open('.gitOUT.txt').read():
            exit('Invalid token, update it.')
        elif not "ssh-rsa" in open('.gitOUT.txt').read():
            createSSH()
        elif "ssh-rsa" in open('.gitOUT.txt').read():
            sys('getID=$(grep -w "id" .gitOUT.txt|sed -e "s/.* //"|sed "s/,//"); curl -is -u ' + name + ':' + token + ' -H "Accept: application/vnd.github.v3+json" -H "Content-Type: application/json" -X DELETE https://api.github.com/user/keys/$getID -o .gitOUT.txt || echo "\nNo internet connection"')
            createSSH()
        sys('git clone git@github.com:looneytkp/Popcorn-Time.git; git clone git@github.com:looneytkp/scripts.git')
        remove(".gitOUT.txt"); chdir(home)
        with open(setup, 'a') as txt:
            txt.write("git\n")

#popcorntime
def popcorntime():
    if "popcorntime" in  open(setup).read():
        return "popcorntime is already set up."
    else:
        sys("wget -qnc 'https://github.com/looneytkp/popcorntime/archive/master.zip' && unzip -oq ma*ip && yes|./Po*er/p*e && rm -rf ma*ip Po*er")
        with open(setup, 'a') as txt:
            txt.write("popcorntime\n")

#zsh
def zsh():
    if "zsh" in  open(setup).read():
        return "zsh is already set up."
    else:
        sys('chsh -s $(which zsh); gnome-session-quit --no-prompt')
        with open(setup, 'a') as txt:
            txt.write("zsh\n")

#ohmyzsh
def ohmyzsh():
    if "ohmyzsh" in  open(setup).read():
        return "ohmyzsh is already set up."
    else:
        sys('sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"')
        themes = ['peepcode', 'suvash', 'amuse', 'steeef', 'smt', 'mira', 'kiwi', 'itchy', 'pure', 'mortalscumbag', 'candy-kingdom', 'intheloop', 'trapd00r', 'refined', 'frisk', 'tjkirch', 'crcandy', 'fino-time', 'bureau', 'dst', 'frontcube', 're5et', 'dstufft', 'blinks', 'ysx', 'juanghurtado', 'pmcgee', 'rgm', 'emotty', 'avit', '3den', 'adben', 'rixius', 'junkfood', 'josh', 'fox']
        chdir('/home/' + user + '/.oh-my-zsh/themes')
        for x in themes:
            if path.exists(x + '.zsh-theme'):
                remove(x + '.zsh-theme')
        sys('wget -qc --show-progress --no-clobber http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme https://raw.githubusercontent.com/tylerreckart/hyperzsh/master/hyperzsh.zsh-theme http://raw.github.com/zakaziko99/agnosterzak-ohmyzsh-theme/master/agnosterzak.zsh-theme || if [ $? != 0 ]; then echo -e "- No internet connection\\n" && exit;fi')
        with open(setup, 'a') as txt:
            txt.write("ohmyzsh\n")

def rc():
    if "rc" in  open(setup).read():
        return "rc is already set up."
    else:
        with open(zshrc, 'a') as rc:
            rc.write('DISABLE_UPDATE_PROMPT=true\nalias update-grub="grub-mkconfig -o /boot/grub/grub.cfg"\nalias charge="sudo usbmuxd -u -U usbmux"')
        sys('sed -i \'s/="robbyrussell"/="random"/\' ~/.zshrc && sed -i \'s/echo/#echo/\' ~/.oh-my-zsh/oh-my-zsh.sh')
        with open(setup, 'a') as txt:
            txt.write("rc\n")

def cursors():
    if "cursors" in  open(setup).read():
        return "cursors is already set up."
    else:
        if not path.exists(cursors):
            mkdir(cursors)
        chdir(cursors)
        print('Downloading & installing:')
        sys('wget -qc --show-progress -nc "https://www.dropbox.com/s/kt3m9oil3ya1pae/hacked.tgz" "https://www.dropbox.com/s/jwjtk4ay1x1k6cn/obsidian.tgz" "https://www.dropbox.com/s/4zkuwk6xsishnoc/snow.tgz" "https://www.dropbox.com/s/hb1ivyrzyv8rz9o/capitaine.tar.gz" "https://www.dropbox.com/s/fxz6ecdmq6bj21t/theDOT.tar.xz"')









text = open(setup, 'a+')
text.close()
#sys(pacman)
