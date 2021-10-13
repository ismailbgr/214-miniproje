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

column_names=$(cat $inputfiles | head -n 1)

IFS=" "
read -r -a input_array <<< $inputfiles
IFS=$oldIFS

