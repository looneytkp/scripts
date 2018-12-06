#!/bin/bash
set -e

cd ~/Downloads
run() {
	file=~/Downloads/.tmp.txt
	find *.jpg *.png *.jpeg 2> /dev/null|grep -vE '(_c.jpg|_c.png)'|grep -n . > $file|| printf "\\rno images to convert" #;exit
	cnt=1
	while true;do
		if grep -q "$cnt:" $file; then
			name=$(grep "$cnt:" $file|sed "s/"$cnt:"//")
			proc=$(grep "$name" $file|grep -oE '(.jpg|.png)')
			size=$(identify -verbose -quiet "$name"|grep Geometry|sed -e 's/.*: //' -e 's/+.*//' -e 's/x//')
			if [[ $proc == '.jpg' ]];then
				old='.jpg';new='_c.jpg'
			else
				old='.png';new='_c.png'
			fi
			new_name=$(grep "$cnt:" $file|sed "s/"$cnt:"//"|sed "s/$old/$new/")
			if [[ $size -lt 500741 ]]; then
				echo "$name" >> .logs
			elif [[ $size -gt 500741 ]]; then
				convert -quiet "$name" -resize 500x741! -quality 65 "$new_name"
				#Scnt2=60
				#while true; do
				#	filesize=$(identify "$new_name"|sed -e 's/.*sRGB //' -e 's/B.*//')
				#	if [[ $filesize -gt 80000 ]]; then
				#	convert "$new_name" -resize 500x741! -quality $cnt2 "$new_name"
				#	else
				#		break
				#	fi
				#	cnt2=$((cnt2-5))
				#done
				#rm "$name"
			elif [[ $size == 500741 ]]; then
				convert -quiet "$name" -quality 65 "$new_name"
#				cnt2=60
#				while true; do
#					filesize=$(identify "$new_name"|sed -e 's/.*sRGB //' -e 's/B.*//')
#					if [[ $filesize -gt 80000 ]]; then
#						convert "$new_name" -resize -quality $cnt2 "$new_name"
#					else
#						break
#					fi
#					cnt2=$((cnt2-5))
#				done
				#rm "$name"
			fi
			cnt=$((cnt+1))
		else
			break
		fi
	done
	rm $file
}
run &
pid=$!
spin='-\|/'
i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf "\\r${spin:$i:1} converting..."
  sleep .1
done
echo "done"
if [ -e .logs ]; then
	echo -e "\\nerrors:"
	cat -n .logs
	rm .logs
fi
