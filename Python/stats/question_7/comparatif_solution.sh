#!/bin/sh

#number of test case for a n and a M fixed
test_number="2"
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
	min="100000"   # SALE SALE SALE
	max="0"

	echo "compute the models when n=${n}"
	command_run_model_P0="${CC} ${MODELP0} -p -n ${n} -M ${max_M} > P0_${n}.tmp"
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

				tmpmin="$(echo "${min} > ${var22}" | bc)"
				if [ "$tmpmin" -eq 1 ]
				then
					#echo "min $min, var $var22" 
					min="$var22"
				fi

				tmpmax="$(echo "${max} < ${var22}" | bc)"
				if [ "$tmpmax" -eq 1 ]
				then
					#echo "min $min, var $var22" 
					max="$var22"
				fi
			fi

		fi
	done < P0_${n}.tmp

	compt=$(echo "$compt" | bc)
	sum=$(echo "$sum" | bc)
	moy=$(echo ${sum}/${compt} | bc)

	#echo "test sur l'ecrat type"
	sumome="0"
	ome="0"
	while read line  
	do   
		if [ "${line:0:2}" = "(u" ]
		then 
			IFS="," 
			read -r var1 var2  <<< "${line:2:(${#line}-3)}"
			read -r var21 var22 <<< "${var2}"
			if [  "${var21:1:1}" = "1" ]
			then
				#si varrible utilisé
				tmpo=$(echo "${var22} - ${moy}" | bc)
				#echo $tmpo
				tmpo=$(echo "${tmpo} * ${tmpo}" | bc )
				sumome=$(echo "${sumome}+${tmpo}" | bc )
			fi
		fi
	done < P0_${n}.tmp

	ome=$(echo "${sumome}/${compt}" | bc )
	ome=$(echo "sqrt(${ome})" | bc )

	#format CSV: P0, VALEUR N, moyen, min, max, distance max-min
	echo "P0, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc), ${ome}"
	echo "P0, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc), ${ome}" >> "$CSV/data.csv" 

	command_run_model_P1="${CC} ${MODELP1} -p -n ${n} -M ${max_M} > P1_${n}.tmp"
	eval "${command_run_model_P1}"

	sum="0"
	compt="0"
	moy="0"
	min="100000"
	max="0"

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

				tmpmin="$(echo "${min} > ${var22}" | bc)"
				if [ "$tmpmin" -eq 1 ]
				then
					#echo "min $min, var $var22" 
					min="$var22"
				fi

				tmpmax="$(echo "${max} < ${var22}" | bc)"
				if [ "$tmpmax" -eq 1 ]
				then
					#echo "max $max, var $var22" 
					max="$var22"
				fi
			fi
		fi
	done < P1_${n}.tmp

	compt=$(echo "$compt" | bc)
	sum=$(echo "$sum" | bc)
	moy=$(echo ${sum}/${compt} | bc)
	
	#echo "test sur l'ecrat type"
	sumome="0"
	ome="0"
	while read line  
	do   
		if [ "${line:0:2}" = "(u" ]
		then 
			IFS="," 
			read -r var1 var2  <<< "${line:2:(${#line}-3)}"
			read -r var21 var22 <<< "${var2}"
			if [  "${var21:1:1}" = "1" ]
			then
				#si varrible utilisé
				tmpo=$(echo "${var22} - ${moy}" | bc)
				#echo $tmpo
				tmpo=$(echo "${tmpo} * ${tmpo}" | bc )
				sumome=$(echo "${sumome}+${tmpo}" | bc )
			fi
		fi
	done < P1_${n}.tmp

	ome=$(echo "${sumome}/${compt}" | bc )
	ome=$(echo "sqrt(${ome})" | bc )

	#format CSV: P1, VALEUR N, moyen, min, max, distance max-min
	echo "P1, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc), ${ome}"
	echo "P1, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc), ${ome}" >> "$CSV/data.csv"

	
done

	rm *.tmp

echo "fin"

