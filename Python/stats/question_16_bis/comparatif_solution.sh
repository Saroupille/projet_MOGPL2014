#!/bin/sh

#number of test case for a n and a M fixed
nb_test="50"
val_max_n="20"
max_M="100"

#where is the model OWA
MODELOWA="../../modelisation_OWA/OWA.py"
#where is the model P0
MODELP0="../../modelisation_P0/P0.py"

#executable
CC="python2.7"

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

for ((n=5; n<=${val_max_n}; n+=5))
do
	moyGlobal="0"
	minGlobal="0"
	maxGlobal="0"
	maxminGlobal="0"
	ecartGlobal="0"

	#echo "compute the models when n=${n}"
	echo "Iteration, Model, valeur n, moyenne, val max, val min, difference max-min, ecart type" >> "$CSV/data_${n}.csv"
	for ((i=0; i<${nb_test}; i++))
	do
		sum="0"
		compt="0"
        # valeur arbitraire pour l'initialisation, car nous n'avons pas de valeur retourne par le programme
		min="10000000"
		max="0"

		command_run_model_OWA="${CC} ${MODELOWA} -p -n ${n} -M ${max_M} > OWA_${n}_${i}.tmp"
		eval "${command_run_model_OWA}"

		while read line  
		do   
			if [ "${line:0:2}" = "(u" ]
			then 
				IFS=","
				read -r var1 var2  <<< "${line:2:(${#line}-3)}"
				read -r var21 var22 <<< "${var2}"
				echo "${var21},${var22}" >> "${SOLUTIONS}/OWA_${n}.sol"
				if [  "${var21:1:1}" = "1" ]
				then
					compt+="+ 1"
					sum+="+ ${var22}"

					tmpmin="$(echo "${min} > ${var22}" | bc -l)"
					if [ "$tmpmin" -eq 1 ]
					then
						min="$var22"
					fi

					tmpmax="$(echo "${max} < ${var22}" | bc -l)"
					if [ "$tmpmax" -eq 1 ]
					then
						max="$var22"
					fi
				fi

			fi
		done < OWA_${n}_${i}.tmp

		compt=$(echo "$compt" | bc -l)
		sum=$(echo "$sum" | bc -l)
		moy=$(echo ${sum}/${compt} | bc -l)

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
					tmpo=$(echo "${var22} - ${moy}" | bc -l)
					tmpo=$(echo "${tmpo} * ${tmpo}" | bc -l )
					sumome=$(echo "${sumome}+${tmpo}" | bc -l )
				fi
			fi
		done < OWA_${n}_${i}.tmp

		ome=$(echo "${sumome}/${compt}" | bc -l )
		ome=$(echo "sqrt(${ome})" | bc -l )

		#format CSV: OWA, VALEUR N, moyen, min, max, distance max-min ecrat type
		echo "${i}, OWA, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc -l), ${ome}" >> "$CSV/data_${n}.csv"

		moyGlobal=$(echo "${moyGlobal} + ${moy}" | bc -l)
		maxGlobal=$(echo "${maxGlobal} + ${max}" | bc -l)		
		minGlobal=$(echo "${minGlobal} + ${min}" | bc -l)	
		maxminGlobal=$(echo "${maxminGlobal} + $(echo "${max}-${min}" | bc -l)" | bc -l)
		ecartGlobal=$(echo "${ecartGlobal} + ${ome}" | bc -l)

	done
	moyGlobal=$(echo "scale=2; ${moyGlobal} / ${nb_test}" | bc -l)
	maxGlobal=$(echo "scale=2; ${maxGlobal} / ${nb_test}" | bc -l)
	minGlobal=$(echo "scale=2; ${minGlobal} / ${nb_test}" | bc -l)
	maxminGlobal=$(echo "scale=2; ${maxminGlobal} / ${nb_test}" | bc -l)
	ecartGlobal=$(echo "scale=2; ${ecartGlobal} / ${nb_test}" | bc -l)


	echo "GLOBAL OWA ${n}: ${moyGlobal}, ${maxGlobal}, ${minGlobal}, ${maxminGlobal}, ${ecartGlobal}"
	echo "Model, moyenne, val max, val min, difference max-min, ecrat type" >> "$CSV/res_${n}.csv"
	echo "OWA, ${moyGlobal}, ${maxGlobal}, ${minGlobal}, ${maxminGlobal}, ${ecartGlobal}" >> "$CSV/res_${n}.csv"

	#MODEL P0
	moyGlobal="0"
	minGlobal="0"
	maxGlobal="0"
	maxminGlobal="0"
	ecartGlobal="0"

	for ((i=0; i<${nb_test}; i++))
	do
		command_run_model_P0="${CC} ${MODELP0} -p -n ${n} -M ${max_M} > P0_${n}_${i}.tmp"
		eval "${command_run_model_P0}"

		sum="0"
		compt="0"
		moy="0"
		min="10000000"
		max="0"

		while read line  
		do   
			if [ "${line:0:2}" = "(u" ]
			then 
				IFS="," 
				read -r var1 var2  <<< "${line:2:(${#line}-3)}"
				read -r var21 var22 <<< "${var2}"
				echo "${var21},${var22}" >> "${SOLUTIONS}/P0_${n}.sol"
				if [  "${var21:1:1}" = "1" ]
				then
					compt+="+ 1"
					sum+="+ ${var22}"

					tmpmin="$(echo "${min} > ${var22}" | bc -l)"
					if [ "$tmpmin" -eq 1 ]
					then
						min="$var22"
					fi

					tmpmax="$(echo "${max} < ${var22}" | bc -l)"
					if [ "$tmpmax" -eq 1 ]
					then
						max="$var22"
					fi
				fi
			fi
		done < P0_${n}_${i}.tmp

		compt=$(echo "$compt" | bc -l)
		sum=$(echo "$sum" | bc -l)
		moy=$(echo ${sum}/${compt} | bc -l)
		
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
					tmpo=$(echo "${var22} - ${moy}" | bc -l)
					tmpo=$(echo "${tmpo} * ${tmpo}" | bc -l )
					sumome=$(echo "${sumome}+${tmpo}" | bc -l )
				fi
			fi
		done < P0_${n}_${i}.tmp

		ome=$(echo "${sumome}/${compt}" | bc -l )
		ome=$(echo "sqrt(${ome})" | bc -l )

		#format CSV: P0, VALEUR N, moyen, min, max, distance max-min
		echo "${i}, P0, ${n}, ${moy}, ${min}, ${max}, $(echo "${max}-${min}" | bc -l), ${ome}" >> "$CSV/data_${n}.csv"

		moyGlobal=$(echo "${moyGlobal} + ${moy}" | bc -l)
		maxGlobal=$(echo "${maxGlobal} + ${max}" | bc -l)		
		minGlobal=$(echo "${minGlobal} + ${min}" | bc -l)	
		maxminGlobal=$(echo "${maxminGlobal} + $(echo "${max}-${min}" | bc -l)" | bc -l)
		ecartGlobal=$(echo "${ecartGlobal} + ${ome}" | bc -l)
	done

	moyGlobal=$(echo "scale=2; ${moyGlobal} / ${nb_test}" | bc -l)
	maxGlobal=$(echo "scale=2; ${maxGlobal} / ${nb_test}" | bc -l)
	minGlobal=$(echo "scale=2; ${minGlobal} / ${nb_test}" | bc -l )
	maxminGlobal=$(echo "scale=2; ${maxminGlobal} / ${nb_test}" | bc -l)
	ecartGlobal=$(echo "scale=2; ${ecartGlobal} / ${nb_test}" | bc -l)


	echo "GLOBAL P0 ${n}: ${moyGlobal}, ${maxGlobal}, ${minGlobal}, ${maxminGlobal}, ${ecartGlobal}"
	echo "P0, ${moyGlobal}, ${maxGlobal}, ${minGlobal}, ${maxminGlobal}, ${ecartGlobal}" >> "$CSV/res_${n}.csv"


done
rm *.tmp
rm -fr ${SOLUTIONS}


