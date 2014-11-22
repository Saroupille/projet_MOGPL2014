#!/bin/sh

#number of test case for a n and a M fixed
test_number="5 10 15 20	"
max_M="100"

#where is the model P0
MODELP0="../../modelisation_P0/P0.py"
#where is the model P1
MODELP1="../../modelisation_P1/P1.py"

#executable
CC="gurobi.sh"

#repertory with the solutions
SOLUTIONS="solutions"
CSV="csv"

if [ ! -d "$SOLUTIONS" ]
then
	$(mkdir solutions)
else
	rm -fr $SOLUTIONS/*
fi



if [ ! -d "$CSV" ]
then
	$(mkdir csv)
else
	rm -fr $CSV/*
fi


for n in ${test_number}
do
	sum="0"
	compt="0"

	echo "compute the models when n=${n}"
	command_run_model_P0="${CC} ${MODELP0} -p -n ${n} -M ${max_M} > P0_${n}.sol"
	eval "${command_run_model_P0}"

	while read line  
	do   
		if [ "${line:0:2}" = "(u" ]
		then 
			#echo "${line:2:(${#line}-3)}"
			IFS="," 
			read -r var1 var2  <<< "${line:2:(${#line}-3)}"
			read -r var21 var22 <<< "${var2}"
			echo "${var21},${var22}" >> "${SOLUTIONS}/P0_${n}.sol"
			if [  "${var21:1:1}" = "1" ]
			then
				compt+="+ 1"
				sum+="+ ${var22}"
			fi
		fi
	done < P0_${n}.sol

	#echo "$(echo "$compt" | bc), $(echo "$sum" | bc)" > "${SOLUTIONS}/P0_${n}moy.tmp"

	#format CSV: P0, VALEUR N, moyen, min, max, distance max-min
	echo $(echo "$compt" | bc)
	echo "P0, ${n}, $(echo $(echo "$(echo "$sum" | bc)/$(echo "$compt" | bc)") | bc)"
	

	command_run_model_P1="${CC} ${MODELP1} -p -n ${n} -M ${max_M} > P1_${n}.sol"
	eval "${command_run_model_P1}"

	sum="0"
	compt="0"
	
	while read line  
	do   
		if [ "${line:0:2}" = "(u" ]
		then 
			IFS="," 
			read -r var1 var2  <<< "${line:2:(${#line}-3)}"
			read -r var21 var22 <<< "${var2}"
			echo "${var21},${var22}" >> "${SOLUTIONS}/P1_${n}.sol"
			if [  "${var21:1:1}" = "1" ]
			then
				compt+="+ 1"
				sum+="+ ${var22}"
			fi
		fi
	done < P1_${n}.sol


	#format CSV: P1, VALEUR N, moyen, min, max, distance max-min
	echo $(echo "$compt" | bc)
	echo "P1, ${n}, $(echo $(echo "$(echo "$sum" | bc)/$(echo "$compt" | bc)") | bc)"
	
	
done
echo "fin"

