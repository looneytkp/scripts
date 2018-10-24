#android-tools
#git
#zsh
#youtube-dl
#python-pip
#beautifulsoup
#shellcheck
#gedit-code-assistance
#gedit-plugins

# e96f8d03cd1192d7b45225816c1cfbcb4c8ee495

#chsh -s $(which zsh)
#gnome-session-quit
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

from os import system as sys, path, mkdir
import getpass
user = getpass.getuser()

pacman = {'/usr/bin/git':'git', '/usr/bin/zsh':'zsh', '/usr/bin/youtube-dl':'youtube-dl', '/usr/bin/adb':'android-tools', '/usr/bin/telegram-desktop':'/usr/bin/telegram-desktop', '/usr/lib/gedit/plugins/codeassistance.plugin':'gedit gedit-code-assistance gedit-plugins', '/usr/bin/shellcheck':'shellcheck', '/usr/bin/python-pip':'python-pip'}
#pacman = 'sudo pacman -Syy && sudo pacman -S --needed git zsh youtube-dl android-tools'


class run():
    def install_pkg(pkg):
            print("\nInstalling %s\n" % pkg)
            sys('sudo pacman -S --needed ' + pkg)
#git
#if not path.exists('/usr/bin/git'):
#    run.install_pkg('git')
#    mkdir()
#    name = "looneytkp"; email = 'sgm4kv@gmail.com'
#    sys('git config --global user.name ' + name)
#    sys('git config --global user.email ' + email)
#    sys('git config --global color.ui true')
#    sys('ssh-keygen -t rsa -b 4096 -C ' + email + '; $(ssh-agent -s')
#    sys('ssh-add ~/.ssh/id_rsa')
