#!/bin/bash
#v2.7.4
#looneytkp
set -e
connect(){
	if grep -q "unable" .wget; then 
		grep -wE --color=never unable .wget|sed 's:wget:error:'
		echo;exit 0;
	fi
}
add_on(){
	if [ "$func" == 'header' ]; then
		wget -k "$url" -o .wget -O .ct||connect
		if grep -iqE '.*(&amp|&darr).*' .ct; then
			grep -vE '.*(amp|darr).*' .ct > .ct2;mv .ct2 .ct
		fi
		if grep -qioE ".*trailer.*</a>" .ct; then
			echo 'Trailer' >> .out
			grep -iwE ".*trailer.*</a>" .ct|sed 's:.*<a:<a:';echo >> .out
		fi
		hh=$(echo $header)
		if [ "$hh" == y ]; then
			{
				if grep -qioE "s[0-9][0-9]" .ct; then
					_a=$(grep -ioE "s[0-9][0-9]" .ct|head -1|
					sed -e "s/[S-s]/<h3>Season /" -e 's/$/<\/h3>/')
					_b=$(grep -ioE "s[0-9][0-9]" .ct|head -1|
					sed -e 's/[S-s]/<h3>Season /' -e 's/[0-9]//' -e 's/$/<\/h3>/')
					_c=$(grep -ioE "s[0-9][0-9]" .ct|head -1|
					sed -e 's/[S-s]//' -e 's/[0-9]$//')
					if [ "$_c" -ge 1 ]; then echo "$_a"; else echo "$_b"; fi
				fi
			} >> .out
		fi
	elif [ "$func" == 'proc' ]; then
		c=1
		while true; do
			if [ $c -gt 9 ]; then d="(e$c|e$c)"
			else d="(e$c|e0$c)"
			fi
			if grep -qiwE ".*$d" .ct; then
				grep -iwE ".*$d" .ct >> .ct2
			else
				if [ -e .ct2 ]; then mv .ct2 .ct;fi;break
			fi
			c=$((c+1))
		done
		if ! grep -qE "(480p|720p|1080p)" .ct; then
				grep -iowE "$format" .ct|sed 's:.*<a:<a:' >> .out
		else
			f=(480p 720p 1080p)
			for f in "${f[@]}"; do
				if grep -qioE ".*$f.*</a>" .ct; then
					grep -iwE ".*$f.*" .ct|
					if grep -qE "(x264|x265)";then
						grep -iwE ".*$f.*" .ct > .ct3
						grep -vE "(x264|x265)" .ct3 > .ct2||
						size=$(wc -l<.ct2)
						if [ $size -le 1 ]; then
							rm .ct3 .ct2
						else
							echo -e "\\n$f" >> .out
							grep -iwE ".*$f.*" .ct2|sed 's:.*<a:<a:'|
							grep -iowE ".*$f.*</a>" >> .out
							if [ -e .ct3 ]; then rm .ct3;fi
						fi
					else
						echo -e "\\n$f" >> .out
						grep -iwE ".*$f.*" .ct > .ct2
						grep -iwE "$format" .ct2|sed 's:.*<a:<a:'|
						grep -iowE ".*$f.*</a>" >> .out
					fi
					if grep -qioE ".*$f.*x264.*</a>" .ct; then
						echo -e "\\n$f x264" >> .out
						grep -iwE ".*($f|x264).*" .ct > .ct2
						grep -iwE "$format" .ct2|sed 's:.*<a:<a:'|
						grep -iowE '.*x264.*</a>' >> .out
					fi
					if grep -qioE ".*$f.*x265.*</a>" .ct; then
						echo -e "\\n$f x265" >> .out
						grep -iwE ".*($f|x265).*" .ct > .ct2
						grep -iwE "$format" .ct2|sed 's:.*<a:<a:'|
						grep -iowE '.*x265.*</a>' >> .out
					fi
				fi
			done
			
			rm .ct2
		fi
	fi
}
edit(){
	read -rp "$pixel: " url
	if [[ "$url" == '' ]]; then echo -e "aborted.\\n";return; fi
	read -rp "add header? [Y/n]: " h
	case "$pixel" in
		url)
			if [ "$h" == y ] || [ "$h" == '' ]; then
				header=y;func='header';add_on
			else
				header=n;func='header';add_on
			fi
			func='proc';add_on;;
		480p|720p|1080p)
			if ! grep -q "$pixel" .ct; then
				echo "error: cannot find $pixel";exit
			fi
			if [ "$h" == y ] || [ "$h" == '' ]; then
				header=y;func='header';add_on
			else
				header=n;func='header';add_on
			fi
			echo "$pixel" >> .out
			grep -iowE ".*$pixel.*</a>" .ct|sed 's:.*<a:<a:' >> .out
	esac
	xclip -sel clip < .out
	echo "copied to clipboard."
	rm .out .ct .wget
	edit
}
sort(){
	add(){
		read -rp "$pixel: " url
		if [[ "$url" == '' ]]; then
			return
		else
			url=$url
			header=n;func='header';add_on
			func='proc';add_on
		fi
		add
	}
	a=0;b=1
	echo
#	echo '[vc_row][vc_column column_width_percent="100" align_horizontal="align_center" overlay_alpha="50" gutter_size="3" medium_width="0" mobile_width="0" shift_x="0" shift_y="0" shift_y_down="0" z_index="0" width="1/1"][vc_column_text]' > .out
	while true;do
		if [ $a != 1 ]; then
			if [ $b -ge 10 ]; then srt="$b";else srt="$b";fi
			read -rp "sort s$srt: " url
			size=$(wc -l<.out)
			if [ "$url" == '' ]; then
				if [ "$size" -le 1 ]; then
					echo -e "aborted.\\n";rm .out .wget 2> /dev/null;return
				else
					echo -e "\\n[/vc_column_text][/vc_column][/vc_row]" >> .out
					xclip -sel clip < .out
					echo "copied to clipboard."
					rm .out .wget;break
				fi
			elif [ "$url" == 'skip' ]; then
				echo > /dev/null
			elif [ "$url" == 'add' ]; then
				#if [ $srt -le 1 ]; then srt=$((srt-0));else srt=$((srt-1));fi
				pixel="  url";echo ":: adding to s$srt:"
				add
				printf %b ":: done with s$srt.\\n"
				b=$((b-1))
			elif [ "$url" == 'prev' ]; then
				b=$((b-2))
			else
				header=y;func='header';add_on
				func='proc';add_on;rm .ct
				
			fi
			b=$((b+1))
		else
			break
		fi
	done
	'sort'
}
if [ ! -e /usr/bin/xclip ]; then
	echo -e "install xclip: 'sudo <your-package-manager> xclip'."
	exit 0
fi
shopt -u nocasematch
format='.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>'
if [ -e .out ]; then rm .out; fi
if [ -e .ct ]; then rm .ct*; fi
if [ -e .wget ]; then rm .wget; fi
case $1 in
	"")	pixel='url';edit;;
	480p|480)	pixel="480p";edit;;
	720p|720)	pixel="720p";edit;;
	1080p|1080)	pixel="1080p";edit;;
	-s|--sort)
		if [ ! -d .editmp ]; then mkdir .editmp;fi;_dir=.editmp;'sort';;
	-i|--install)
		_script=$(echo "$0")
		if [[ ! -e /usr/bin/editor ]]; then
			sudo cp "$_script" /usr/bin/editor && sudo chmod 777 /usr/bin/editor
			echo -e "installed editor."
		else
			if [ "$0" == '/usr/bin/editor' ]; then
				echo 'editor is already installed.'
				exit 0
			fi
			a=$(md5sum "$_script"|sed 's:  .*editor.sh::')
			b=$(md5sum /usr/bin/editor|sed 's:  /usr/bin/editor::')
			if [[ "$a" != "$b" ]]; then
				sudo cp -u "$_script" /usr/bin/editor;sudo chmod 777 /usr/bin/editor
				echo -e "updated editor."
			else
				echo "editor is up-to-date."
			fi
		fi;;
	-u|--uninstall)
		if [ -e /usr/bin/editor ]; then sudo rm /usr/bin/editor
			echo 'uninstalled editor'
		else
			echo 'editor is not installed'
		fi;;
	-h|--help)	echo -e "\\na simple url parser.\\nusage: editor [...arguments]\\narguments:\\n   480(p), 720(p), 1080(p).\\n   -s, --sort -{add - parse more URLs.}\\n	      -{skip - hops to next URL.}\\n	      -{prev - return to previous state.}\\n   -i, --install.\\n   -u, --uninstall.\\n   -h, --help.\\n";;
	*) echo -e "invalid argument: $1\\ntry 'editor -h for more information.";;
esac
