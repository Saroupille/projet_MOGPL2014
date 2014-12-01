Le projet se trouve sur github à l'adresse suivante : [projet MOGPL 2014](https://github.com/Saroupille/projet_MOGPL2014)

#Utiliser gurobi avec Python

Il suffit d'utiliser la commande `gurobi.sh mon_modele.py`. A noter que pour les modèles utilisant *pygraph* on utilisera plutôt `python2.7 mon_modele.py`.

#Génération des statistiques

Pour chaque tableau du rapport, on trouvera le fichier csv par défault correspondant dans le dossier *rapport/csv/question_\<numero\>/*. Ce fichier aura été généré par un script bash se trouvant dans le répertoire *bash/question_\<numero\>/*.

Il est possible de relancer les tests en utilisant le script *bash/generate_data.sh*. Cependant cela peut durer plusieurs heures à cause de la question 15. Il est cependant possible d'éditer ce fichier pour choisir les fichiers à régénérer.

##Configuration

Les tests ont été fait sur un ordinateur *TOSHIBA portege z930-10t*. La configuration peut se trouver ici : [configuration z930-10t](http://www.materiel.net/ordinateur-portable/toshiba-portege-z930-10t-80440.html).


