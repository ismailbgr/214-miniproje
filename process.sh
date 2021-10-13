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

column_names=$(cat $inputfiles | head -n 1)

# echo $column_names

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



# for i in "${alllines[@]}";do

# echo $i
# echo aaaaaaaaaaaaaaaaaaaaaaaaa

# done

# exit

#TODO Değiştir
# text=$(cat $inputfiles | tail -n 1 | sed -E 's/([a-Z]),([a-Z])/\1#\2/g' | sed -E 's/([a-Z]), /\1# /g')

for (( k = 0; k < ${#alllines[@]}; k++));do
text=${alllines[$k]}

IFS=$','

read  -r -a features_array <<< $text

# for i in ${features_array[*]};do

# echo $i

# done

features_array[26]=""

#echo ${column_array[26]}
features_array[18]=${features_array[0]}
features_array[22]=$(echo $(($(($(date --date="$(echo ${features_array[9]} | sed "s/\"//g")" +%s) - $( date --date="${features_array[3]}-01-01" +%s ))) / (60*60*24) ))  )
features_array[19]=$(printf '%.3f\n' $(echo "${features_array[0]} / ${features_array[22]}" | bc -l))
features_array[21]=$(( $(echo ${features_array[1]} | grep -o "#" | wc -l) + 1 ))
features_array[20]=$(printf '%.3f\n' $(echo "${features_array[0]} / ${features_array[21]}" | bc -l))


if [[ -z ${features_array[16]} ]] || [[ -z ${features_array[17]} ]]
then

echo "test" > /dev/null

else

features_array[26]=$((${features_array[17]} - ${features_array[16]}))
echo ${features_array[26]}

fi




# echo ${features_array[20]}

newline=""

# echo ${#features_array[@]}

for i in "${features_array[@]}";
 do

    newline="$newline$i,"

done
# echo ${#features_array[@]}
# echo ${features_array[0]}

newline=${newline::-1}

# echo "$newline"
alllines[$k]=$newline

done








# echo $(cat $inputfiles | sed "s/$column_names//g" | sed "s/\",\"/æ/g")
#| sed "s/,/€/g" | sed "s/æ/\",\"/g")


# for i in "${alllines[@]}";do

# echo "$i"

# done


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

echo ${splitterarr[@]}
# echo ${#alllines[@]}

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