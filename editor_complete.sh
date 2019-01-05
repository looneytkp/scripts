#!/bin/bash
#v3.8.1
#looneytkp
cleanup(){
	if [ -e .out ]; then rm .out*; fi
	if [ -e .ct ]; then rm .ct*; fi
	if [ -e .wget ]; then rm .wget; fi
	if [ -d $_dir ]; then rm -rf $_dir; fi
}
sig_abort(){
	cleanup
	echo -e "\\naborted.\\n"
	exit 0
}
abort(){
	cleanup
	if [ $esc == yes ]; then
		if [ $size -lt 1 ]; then
			echo -e ":: failed.\\n"
		else
			echo -e ":: done.\\n"
		fi
	else
		echo -e "aborted.\\n"
	fi
	exit 0		
}
connect(){
	if [ $? == 4 ]; then
		grep -wE --color=never unable .wget|sed 's:wget:error:'
		echo -e "check internet connection!\\n";abort
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
	esc=no;esc=$(echo $esc)
	printf %b "            [hit enter if input is null to abort]\\r"
	read -erp "$pixel: " url
	lru=$(echo "$url"|grep "http"|| echo false)
	if [ $lru == false ]; then
		if [ "$url" == "" ]; then
			abort
		else
			echo -e "error: $url: not a URL";b=$((b-1))
			edit
		fi
	fi
	printf %b "                   [Y/n]\\r"
	read -N 1 -rp "add header?: " h
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
	echo -e "\\ncopied to clipboard."
	rm .out .ct .wget
	edit
}
sort(){
	compare(){
		size=$(wc -l<.out)
		if [ $size -le 1 ]; then
			empty=yes
			b=$((b+0))
			status=1
		else
			cmpr=$(grep -iwoE "s01" .out|head -1|sed 's:[S-s]::')
			if [ "$cmpr" == "$srt" ]; then
				cat .out >> "$_dir/s$srt"
				truncate -s 0 .out
				b=$((b+0))
				empty=no;status=0
			else
				b=$((b+0))
				status=1
			fi
		fi
	}
	add(){
		printf %b "              [s$srt URL only]\\r"
		read -rp "$pixel: " url
		if [[ "$url" == '' ]]; then
			if [ -e .out2 ]; then mv .out2 .out; fi
			compare;return
		else
			lru=$(echo "$url"|grep "http"|| echo false)
			if [ $lru == false ]; then
				echo ":: error: $url: not a URL"
				empty="yes";status=2
			else
				header=n;func='header';add_on
				func='proc';add_on
				cmpr=$(grep -iwoE "s01" .out|head -1|sed 's:[S-s]::')
				if [ "$cmpr" != "$srt" ]; then
					echo -e ":: error:'s$srt' not found in URL."
					truncate -s 0 .out;empty="yes";status=2
				else
					cat .out >> .out2
				fi
			fi
		fi
		add
	}
	_dir=.editmp
	if [ $n -gt 1 ]; then
		if [ ! -d $_dir ]; then mkdir $_dir;fi
	else
		if [ ! -d $_dir ]; then mkdir $_dir;echo
		elif [ -n "$(ls -A $_dir)" ]; then rm $_dir/*;echo
		fi
	fi
	a=0;b=1;d=0
	touch .out
	esc=$(echo $esc)
	while true;do
		rand(){
			text=("[flags:append, mod, skip, return, delete, exit]" "[append:adds to the end of existing texts]" "[skip:hops to the next tag.]" "[exit:aborts the script]" "[return:hops to previous tag]" "[modify:edits the current tag file]" "[delete: erases current tag]" "[tip:letters are also flags. eg. s = skip]" "[letter flags: a, m, s, r, d, e]" "[tip:hit enter to abort if input is null]" "[tip:input URLs that match with tags]" "[info:tags are s01 s02 s03 ... etc]" "[tip:hit enter twice to clip a processed URL]" "[tip:sort supports positional parameters]")
			ezis=${#text[@]};xeden=$((RANDOM % $ezis))
			printf %b "                  ${text[$xeden]}\\r"
		}
		if [ $b -ge 10 ]; then
			d="";srt="$d$b"
		elif [ $b -le 10 ]; then
			if [ $b -eq 0 ]; then
				b=1
			else
				d=0;srt="$d$b"
			fi
		
		fi
		if [ $a != 1 ]; then
			if [ $n -lt 1 ]; then
				rand;read -rp "sort s$srt: " url
			elif [ $n -ge 1 ] && [ $esc == no ]; then
				url=$position
			elif [ $n -ge 1 ] && [ $esc == yes ]; then
				url=""
			fi
			size=$(wc -l<.out)
			case "$url" in
				"")
					if [ -z "$(ls -A $_dir)" ]; then
						abort
					else
						echo '[vc_row][vc_column column_width_percent="100" align_horizontal="align_center" overlay_alpha="50" gutter_size="3" medium_width="0" mobile_width="0" shift_x="0" shift_y="0" shift_y_down="0" z_index="0" width="1/1"][vc_column_text]' > .out
						for file in $_dir/*;do
							cat $file >> .out
						done
						echo -e "\\n[/vc_column_text][/vc_column][/vc_row]" >> .out
						xclip -sel clip < .out
						if [ $esc == yes ]; then echo ":: copied to clipboard."
							rm .out;return
						else echo "copied to clipboard."
							rm .out .wget;break
						fi
					fi;;
				skip|s)
					echo > /dev/null;b=$((b+1));;
				append|a)
					pixel=":: url";echo ":: appending links to s$srt.";add
					status=$(echo "$status");empty=$(echo "$empty")
					if [ "$status" == 2 ] && [ "$empty" == "yes" ]; then
						add
					elif [ "$status" == 1 ] && [ "$empty" == "yes" ]; then
						echo -e ":: exited.\\n"
						#if [ ! -e $_dir/s$srt ]; then b=$((b-1));fi
					elif [ "$status" == 1 ] && [ "$empty" == "" ]; then
						echo -e ":: error: s$srt links not found, check URL."
						add
					elif [ "$status" == 0 ] && [ "$empty" == "no" ]; then
						echo -e ":: done with s$srt.\\n";b=$((b+1))
					fi;;
				return|r)
						b=$((b-1))
					;;
				delete|d)
					if [ -e "$_dir/s$srt" ]; then rm "$_dir/s$srt";echo "s$srt deleted.";fi
					b=$((b-0));;
				mod|m)
					echo ":: not yet functional.";b=$((b-0));;
				exit|e) abort;;
				*)
					lru=$(echo "$url"|grep "http"|| echo false)
					if [ $lru == false ]; then
						echo "error: $url: not a URL or flag.";b=$((b+0))
						if [ "$nd2" != "" ]; then abort;fi
					else
						header=y;func='header';add_on
						func='proc';add_on;rm .ct
						compare
						if [ "$nd2" != "" ]; then return;fi
							if [ $status == 1 ]; then
							echo "error: s$srt links not found.";b=$((b-0))
						fi
						b=$((b+1))
					fi;;
			esac
		else
			break
		fi
	done
	'sort'
}
set -e
trap sig_abort SIGINT
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
	"")	pixel='url';echo;edit;;
	480p|480)	pixel="480p";echo;edit;;
	720p|720)	pixel="720p";echo;edit;;
	1080p|1080)	pixel="1080p";echo;edit;;
	-s|--sort)
		if [ "$2" != '' ]; then
			esc=no;nd2="$2";n=$#;n=$((n-1))
			echo "you found the easter egg :)"
			echo -e "\\n:: auto sorting $n URLs"
			for position;do
				if [ "$position" == -s ]||[ "$position" == '--sort' ]; then
					continue
				else
					n=$((n+1))
					'sort' "$position"
				fi
			done
			esc=yes
			'sort' "$n";printf %b "\\r";abort
		else
			esc=no;n=0;'sort'
		fi;;
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
	-h|--help)	echo -e "\\na simple url parser.\\nusage: editor [...arguments]\\narguments:\\n   480(p), 720(p), 1080(p).\\n   -s, --sort -{append, modify, delete, skip, return, exit}\\n   -i, --install.\\n   -u, --uninstall.\\n   -h, --help.\\n";;
	*) echo -e "invalid argument: $1\\ntry 'editor -h for more information.";;
esac
