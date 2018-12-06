#!/bin/bash
set -e
cd ~/Downloads
run(){
if [ -e .out ] && [ -e .txt ]; then rm .out .txt;fi
read -rp "url: " url
if [[ "$url" == "" ]]; then
	echo "aborted"
	return
fi
page=$(wget "$url" -q -O - || echo "check connection")
echo "$page" > .txt
grep -o '<a href=".*' .txt > .out
if grep -q "</A>" .out; then
	sed -i "s:</A>.*:</A>:g" .out
else
	sed -i "s:</a>.*:</a>:g" .out
fi
xclip -sel clip < .out
rm .out .txt
run
}
run
