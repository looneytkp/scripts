#!/bin/bash
set -e
shopt -u nocasematch
cd ~/Downloads
execute(){
if [ -e .out ] && [ -e .txt ]; then rm .out .txt;fi
read -rp "$pixel: " link
if [[ "$link" == '' ]]; then
	echo "aborted";return
fi
fail=$(echo "connection failed" && return)
wget -k "$link" -q -O .txt || $fail
if [[ "$pixel" == "url" ]]; then
	if grep -qioE ".*\\.\\.\\/</a>" .txt; then
		grep -viE ".*\\.\\.\\/</a>" .txt > .txt2
		mv .txt2 .txt
	fi
	grep -ioE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:' > .out
elif [[ "$pixel" == 480p ]] || [[ "$pixel" == 720p ]] || [[ "$pixel" == 1080p ]]; then
	if ! grep -q "$pixel" .txt; then
		echo "error: cannot find $pixel";exit
	fi
	echo "$pixel"p > .out
	grep -ioE ".*$pixel.*</a>" .txt|sed 's:.*<a:<a:' >> .out
elif [[ "$pixel" == "sort" ]]; then
	if grep -qioE ".*480p.*</a>" .txt; then
		echo "480p" >> .out
		grep -ioE ".*480p.*</a>" .txt|sed 's:.*<a:<a:' >> .out
	fi
	if grep -qioE ".*720p.*</a>" .txt; then
		echo -e "\\n720p" >> .out
		grep -ioE ".*720p.*</a>" .txt|sed 's:.*<a:<a:' >> .out
	fi
	if grep -qioE ".*1080p.*</a>" .txt; then
		echo -e "\\n1080p" >> .out
		grep -ioE ".*1080p.*</a>" .txt|sed 's:.*<a:<a:' >> .out
	fi
fi
xclip -sel clip < .out
echo "copied to clipboard"
rm .out .txt
execute
}
case $1 in
	"")	pixel="url";;
	480p|480)	pixel="480p";;
	720p|720)	pixel="720p";;
	1080p|1080)	pixel="1080p";;
	sort)	pixel="sort";;
	install)	if [[ ! -e /usr/bin/editor ]]; then
					sudo cp editor.sh /usr/bin/editor
					echo -e "installed editor.";exit
				else
					a=$(md5sum editor.sh|sed 's: editor.sh::')
					b=$(md5sum /usr/bin/editor|sed 's: /usr/bin/editor::')
					if [[ "$a" != "$b" ]]; then
						sudo cp -u editor.sh /usr/bin/editor
						echo -e "updated editor.";exit
					else
						echo "no changes found.";exit
					fi
				fi;;
	help)	echo -e "\\neditor without any option will grab every available text.\\nusage: editor [options]\\noptions:\\n    480/480p   -     parse only 480p texts.\\n    720/720p   -     parse only 720p texts.\\n    1080/1080p -     parse only 1080p texts.\\n    sort       -     parse all texts in descending order.\\n    install    -     install editor into system.\\n    help       -     show help and exit.\\n";exit;;
	*) echo "invalid argument: $1";exit;;
esac
execute
