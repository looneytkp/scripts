#!/bin/bash
set -e
shopt -u nocasematch
cd ~/Downloads
add_on(){
	{
		if grep -qioE 's01' .txt;then echo '<h3>Season 1</h3>'
			elif grep -qioE 's02' .txt;then echo '<h3>Season 2</h3>';elif grep -qioE 's03' .txt;then echo '<h3>Season 3</h3>';elif grep -qioE 's04' .txt;then echo '<h3>Season 4</h3>';elif grep -qioE 's05' .txt;then echo '<h3>Season 5</h3>';elif grep -qioE 's06' .txt;then echo '<h3>Season 6</h3>';elif grep -qioE 's07' .txt;then echo '<h3>Season 7</h3>';elif grep -qioE 's08' .txt;then echo '<h3>Season 8</h3>';elif grep -qioE 's09' .txt;then echo '<h3>Season 9</h3>';elif grep -qioE 's10' .txt;then echo '<h3>Season 10</h3>';elif grep -qioE 's11' .txt;then echo '<h3>Season 11</h3>';elif grep -qioE 's12' .txt;then echo '<h3>Season 12</h3>';elif grep -qioE 's13' .txt;then echo '<h3>Season 13</h3>';elif grep -qioE 's14' .txt;then echo '<h3>Season 14</h3>';elif grep -qioE 's15' .txt;then echo '<h3>Season 15</h3>';elif grep -qioE 's16' .txt;then echo '<h3>Season 16</h3>';elif grep -qioE 's17' .txt;then echo '<h3>Season 17</h3>';elif grep -qioE 's18' .txt;then echo '<h3>Season 18</h3>';elif grep -qioE 's19' .txt;then echo '<h3>Season 19</h3>';elif grep -qioE 's20' .txt;then echo '<h3>Season 20</h3>';elif grep -qioE 's21' .txt;then echo '<h3>Season 21</h3>';elif grep -qioE 's22' .txt;then echo '<h3>Season 22</h3>';elif grep -qioE 's23' .txt;then echo '<h3>Season 23</h3>'
			#optionally add more headers here
		fi
	} >> .out
}
connection(){
	if grep -q "unable" .wget; then
		grep -wE --color=never unable .wget
		exit
	fi
}
edit(){
	if [ -e .out ] && [ -e .txt ]; then rm .out .txt;fi
	read -rp "$pixel: " url
	if [[ "$url" == '' ]]; then
		echo "aborted";return
	fi
	wget -k "$url" -o .wget -O .txt;connection
	if grep -iqE '.*(&amp|&darr).*' .txt; then
		grep -vE '.*(amp|darr).*' .txt > .txt2
		mv .txt2 .txt
	fi
	if [ "$pixel" == 'url' ]; then
		#if you don't fancy being asked for header, comment
		read -rp "add header ? y/n: " h		#this
		case $h in 							#this
			y|"")	add_on;;				#this
			n|*);;							#this
		esac								#and that.
		{
			if grep -qioE ".*trailer.*</a>" .txt; then
				echo 'Trailer'
				grep -ioE ".*trailer.*</a>" .txt|sed 's:.*<a:<a:'
				echo
			fi
			if ! grep -qE "(480p|720p|1080p)" .txt; then
						grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'
					else
						if grep -qioE ".*480p.*</a>" .txt; then echo "480p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*480p.*</a>'
						fi
						if grep -qioE ".*720p.*</a>" .txt; then echo -e "\\n720p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*720p.*</a>'
						fi
						if grep -qioE ".*1080p.*</a>" .txt; then
							echo -e "\\n1080p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*1080p.*</a>'
						fi
					fi
		} >> .out
	elif [[ "$pixel" == 480p ]] || [[ "$pixel" == 720p ]] || [[ "$pixel" == 1080p ]]; then
		if ! grep -q "$pixel" .txt; then
			echo "error: cannot find $pixel";exit
		fi
		#if you don't fancy being asked for header, comment
		read -rp "add header ? y/n: " h		#this
		case $h in 							#this
			y|"")	add_on;;				#this
			n|*);;							#this
		esac								#and that.
		{
			if grep -qioE ".*trailer.*</a>" .txt; then
				echo 'Trailer'
				grep -ioE ".*trailer.*</a>" .txt|sed 's:.*<a:<a:'
				echo
			fi
			echo "$pixel"
			grep -ioE ".*$pixel.*</a>" .txt|sed 's:.*<a:<a:'
		} >> .out
	fi
	xclip -sel clip < .out
	echo "copied to clipboard"
	rm .out .txt .wget
	edit
}
sort(){
	a=0;b=1
	echo '[vc_row][vc_column column_width_percent="100" align_horizontal="align_center" overlay_alpha="50" gutter_size="3" medium_width="0" mobile_width="0" shift_x="0" shift_y="0" shift_y_down="0" z_index="0" width="1/1"][vc_column_text]' > .out
	while true;do
		if [ $a != 1 ]; then
			if [ $b -ge 10 ]; then
				read -rp "sort s$b: " url
			else
				read -rp "sort s0$b: " url
			fi
			size=$(wc -l<.out)
			if [ "$url" == '' ]; then
				if [ $size -le 1 ]; then
					echo "aborted";rm .out .wget 2> /dev/null;return
				else
					echo '[/vc_column_text][/vc_column][/vc_row]' >> .out
					xclip -sel clip < .out
					echo "copied to clipboard"
					rm .out .wget;break
				fi
			elif [ "$url" == 'skip' ]; then
				echo > /dev/null
			else
				wget -k "$url" -o .wget -O .txt||connection
				if grep -iqE '.*(&amp|&darr).*' .txt; then
					grep -vE '.*(amp|darr).*' .txt > .txt2
					mv .txt2 .txt
				fi
				add_on
				{
					if grep -qioE ".*trailer.*</a>" .txt; then
						echo 'Trailer'
						grep -ioE ".*trailer.*</a>" .txt|sed 's:.*<a:<a:'
						echo
					fi
					if ! grep -qE "(480p|720p|1080p)" .txt; then
						grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'
					else
						if grep -qioE ".*480p.*</a>" .txt; then echo "480p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*480p.*</a>'
						fi
						if grep -qioE ".*720p.*</a>" .txt; then echo -e "\\n720p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*720p.*</a>'
						fi
						if grep -qioE ".*1080p.*</a>" .txt; then
							echo -e "\\n1080p"
							grep -iowE '.*(webrip|avi|flv|wmv|mov|mp4|mkv|3gp|webm|m4a|m4v|f4a|f4v|m4b|m4r|f4b).*</a>' .txt|sed 's:.*<a:<a:'|grep -iowE '.*1080p.*</a>'
						fi
					fi
				} >> .out
				rm .txt
			fi
	b=$((b+1))
		else
			break
		fi
	done
	'sort'
}
case $1 in
	"")	pixel='url';edit;;
	480p|480)	pixel="480p";edit;;
	720p|720)	pixel="720p";edit;;
	1080p|1080)	pixel="1080p";edit;;
	sort)	'sort';;
	install)	if [[ ! -e /usr/bin/editor ]]; then
					sudo cp editor.sh /usr/bin/editor
					echo -e "installed editor."
				else
					a=$(md5sum editor.sh|sed 's: editor.sh::')
					b=$(md5sum /usr/bin/editor|sed 's: /usr/bin/editor::')
					if [[ "$a" != "$b" ]]; then
						sudo cp -u editor.sh /usr/bin/editor
						echo -e "updated editor."
					else
						echo "redundant update, no changes found."
					fi
				fi;;
	help)	echo -e "\\nusage: editor [options]\\noptions:\\n    480/480p	-	grab 480p URLs.\\n    720/720p	-	grab 720p URLs.\\n    1080/1080p	-	grab 1080p URLs.\\n    sort	-	grab & parse all URLs in order.\\n    install	-	install editor.\\n    help	-	show help.\\n";;
	*) echo "invalid argument: $1";;
esac
