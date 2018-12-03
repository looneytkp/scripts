#!/bin/bash
set -e

cd ~/Downloads/imgs
ls|grep -n . > ~/Downloads/first.txt
cnt=1
while true
do
	if grep -q "$cnt:" ~/Downloads/first.txt; then
		name=$(grep "$cnt:" ~/Downloads/first.txt|sed "s/"$cnt:"//")
		size=$(convert "$name" -print "%wx%h\n" /dev/null|sed "s/x//")
		#sizes=$(du -sh "$name"|sed "s/[A-Z].*//")
		#if [[ $sizes -lt 90 ]]; then
		#	echo "small: $name"
		#	if [[ $size -lt 500741 ]]; then
		#		echo "$name size less than 500x741"
		#	elif [[ $size -gt 500741 ]]; then
		#		convert "$name" -resize 500x741! "$name"
		#		echo "resized $name"
		#	fi
		#else
			if [[ $size -lt 500741 ]]; then
				echo "$name size less than 500x741"
			elif [[ $size -gt 500741 ]]; then
				convert "$name" -resize 500x741! -quality 65 "$name"
				echo "resized $name"
			elif [[ $size == 500741 ]]; then
				convert "$name" -quality 65 "$name"
				echo "reduced $name"
			fi
		#fi
		if grep -q "$cnt:" ~/Downloads/first.txt; then
			cnt=$((cnt+1))
		else
			echo 'done';exit
		fi
	else
		echo 'done'
		exit
	fi
done
