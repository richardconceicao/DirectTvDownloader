#!/bin/bash
# -xv
function GLOBAL () {
	read -p "DIGITE O LINK DO ARQUIVO MPD : " MPD
	curl -o TEMP/MPD.txt "$MPD" > /dev/null 2>&1
	URL=`echo "$MPD" | sed "s/.\{4\}$//g"`
	RAND=`echo $((($RANDOM %900) + 100))`
	AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:86.0) Gecko/20100101 Firefox/86.0"
}
function AV () {
	echo | grep "_._" TEMP/MPD.txt | sed "s/_\$Number.\{1,130\}\|^.\{1,71\}//g" | cat -n
	read -p "DIGITE O NUMERO DA LINHA CORRESPONDENTE A RESOLUCAO DESEJADO : " BD
	echo | grep "_._" TEMP/MPD.txt | sed "s/_\$Number.\{1,130\}\|^.\{1,68\}//g" | sed -n \
	""$BD"p" > TEMP/QL.txt
	VIDQ=`echo | cat TEMP/QL.txt`
	for n in `seq -f "00000%04g" 1 9999` ; do
		echo "$URL""$VIDQ"_"$n".mp4 >> TEMP/AV.txt
		echo "$URL"_aac2_"$n".mp4 >> TEMP/AV.txt
	done

	sed -i '1i\\' TEMP/AV.txt
	sed -i "1s|$|"$URL"_aac2init.mp4|g" TEMP/AV.txt

	sed -i '1i\\' TEMP/AV.txt
	sed -i "1s|$|"$URL""$VIDQ"init.mp4|g" TEMP/AV.txt
}
function FOLDER () {
	if [ -e "TEMP/" ]; then
		rm -rf TEMP/
	fi
	if [ ! -e "TEMP/SEG/" ]; then
		mkdir -vp TEMP/SEG > /dev/null 2>&1
	fi
	if [ ! -e "OUTPUT/" ]; then
		mkdir -vp OUTPUT/ > /dev/null 2>&1
	fi
}
function DOWNLOAD () {
	OLDIFS=$IFS
	IFS="
	"
	for n in $(cat TEMP/AV.txt) ; do
		wget -nc -U "$AGENT" "$n" -P TEMP/SEG/
		ERROR=$?
		if [ "$ERROR" == 8 ]; then
			echo "DOWNLOAD FINALIZADO!"
  			break
  		elif [ "$ERROR" == 4 ]; then
  			wget -nc -U "$AGENT" "$n" -P TEMP/SEG/
  			sleep 0.5
  			wget -nc -U "$AGENT" "$n" -P TEMP/SEG/
		fi
	done
	IFS=$OLDIFS
}
function MERGEAV () {
	ls TEMP/SEG/ | sort | grep "aac" | sed '$ d' >> TEMP/A.txt
	BASEA=`echo | cat "TEMP/A.txt" | sed "s/_.*$//g" | sed -n 1p`
	sed -i '1i\\' TEMP/A.txt
	sed -i "1s|$|"$BASEA"_aac2init.mp4|g" TEMP/A.txt
	for a in $(cat TEMP/A.txt) ; do
		cat "TEMP/SEG/$a" >> "OUTPUT/""A"."$RAND".mp4
	done
	ls TEMP/SEG/ | sort | grep "_.\{1,2\}_" | sed '$ d' >> TEMP/V.txt
	BASEV=`echo | cat "TEMP/V.txt" | sed "s/.\{14\}$//g" | sed -n 1p`
	sed -i '1i\\' TEMP/V.txt
	sed -i "1s|$|"$BASEV"init.mp4|g" TEMP/V.txt
	for v in $(cat TEMP/V.txt) ; do
		cat "TEMP/SEG/$v" >> "OUTPUT/""V"."$RAND".mp4
	done
}
function CLEAN () {
	rm -rf TEMP/
}
FOLDER
GLOBAL
AV
DOWNLOAD
MERGEAV
CLEAN
