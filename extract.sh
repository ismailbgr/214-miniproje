while getopts "t:i:o:v:" arg; do
    case $arg in
        t)
            argt=$OPTARG
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
        v) 
            argv=$OPTARG
            # echo "outputfile:$outputfile"

        ;;
    esac
done

if [[ -z $inputfiles ]]
then

echo "input girilmedi"
exit

fi

if [[ -z $argt ]]
then

echo "-t girilmedi"
exit

fi

if [[ -z $argv ]]
then

echo "-v girilmedi"
exit

fi

if [[ -z $outputfile ]]
then

echo "output adı girilmedi"
exit

fi

column_names=$(cat $inputfiles | head -n 1)

# echo $column_names

oldIFS=$IFS

IFS=,

read -r -a column_array <<< "$column_names"

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

alllines[$index]=$(echo $line | sed -E 's/([a-Z]),([a-Z])/\1€\2/g' | sed -E 's/([a-Z]), /\1€ /g')
index=$(($index + 1))

done < temp.csv

rm temp.csv

allauthors=()

alltitles=()

for (( k = 0; k < ${#alllines[@]}; k++));do
text=${alllines[$k]}

IFS=$','

read  -r -a features_array <<< $text

allauthors+=(${features_array[1]})
alltitles+=(${features_array[2]})
done

for i in ${allauthors[@]}
do

echo $i >> temp.csv

done

sed  "s/€/\n/g" temp.csv | sed "s/\"//g"> temp2.csv

sort temp2.csv | uniq | sed "s/^ *//g" > temp3.csv

uniqauths=()

while read line
do

uniqauths+=($line)

done < temp3.csv

index=1

echo -n "" > $argt

for i in "${uniqauths[@]}"
do

    echo "$i,$index" >> $argt
    index=$(($index+1))

done

rm temp*.csv

for (( i=0;i < "${#alltitles[@]}" ; i++ ))
do

echo "${alltitles[$i]},$(echo ${allauthors[$i]} | sed 's/\"//g')" >> tempa.csv 

done
index=0

for j in ${uniqauths[@]}
do

for i in "${!uniqauths[@]}";
do

    if [[ "${uniqauths[$i]}" = "$j" ]];
    then
        index=$(($i + 1))
        break
    fi
done


sed "s/$j/$index/g" -i tempa.csv

sed "s/€/,/g" tempa.csv | sed -E "s/ *, */,/g" > $outputfile

done

declare -A matrix

lines=()

IFS=$'\n'

while read line
do
lines+=($line)

done < $outputfile








for (( i=0 ; i < ${#uniqauths[@]}; i++ ))
    do

        for (( j=0; j<${#uniqauths[@]}; j++  ))
        do

            matrix["$i,$j"]=0

        done

    done







for i in "${lines[@]}"
do

temp=$(echo $i | sed -E 's/\"[a-zA-Z1-9 ]*\",//g' )

IFS=,
temparr=($temp)
IFS=$'\n'

    

    for (( i=0; i<${#temparr[@]}; i++ ))
    do

        for (( j=$i; j<${#temparr[@]}; j++ ))
        do

            matrix["$i,$j"]=$((${matrix["$i,$j"]} + 1))
            matrix["$j,$i"]=$((${matrix["$j,$i"]} + 1))
            matrix["$i,$i"]=0
        done

    done


done

str=""

str+=" ,"
for (( i=1; i<=${#temparr[@]}; i++ ))
do
str+="$i,"
done

str=${str::-1}

echo $str > $argv
str=""
IFS=$'\n'

for (( i=0; i<${#temparr[@]}; i++ ))
    do

        str+="$(($i + 1)),"
        for (( j=0; j<${#temparr[@]}; j++ ))
        do

            str+=${matrix["$i,$j"]}
            str+=","

        done
        str=${str::-1}
        echo $str >> $argv
        str=""


    done

rm temp*.csv