# search for type in swift files
array=()

# find /Users/ahmedosman/flix-app/flixapp -name '*.swift' -print0 > .files

function name () {
cat .files | while IFS=  read -r -d $'\0'; do

found=$(grep -Hn '[class|struct|protocol] '$1 "$REPLY")
if [ ! -z "$found" ]; then
echo $found
echo ------
# echo $REPLY
    array+=("$REPLY")
fi
done
}

for type in "$@"; do
    name $type
done


echo ${array[@]}

# search for type in swift files
# array=()
# while IFS=  read -r -d $'\0'; do
#     found=$(grep -Hn '[class|struct|protocol] *TransportProgressInfo' "$REPLY")
#     if [ ! -z "$found" ]; then
#         array+=("$REPLY")
#     fi
# done < <(find /Users/ahmedosman/flix-app/flixapp/Classes/Presentation/Shared/Route -name '*.swift' -print0)

# echo ${array[@]}