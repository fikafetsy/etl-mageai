#!/bin/bash

ask_confirmation() {
    read -p "Voulez-vous continuer ? (yes/y pour continuer) : " response
    if [[ "$response" == "yes" || "$response" == "y" ]]; then
        echo "Continuons..."
        return 0
    else
        echo "Opération annulée."
        exit 1
    fi
}

# Variables
PWD=$(pwd)
CONTAINER_NAME="mage-ai-magic-1"
GIT_REPO="git@github.com:fikafetsy/etl-mageai.git"
PROJECT_DIR="mage-ai"
MAGE_ISO_PROD_DEV=$PWD
DIR_NOT_DELETE=pipeline_save

# Vérification des arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  run            - Cloner le projet et démarrer les services"
    echo "  stop [--rmi]   - Arrêter le conteneur $CONTAINER_NAME (ajoutez --rmi pour supprimer l'image associée)"
    echo "  update-env     - Re-copier .env-dev et intégrer les changements dans le conteneur"
    exit 1
fi

OPTION=$1
REMOVE_IMAGE=false

# Vérifier si l'option --rmi est passée pour supprimer l'image
if [ "$OPTION" == "stop" ] && [ "$2" == "--rmi" ]; then
    REMOVE_IMAGE=true
fi

if [ "$OPTION" == "run" ]; then
    # Option run: Cloner le projet
    echo "Clonage du projet depuis $GIT_REPO..."
    git clone "$GIT_REPO"

    # Copier le fichier .env-dev dans le dossier cloné
    echo "Copie du fichier .env..."
    cp .env $PROJECT_DIR/.env

    # Démarrer les services avec Docker Compose
    echo "Démarrage des services avec Docker Compose..."
    cd $PROJECT_DIR
    docker-compose up -d

    # Afficher les détails du conteneur
    echo "Détails du conteneur $CONTAINER_NAME :"
    docker ps -f name=$CONTAINER_NAME --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"

elif [ "$OPTION" == "stop" ]; then
    # Option stop: Arrêter et supprimer le conteneur $CONTAINER_NAME
    echo "Arrêt du conteneur $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME

    echo "Copie les fichier *.py"
    cp ../pipeline_save/*.py $MAGE_ISO_PROD_DEV

    echo "Copie les fichiers du dossier $DIR_NOT_DELETE vers $MAGE_ISO_PROD_DEV..."
    cp -rv $DIR_NOT_DELETE/* $MAGE_ISO_PROD_DEV

    echo "Suppression du conteneur $CONTAINER_NAME..."
    docker rm $CONTAINER_NAME

    # Si l'option --rmi est utilisée, supprimer l'image associée
    if [ "$REMOVE_IMAGE" = true ]; then
        IMAGE_ID=$(docker inspect --format="{{.Image}}" $CONTAINER_NAME)
        if [ -n "$IMAGE_ID" ]; then
            echo "Suppression de l'image $IMAGE_ID..."
            docker rmi $IMAGE_ID
        else
            echo "Aucune image trouvée pour le conteneur $CONTAINER_NAME"
        fi
    fi

    ask_confirmation

    # Supprimer tous les dossiers au même niveau que mage.sh sauf bobodata
    echo "Suppression des dossiers au même niveau que mage.sh sauf bobodata..."
    find . -maxdepth 1 -type d ! -name '.' ! -name 'pipeline_save' -exec rm -rf {} +


elif [ "$OPTION" == "update-env" ]; then
    # Option update-env: Re-copier .env et redémarrer les services
    echo "Mise à jour du fichier .env ..."
    
    if [ -d "$PROJECT_DIR" ]; then
        # Copier le nouveau fichier .env-dev dans le projet cloné
        cp .env $PROJECT_DIR/.env
        
        # Redémarrer les services pour appliquer les nouveaux changements
        echo "Redémarrage des services pour intégrer les changements..."
        cd $PROJECT_DIR
        docker-compose down
        docker-compose up -d
        
        echo "Les services ont été redémarrés avec les nouvelles variables d'environnement."
    else
        echo "Erreur : Le dossier $PROJECT_DIR n'existe pas. Assurez-vous que le projet est cloné."
    fi

else
    echo "Option non valide. Utilisez 'run', 'stop' ou 'update-env'."
    exit 1
fi

