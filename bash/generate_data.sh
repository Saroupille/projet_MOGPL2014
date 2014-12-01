echo "This can be very long to process."
echo "Be careful if you press Ctrl+C. The compilation of the report can fail"

dirs="question_3 question_6 question_7 question_11 question_15 question_16 question_16_bis"
#dirs="question_3"
script="generate_table_csv.sh"

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
for dir in $dirs
do
	echo "begin processing of ${dir}"
	rm -rf $BASE_DIR/../rapport/csv
	mkdir -p $BASE_DIR/../rapport/csv/$dir
	sh $BASE_DIR/$dir/$script
	cp "$BASE_DIR/$dir/csv/"* "$BASE_DIR/../rapport/csv/$dir/"
done

