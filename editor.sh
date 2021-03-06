#!/bin/bash
#v3.8.4
#looneytkp
cleanup(){
	if [ -e .out ]; then rm .out*; fi
	if [ -e .ct ]; then rm .ct*;fi
	if [ -e .wget ]; then rm .wget; fi
	if [ -d $_dir ]; then rm -rf $_dir; fi
}
sig_abort(){
	cleanup
	echo -e "\\naborted.\\n"
	exit 0
}
abort(){
	#cleanup
	if [ "$nd2" != '' ]; then
		if [ $size -ge 1 ]; then
			echo -e ":: faulty: $url.\\n"
		else
			if [ ! -e $out ]; then
				truncate -s 0 $out;size=$(wc -l<$out)
				echo -e ":: faulty: $url.\\n"
			else
				xclip -sel clip < $out
				echo -e ":: copied to clipboard.\\n"
			fi
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
parser(){
if [ "$cur" == fl ]; then ct=$file;fi
f=(480p 720p 1080p)
			for f in "${f[@]}"; do
				if grep -qioE ".*$f.*</a>" $ct; then
					grep -iwE ".*$f.*" $ct|
					if grep -qE ".*$f.*(x264|x265).*";then
						grep -iwE ".*$f.*" $ct > $ct3
						grep -vE ".*$f.*(x264|x265).*" $ct3 > $ct2||
						size=$(wc -l<$ct2)
						if [ $size -le 1 ]; then
							if [ "$cur" == fl ]; then
								echo -e "\\n$f" >> $out
								grep -iwE ".*$f.*" $ct2|sed 's:.*<a:<a:'|
								grep -iowE ".*$f.*</a>" >> $out
							else
								rm $ct3 $ct2
							fi
						else
							echo -e "\\n$f" >> $out
							grep -iwE ".*$f.*" $ct2|sed 's:.*<a:<a:'|
							grep -iowE ".*$f.*</a>" >> $out
							if [ -e $ct3 ]; then rm $ct3;fi
						fi
					else
						echo -e "\\n$f" >> $out
						grep -iwE ".*$f.*" $ct > $ct2
						grep -iwE "$format" $ct2|sed 's:.*<a:<a:'|
						grep -iowE ".*$f.*</a>" >> $out
					fi
					if grep -qioE ".*$f.*x264.*</a>" $ct; then
						echo -e "\\n$f x264" >> $out
						grep -iwE ".*($f|x264).*" $ct > $ct2
						grep -iwE "$format" $ct2|sed 's:.*<a:<a:'|
						grep -iowE '.*x264.*</a>' >> $out
					fi
					if grep -qioE ".*$f.*x265.*</a>" $ct; then
						echo -e "\\n$f x265" >> $out
						grep -iwE ".*($f|x265).*" $ct > $ct2
						grep -iwE "$format" $ct2|sed 's:.*<a:<a:'|
						grep -iowE '.*x265.*</a>' >> $out
					fi
				fi
			done
			if [ "$cur" != fl ]; then if [ -e $ct3 ]; then rm $ct2 $ct3;fi;fi
}
add_on(){
	if [ "$func" == 'header' ]; then
		wget -k "$url" -o .wget -O $ct||connect
		if grep -iqE '.*(&amp|&darr).*' $ct; then
			grep -vE '.*(amp|darr).*' $ct > $ct2;mv $ct2 $ct
		fi
		if grep -qioE ".*trailer.*</a>" $ct; then
			echo 'Trailer' >> $out
			grep -iwE ".*trailer.*</a>" $ct|sed 's:.*<a:<a:';echo >> $out
		fi
		hh=$(echo $header)
		if [ "$hh" == y ]; then
			{
				if grep -qioE "s[0-9][0-9]" $ct; then
					_a=$(grep -ioE "s[0-9][0-9]" $ct|head -1|
					sed -e "s/[S-s]/<h3>Season /" -e 's/$/<\/h3>/')
					_b=$(grep -ioE "s[0-9][0-9]" $ct|head -1|
					sed -e 's/[S-s]/<h3>Season /' -e 's/[0-9]//' -e 's/$/<\/h3>/')
					_c=$(grep -ioE "s[0-9][0-9]" $ct|head -1|
					sed -e 's/[S-s]//' -e 's/[0-9]$//')
					if [ "$_c" -ge 1 ]; then echo "$_a"; else echo "$_b"; fi
				fi
			} >> $out
		fi
	elif [ "$func" == 'proc' ]; then
		c=1
		while true; do
			if [ $c -gt 9 ]; then d="(e$c|e$c)"
			else d="(e$c|e0$c)"
			fi
			if grep -qiwE ".*$d" $ct; then
				grep -iwE ".*$d" $ct >> $ct2
			else
				if [ -e $ct2 ]; then mv $ct2 $ct;fi;break
			fi
			c=$((c+1))
		done
		if ! grep -qE "(480p|720p|1080p)" $ct; then
				grep -iowE "$format" $ct|sed 's:.*<a:<a:' >> $out
		else
			cur=lf
			parser
			if [ -e $ct2 ]; then rm $ct2;fi
		fi
	fi
}
edit(){
	esc=no;esc=$(echo $esc);nd2='';nd2=$(echo "$nd2")
	if ! grep -q "#editor=no-talk" ~/.bashrc; then
		printf %b "            [hit enter if input is null to abort]\\r"
	fi
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
	read -N 1 -erp "add header?: " h
	case "$pixel" in
		url)
			if [ "$h" == y ] || [ "$h" == '' ]; then
				header=y;func='header';add_on
			else
				header=n;func='header';add_on
			fi
			func='proc';add_on;;
		480p|720p|1080p)
			if ! grep -q "$pixel" $ct; then
				echo "error: cannot find $pixel";exit
			fi
			if [ "$h" == y ] || [ "$h" == '' ]; then
				header=y;func='header';add_on
			else
				header=n;func='header';add_on
			fi
			echo "$pixel" >> $out
			grep -iowE ".*$pixel.*</a>" $ct|sed 's:.*<a:<a:' >> $out
	esac
	xclip -sel clip < $out
	echo -e "copied to clipboard."
	rm $out $ct .wget
	edit
}
sort(){
#here
	compare(){
		size=$(wc -l<$out)
		if [ $size -le 1 ]; then
			empty=yes
			b=$((b+0))
			status=1
		else
			cmpr=$(grep -iwoE "s$srt" $out|head -1|sed 's:[S-s]::')
			if [ "$cmpr" == "$srt" ]; then
				cat $out >> "$_dir/s$srt"
				truncate -s 0 $out
				b=$((b+0))
				empty=no;status=0
			else
				b=$((b-1))
				status=1
			fi
		fi
	}
	add(){
		if ! grep -q "#editor=no-talk" ~/.bashrc; then
			printf %b "              [input s$srt URL only]\\r"
		fi
		read -erp "$pixel: " url
		if [[ "$url" == '' ]]; then
			if [ -e $out2 ]; then mv $out2 $out; fi
			compare;return
		else
			lru=$(echo "$url"|grep "http"|| echo false)
			if [ $lru == false ]; then
				echo ":: error: $url: not a URL"
				empty="yes";status=2
			else
				header=n;func='header';add_on
				func='proc';add_on
				cmpr=$(grep -iwoE "s01" $out|head -1|sed 's:[S-s]::')
				if [ "$cmpr" != "$srt" ]; then
					echo -e ":: error:'s$srt' not found in URL."
					truncate -s 0 $out;empty="yes";status=2
				else
					cat $out >> $out2
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
	touch $out
	esc=$(echo $esc)
	while true;do
		talk(){
			if ! grep -q "#editor=no-talk" ~/.bashrc; then
				text=("[flags:append mod skip return delete exit]" "[append:adds to the end of existing texts]" "[skip:hops to the next tag.]" "[exit:aborts the script]" "[return:hops to previous tag]" "[tip:pass '--no-talk' to disable ghost-texts]"  "[modify:edits the current tag file]" "[delete: erases current tag]" "[tip:letters are also flags. eg. s = skip]" "[letter flags: a, m, s, r, d, e]" "[tip:hit enter to abort if input is null]" "[info:input URLs that match with tags]" "[info:tags are s01 s02 s03 ... etc]" "[tip:hit enter to clip URL if input is valid]" "[tip:sort supports positional parameters]" "[tip:pass '--talk' to enable ghost-texts]")
				ezis=${#text[@]};xeden=$((RANDOM % $ezis))
				printf %b "              ${text[$xeden]}\\r"
			fi
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
				talk;read -erp "s$srt: " -a url
			elif [ $n -ge 1 ] && [ $esc == no ]; then
				url=$position
			elif [ $n -ge 1 ] && [ $esc == yes ]; then
				url=""
			fi
			size=$(wc -l<$out)
			case "$url" in
				"")
					if [ -z "$(ls -A $_dir)" ]; then
						abort
					else
						
						if [ $size == 2 ]; then #&& [ "$(wc -l<$_dir/s$srt)" -le 2 ]; then
							abort
						#elif [ $size -lt 2 ] && [ "$(wc -l<$_dir/s$srt)" -gt 2 ]; then
						#	abort
						else
							echo '[vc_row][vc_column column_width_percent="100" align_horizontal="align_center" overlay_alpha="50" gutter_size="3" medium_width="0" mobile_width="0" shift_x="0" shift_y="0" shift_y_down="0" z_index="0" width="1/1"][vc_column_text]' > $out
							if [ $n -ge 1 ] && [ $esc == no ]; then
								for file in $_dir/*;do
									cat $file >> $out
								done
							else
								cur=fl;cur=$(echo $cur)
								for file in $_dir/*;do
									grep -qio '.*Season.*' $file >> $out
									parser
								done
							fi
							echo -e "\\n[/vc_column_text][/vc_column][/vc_row]" >> $out
							#xclip -sel clip < $out
							if [ $esc == yes ]; then 
								if [ $n -le 1 ]; then 
									rm $out;return
								else
									xclip -sel clip < $out
									echo "copied to clipboard."
									rm $out .wget;break
									b=$((b+1))
								fi
							else
								xclip -sel clip < $out
								echo "copied to clipboard."
								rm $out .wget;break
								b=$((b+1))
							fi
						fi
					fi;;
				skip|s)
					echo > /dev/null;b=$((b+1));;
				append|a)
					pixel=":: url";echo ":: appending texts.";add
					status=$(echo "$status");empty=$(echo "$empty")
					if [ "$status" == 2 ] && [ "$empty" == "yes" ]; then
						add
					elif [ "$status" == 1 ] && [ "$empty" == "yes" ]; then
						echo -e ":: exited.\\n"
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
					if [ $n -lt 1 ]; then
						for url in "${url[@]}";do
							lru=$(echo "$url"|grep "http"|| echo false)
							if [ $lru == false ]; then
								echo "error: $url: not a URL/flag.";b=$((b+0))
								if [ -e $_dir/s$srt ]; then rm "$_dir/s$srt";fi;break
							else
								header=y;func='header';add_on
								func='proc';add_on
								compare
								if [ $status == 1 ]; then
									echo "error: $url.";b=$((b+0))
									#rm $ct #$ct2 $ct3
									#cleanup;mkdir $_dir
									truncate -s 2 $out;
									break
								fi
							fi
						done
						b=$((b+1))
						if [ $b -gt 1 ]; then b=$((b-0));fi # else b=$((b-1));fi
					else
						lru=$(echo "$url"|grep "http"|| echo false)
						if [ $lru == false ]; then
							echo ":: error: $url: not a URL/flag.";b=$((b+0))
							if [ "$nd2" != "" ]; then abort;fi
						else
							header=y;func='header';add_on
							func='proc';add_on;rm $ct
							compare
							if [ "$nd2" != "" ]; then b=$((b+1));return;fi
							if [ $status == 1 ]; then
								echo ":: error: s$srt not found.";b=$((b-0))
							fi
							b=$((b+1))
						fi
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
#cleanup
if [ ! -e /usr/bin/xclip ]; then
	echo -e "install xclip: 'sudo <your-package-manager> xclip'."
	exit 0
fi
shopt -u nocasematch
out=.out
out2=.out2
ct=.ct
ct2=.ct2
ct3=.ct3
format='.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>'
case $1 in
	"")	pixel='url';echo;edit;;
	480p|480)	pixel="480p";echo;edit;;
	720p|720)	pixel="720p";echo;edit;;
	1080p|1080)	pixel="1080p";echo;edit;;
	--talk)
		if grep -q "#editor=no-talk" ~/.bashrc; then
			sed -i "/#editor=no-talk/d" ~/.bashrc
		fi;;
	--no-talk)
		if ! grep -q "#editor=no-talk" ~/.bashrc; then
			echo "#editor=no-talk" >> ~/.bashrc
		fi;;
	-s|--sort)
		if [ "$2" != '' ]; then
			esc=no;nd2="$2";n=$#;n=$((n-1))
			fc=(a s d m e r)
			echo -e "\\n:: auto sorting $n URL(s)."
			for position;do
				for i in "${fc[@]}"; do
					if [ $2 == $i ]; then echo -e ":: error: $i: not a URL or flag.";abort;fi
				done
				if [ "$position" == -s ]||[ "$position" == '--sort' ]; then
					continue
				else
					n=$((n+1))
					'sort' "$position"
					status=$(echo "$status");empty=$(echo "$empty")
					if [ "$status" == 1 ] && [ "$empty" == "yes" ]; then
						echo ":: faulty URL: $url."
						abort
					fi
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
		fi
		if grep -q "#editor=no-talk" ~/.bashrc; then
			sed -i "/#editor=no-talk/d" ~/.bashrc
		fi;;
	-u|--uninstall)
		if grep -q "#editor=no-talk" ~/.bashrc; then
			sed -i "/#editor=no-talk/d" ~/.bashrc
		fi
		if [ -e /usr/bin/editor ]; then sudo rm /usr/bin/editor
			echo 'uninstalled editor'
		else
			echo 'editor is not installed'
		fi;;
	-h|--help)	echo -e "\\na simple html editor.\\nusage: editor [...arguments]\\narguments:\\n   480(p), 720(p), 1080(p).\\n   -s, --sort -{append, modify, delete, skip, return, exit}\\n   -i, --install.\\n   -u, --uninstall.\\n   -h, --help.\\n";;
	*) echo -e "invalid flag: $1\\ntry 'editor -h for more information.";;
esac
