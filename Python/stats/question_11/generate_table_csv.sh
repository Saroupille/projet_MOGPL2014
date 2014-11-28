#!/bin/sh

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

#where is the model
MODEL="../../modelisation_P3/P3.py"

MODEL_GRAPH="../../modelisation_graphe/approche_regret.py"
#executable
CC="gurobi.sh"
CC_GRAPH="python2.7"

#repertory with the solutions 
SOLUTIONS="solutions/"

#temporary directory to store some data
TMP=tmp

#directory where the results are stored
CSV=csv

#check if the tmp directory exists
if [ ! -d "$TMP" ]
then
	$(mkdir tmp)
else
	rm -fr $TMP/*
fi

#the same for csv
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
	echo "Méthode,10,50,100" >> csv/time_${m}.csv
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
			command_run_model="{ /usr/bin/time -f "%e" ${CC} ${MODEL} -a ${m}_${n}_${i} -M ${m} -n ${n}; } 2>&1 | tail -n 1"
			command_run_graph="{ /usr/bin/time -f "%e" ${CC_GRAPH} ${MODEL_GRAPH} -v -M ${m} -n ${n}; } 2>&1 | tail -n 1"
			#run the model
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
	echo "\$\\mathcal{P}_1\$, ${result}" >> csv/time_${m}.csv
	echo "flot, ${result_graph}" >> csv/time_${m}.csv
done
