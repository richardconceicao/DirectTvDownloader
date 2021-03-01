#!/bin/bash
#-xv
NUM="999"
read -p "DIGITE O LINK DO ARQUIVO MPD : " MPD
wget "$MPD" -O MPD.txt > /dev/null 2>&1
URL=`echo "$MPD" | sed "s/.\{4\}$//g"`
RAND=`echo $((($RANDOM %900) + 100))`

function AV () {
	echo | grep "_._" MPD.txt | sed "s/_\$Number.\{1,130\}\|^.\{1,71\}//g" | cat -n
	read -p "DIGITE O NUMERO DA LINHA CORRESPONDENTE A RESOLUCAO DESEJADO : " BD
	echo | grep "_._" MPD.txt | sed "s/_\$Number.\{1,130\}\|^.\{1,68\}//g" | sed -n ""$BD"p" > QL.txt
	VIDQ=`echo | cat QL.txt`
	for n in `seq -f "00000%04g" 1 $NUM` ; do
		echo "$URL""$VIDQ"_"$n".mp4 >> AV.txt
		echo "$URL"_aac2_"$n".mp4 >> AV.txt
	done

	sed -i '1i\\' AV.txt
	sed -i "1s|$|"$URL"_aac2init.mp4|g" AV.txt

	sed -i '1i\\' AV.txt
	sed -i "1s|$|"$URL""$VIDQ"init.mp4|g" AV.txt
}
function DOWNLOAD () {
	OLDIFS=$IFS
	IFS="
	"
	for n in $(cat AV.txt) ; do
		sleep 0.3
		wget -U "Mozilla/5.0 (X11; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0" "$n" -P SEGMENT/
		if [ $? == 8 ] ; then
			echo "DOWNLOAD FINALIZADO!"
  			break
		fi
	done
	IFS=$OLDIFS
}
function MERGEA () {
   #LISTANDO AQUIVOS
	ls SEGMENT/ | sort | grep "aac" | sed '$ d' >> SEGMENT/A.txt
   #BASEA
	BASEA=`echo | cat "SEGMENT/A.txt" | sed "s/_.*$//g" | sed -n 1p`
   #ADICIONANDO INIT
	sed -i '1i\\' SEGMENT/A.txt
	sed -i "1s|$|"$BASEA"_aac2init.mp4|g" SEGMENT/A.txt
	for a in $(cat SEGMENT/A.txt) ; do
		cat "SEGMENT/$a" >> "A"."$RAND".mp4
	done
}
function MERGEV () {
   #LISTANDO AQUIVOS
	ls SEGMENT/ | sort | grep "_.\{1,2\}_" | sed '$ d' >> SEGMENT/V.txt
   #BASEV
	BASEV=`echo | cat "SEGMENT/V.txt" | sed "s/.\{14\}$//g" | sed -n 1p`
   #ADICIONANDO INIT
	sed -i '1i\\' SEGMENT/V.txt
	sed -i "1s|$|"$BASEV"init.mp4|g" SEGMENT/V.txt
	for v in $(cat SEGMENT/V.txt) ; do
		cat "SEGMENT/$v" >> "V"."$RAND".mp4
	done
}
function CLEAN () {
	rm -rf *.txt
	rm -rf SEGMENT/*
}
AV
DOWNLOAD
MERGEA
MERGEV
CLEAN
