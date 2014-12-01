#!/bin/sh
echo "question 11"
#TO DO :
# * rajouter une option pour supprimer les fichiers temporaires
# * rajouter une option pour supprimer les fichiers solutions
# * delete files csv if they already exist
# * améliorer le script

#number of test case for a n and a M fixed
test_number=10

#every value of n
size="10 50 100"
#every value of M
max_value="100"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#where is the model
MODEL_P3="${DIR}/../../python/modelisation_P3/P3.py"

MODEL_GRAPH="${DIR}/../../python/modelisation_graphe/approche_regret.py"

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
	echo "Méthode,10,50,100" > $CSV/question_11_${m}.csv
	#iterate over n
	for n in ${size}
	do
		global_time=0
		global_time_graph=0
		echo "compute the models when n=${n}"
		#for each test case
		for i in $(seq 1 ${test_number})
		do
			#command to run the model
			command_run_model="{ /usr/bin/time -f "%e" ${CC} ${MODEL_P3} -M ${m} -n ${n}; } 2>&1 | tail -n 1"
			command_run_graph="{ /usr/bin/time -f "%e" ${CC} ${MODEL_GRAPH} -M ${m} -n ${n}; } 2>&1 | tail -n 1"
			#run the model
			#echo $command_run_graph
			time=$(echo $(eval "${command_run_model}"))
			time_graph=$(echo $(eval "${command_run_graph}"))
			global_time=$(echo "${global_time} + ${time}" | bc -l)
			global_time_graph=$(echo "${global_time_graph} + ${time_graph}" | bc -l)
		done
		moyenne=$(echo "scale=3; ${global_time} / ${test_number}" | bc -l)
		moyenne_graph=$(echo "scale=3; ${global_time_graph} / ${test_number}" | bc -l)
		result=$(echo "${result},${moyenne}")
		result_graph=$(echo "${result_graph},${moyenne_graph}")
	done
	result=$(echo ${result#?})
	result_graph=$(echo ${result_graph#?})
	echo "\$\\mathcal{P}_1\$, ${result}" >> $CSV/question_11_${m}.csv
	echo "flot, ${result_graph}" >> $CSV/question_11_${m}.csv
done
