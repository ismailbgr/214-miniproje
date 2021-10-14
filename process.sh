# #!/bin/bash

# #Cites,Authors,Title,Year,Source,Publisher,ArticleURL,CitesURL,GSRank,QueryDate,Type,DOI,ISSN,CitationURL,Volume,Issue,StartPage,EndPage,ECC,CitesPerYear,CitesPerAuthor,AuthorCount,Age,Abstract,FullTextURL,RelatedURL

while getopts "s:i:o:" arg; do
    case $arg in
        s)
            splitargs=$OPTARG
            # echo "splitargs:$splitargs"
        ;;
        i)
            inputfiles=$OPTARG
            # echo "inputfiles:$inputfiles"
        ;;
        o)
            outputfile=$OPTARG
            # echo "outputfile:$outputfile"

        ;;
    esac
done

if [[ -z $inputfiles ]]
then

echo "input girilmedi"
exit

fi

if [[ -z $outputfile ]]
then

echo "output girilmedi"
exit

fi

if [[ -z $splitargs ]]
then

echo "split argümanı girilmedi"
exit

fi


column_names=$(cat $inputfiles | head -n 1)


oldIFS=$IFS

IFS=,

read -r -a column_array <<< "$column_names"

column_array+=("Total Pages")

IFS=$oldIFS


IFS=" "
read -r -a input_array <<< $inputfiles
IFS=$oldIFS

for i in "${input_array[@]}"
do
tail $i -n +2 >> temp.csv
echo -n $'\n' >> temp.csv

done

alllines=()
index=0;

while read line
do

if [ "$line" = "" ] 
then

    continue

fi

alllines[$index]=$(echo $line | sed -E 's/([a-Z]),([a-Z])/\1#\2/g' | sed -E 's/([a-Z]), /\1# /g')
index=$(($index + 1))

done < temp.csv

rm temp.csv



for (( k = 0; k < ${#alllines[@]}; k++));do
text=${alllines[$k]}

IFS=$','

read  -r -a features_array <<< $text


features_array[26]=""

features_array[18]=${features_array[0]}
features_array[22]=$(echo $(($(($(date --date="$(echo ${features_array[9]} | sed "s/\"//g")" +%s) - $( date --date="${features_array[3]}-01-01" +%s ))) / (60*60*24) ))  )
features_array[19]=$(printf '%.3f\n' $(echo "$((${features_array[0]} * 365 / ${features_array[22]} ))" | bc -l))
features_array[21]=$(( $(echo ${features_array[1]} | grep -o "#" | wc -l) + 1 ))
features_array[20]=$(printf '%.3f\n' $(echo "${features_array[0]} / ${features_array[21]}" | bc -l))


if [[ -z ${features_array[16]} ]] || [[ -z ${features_array[17]} ]]
then

echo "test" > /dev/null

else

features_array[26]=$((${features_array[17]} - ${features_array[16]}))
# echo ${features_array[26]}

fi






newline=""



for i in "${features_array[@]}";
 do

    newline="$newline$i,"

done


newline=${newline::-1}


alllines[$k]=$newline

done





##sort kısmı

IFS=" "
read -r -a splitters <<< $splitargs

splitterarr=()

for i in "${splitters[@]}"
do

index=1

for j in "${column_array[@]}"
do

if [ "$i" = "$j" ]
then

    if [[ $index -lt 24 ]] && [[ $index -gt 18 ]]
    then
    echo "invalid sort parameter"
    exit
    fi

    splitterarr+=($index)
    index=$(($index + 1))
    else
    index=$(($index + 1))
    fi

done


done


for i in "${alllines[@]}"
do
echo $i >> temp2.csv
done

args=""

for ((i = 0; i<${#splitterarr[@]};i++))
do

args="$args -k$((${splitterarr[$i]})),$(($i + 1))"

done

newheader=""
for i in "${column_array[@]}";
 do

    newheader="$newheader$i,"

done

newheader=${newheader::-1}

echo $newheader > $outputfile

sort $args temp2.csv | sed "s/#/,/g" >> $outputfile

rm temp2.csv

