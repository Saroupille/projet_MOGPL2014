echo "This can be very long to process (about 5 hours). Most of the time is spend on question_15"
echo "You can edit this script to choose which questions need to be compile."
echo "However, the report will not compile if all the data are not there."
echo "You will need to compile the report by yourself"

dirs="question_3 question_6 question_7 question_11 question_15 question_16 question_16_bis"
#dirs="question_3"
script="generate_table_csv.sh"

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#rm -rf $BASE_DIR/../rapport/csv/$dir
#mkdir -p $BASE_DIR/../rapport/csv/$dir
#directory where the results are stored
CSV=${BASE_DIR}/../rapport/csv

if [ ! -d "$CSV" ]
then
	$(mkdir $CSV)
fi


for dir in $dirs
do
	echo "begin processing of ${dir}"
	rm -rf $CSV/$dir
	mkdir -p $CSV/$dir
	sh $BASE_DIR/$dir/$script
	cp "$BASE_DIR/$dir/csv/"* "$BASE_DIR/../rapport/csv/$dir/"
done



