#!/bin/bash

REPERTOIRE=""

#taches 0 et 1 privilégier utilisation des paramètres positionnels 
#ou demander repertoire

#fonction pour demander le repertoire
demander_repertoire() {
	read -p "Répertoire à traiter: " REPERTOIRE_DONNE

	if [ -z "$REPERTOIRE_DONNE" ]; then
		REPERTOIRE="./"
	else
		REPERTOIRE="$REPERTOIRE_DONNE"
	fi

	if [ ! -d "$REPERTOIRE" ]; then
		echo "Le répertoire n'existe pas :("
		echo ""
		demander_repertoire
	else 
		echo "Répertoire séléctionné: $REPERTOIRE"
		echo ""
	fi

}


#verifie si il $1 existe sinon utilise la fonction pour demander le repertoire
if [ -n "$1" ]; then
	REPERTOIRE="$1"

	if [ ! -d "$REPERTOIRE" ]; then
		echo "Le répertoire n'existe pas :("
		echo ""
		demander_repertoire
	else 
		echo "Répertoire séléctionné: $REPERTOIRE"
		echo ""
	fi

else
	demander_repertoire
fi



#tache 2 choix de l'action et texte à utiliser
ACTION=""

#fonction pour choisir l'action
demander_action() {
	echo "Actions possibles: pre, su, min (Ajouter un préfixe, Ajouter un suffixe, Convertir en minuscules)"
	read -p "Action: " ACTION_DONNEE
	if [ "$ACTION_DONNEE" == "pre" ] || [ "$ACTION_DONNEE" == "su" ] || [ "$ACTION_DONNEE" == "min" ]; then
		ACTION="$ACTION_DONNEE"
		echo Action séléctionnée: $ACTION
		echo ""
	else
		echo "$ACTION_DONNEE n'est pas une action valide"
		echo ""
		demander_action
	fi
}

#verifie si $2 existe sinon utilise la fonction pour demander l'action
if [ -n "$2" ]; then
	if [ "$2" == "pre" ] || [ "$2" == "su" ] || [ "$2" == "min" ]; then
		ACTION="$2"
		echo Action séléctionnée: $ACTION
		echo ""
	else
		echo "$2 n'est pas une action valide"
		echo ""
		demander_action
	fi
else
	demander_action
fi

#$3 texte a ajouter en prefixe ou suffixe
TEXTE=""

#fonction pour demander le texte
demander_texte() {
	echo Entrez le préfixe ou suffixe à utiliser
	read -p "Texte: " TEXTE_DONNE
	TEXTE=$TEXTE_DONNE
	echo "Préfixe/suffixe utilisé: $TEXTE"
	echo ""
}

#verifie si $3 existe, et si l'action est min laisser TEXTE vide
if [ -n "$3" ]; then
	if [ "$ACTION" == "min" ]; then
		TEXTE=""
	else
		TEXTE="$3"
		echo "Préfixe/suffixe utilisé: $TEXTE"
		echo ""
	fi
else
	if [ ! "$ACTION" == "min" ]; then
		demander_texte
	fi
fi

#tache 3: renommage

echo "Traitement en cours..."
echo "Renommage dans $REPERTOIRE"
echo ""

FICHIERS_RENOMMES=0 #compteur de fichiers renommés

#Renommage des fichiers
#Boucle qui s'effectue pour chaque fichier du repertoire
while IFS= read -r -d $'\0' CHEMIN_FICHIER; do

	NOM_ACTUEL=$(basename "$CHEMIN_FICHIER")
	NOUVEAU_NOM=""

	BASE_NOM="${NOM_ACTUEL%.*}" #nom sans l'extension
	EXT="${NOM_ACTUEL##*.}" #juste l'extension

	EXTENSION=""
	#ajouter le point si il y a bien une extension
	if [ "$NOM_ACTUEL" != "$EXT" ]; then
        EXTENSION=".${EXT}"
    fi



	#Renommage:
	#case pour faire la bonne action de renommage en fonction de l'action choisie par l'utilisateur
	case "$ACTION" in
		"pre")
			#ajout du prefixe
			NOUVEAU_NOM="${TEXTE}${BASE_NOM}${EXTENSION}"
			;;
		"su")
			#ajout suffixe
			NOUVEAU_NOM="${BASE_NOM}${TEXTE}${EXTENSION}"
			;;
		"min")
			#mise en minuscules
			NOM_COMPLET="${BASE_NOM}${EXTENSION}" 
			NOUVEAU_NOM=$(echo "$NOM_COMPLET" | tr '[:upper:]' '[:lower:]' )
			;;
	esac

	#vérification si le nomveau nom est le même que l'ancien
	#(pour pas que des fichiers inchangés soient comptés dans le compteur des fichiers renommés)
	if [ "$NOM_ACTUEL" != "$NOUVEAU_NOM" ]; then

		#renommage:
		mv -n "${CHEMIN_FICHIER}" "${REPERTOIRE}/${NOUVEAU_NOM}"

		#affichage du résumé
		echo "${NOM_ACTUEL} --> $NOUVEAU_NOM"

		#compteur
		FICHIERS_RENOMMES=$((FICHIERS_RENOMMES+1))
	fi
done < <(find "$REPERTOIRE" -maxdepth 1 -type f -not -name ".*" -print0)

#affichage résumé final
echo ""
echo "Effectué ! $FICHIERS_RENOMMES fichiers renommés!"
