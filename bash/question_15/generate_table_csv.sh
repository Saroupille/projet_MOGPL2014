#!/bin/sh
echo "question 15"
#TO DO :
# * rajouter une option pour supprimer les fichiers temporaires
# * rajouter une option pour supprimer les fichiers solutions
# * delete files csv if they already exist
# * améliorer le script

#number of test case for a n and a M fixed
test_number=10
size="10 50 100"
#every value of n
#size="10 50 100 500 1000"
#every value of M
max_value="100"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#where is the model
MODEL="${DIR}/../../python/modelisation_OWA/OWA.py"

#executable
CC="python2.7"

#directory where the results are stored
CSV=${DIR}/csv

#the same for csv
if [ ! -d "$CSV" ]
then
	$(mkdir $CSV)
else
	rm -fr $CSV/*
fi


#iterate over m
for m in ${max_value}
do
	echo "start new csv file for m=${m}"
	#header of the table
	echo "size, moyenne des satisfactions, temps moyen (en seconde)" >> ${CSV}/question_15_${m}.csv
	#iterate over n
	for n in ${size}
	do	
		echo "compute the models when n=${n}"
		#for each test case
		for i in $(seq 1 ${test_number})
		do
			#command to run the model
			tmp_file=$(mktemp)
			command_run_model="${CC} ${MODEL} -M ${m} -n ${n} > ${tmp_file}"
			eval "${command_run_model}"
			time=$(cat ${tmp_file} | grep 'Explore' | cut -d' ' -f8)
			value=$(cat ${tmp_file} | tail -n 1)
			#echo "$time"
			#echo "$value"
			time_t="$time"+${time_t:-0}
			value_t="$value"+${value_t:-0}
		done
		echo "end of the execution of the models"
		time_avg=$(echo "scale=2; ($time_t) / ${test_number}" | bc -l)
		value_avg=$(echo "scale=2; ($value_t) / ${test_number}" | bc -l)
		echo "${n},${value_avg},${time_avg}" >> $CSV/question_15_${m}.csv 		
	done
done
