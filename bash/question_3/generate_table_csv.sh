#!/bin/sh

#number of test case for a n and a M fixed
test_number=10
#for testing
#size="10 50"
#every value of n
size="10 50 100 500 1000"
#every value of M
max_value="10 100 1000"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo ${DIR}
#where is the model
MODEL="${DIR}/../../python/modelisation_P0/P0.py"

#executable
CC="python2.7"

#repertory with the solutions 
SOLUTIONS="solutions/"

#temporary directory to store some data
TMP=tmp

#directory where the results are stored
CSV=csv

#check if the csv diretory exists
if [ ! -d "$CSV" ]
then
	$(mkdir csv)
else
	rm -fr $CSV/*
fi


#iterate over m
for m in ${max_value}
do
	echo "start new csv file for m=${m}"
	#header of the table
	echo "n, temps moyen, satisfaction moyenne, satisfaction minimum, satisfaction maximum" >> csv/data_${m}.csv
	#iterate over n
	for n in ${size}
	do	
		echo "compute the models when n=${n}"
		#for each test case
		tmp_file="$(mktemp)"
		for i in $(seq 1 ${test_number})
		do
			#command to run the model
			command_run_model="${CC} ${MODEL} -a ${m}_${n}_${i} -n ${n} >> ${tmp_file}"
			#run the model
			eval "${command_run_model}"
		done
		number_of_lines=$((n*test_number))
		#begininng of the command to get the result
		answers="cat solutions/${m}_${n}_{1..${test_number}}.sol | cut -d' ' -f2,3 | sort | tail -n ${number_of_lines}"
		echo "start processing the data"
		#the min is on the first line
		current_min=" $(eval "${answers} | head -n 1 | cut -d' ' -f2")"
		#the max is on the last line
		current_max=" $(eval "${answers} | tail -n 1 | cut -d' ' -f2")"
		#we use awk to compute the average
		current_avg=" $(eval "${answers} | awk '{sum+= \$2} END { print sum/NR}'")"

		#parse the line storing the resolution time
		times="cat ${tmp_file} | grep 'Explore' | cut -d' ' -f8"
		#one more time, we use awk to compute th average
		time_avg="$(eval "${times} | awk '{sum+= \$1} END { print sum/NR}'")"
		#Store all the data in the csv file
		echo "${n}, ${time_avg}, ${current_avg}, ${current_min}, ${current_max}" >> csv/data_${m}.csv
	done
done

echo "delete the solutions files"
rm -rf ${SOLUTIONS}/*
rmdir ${SOLUTIONS}
