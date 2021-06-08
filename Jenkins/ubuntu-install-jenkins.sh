#!/bin/bash

### MODE SECURE
set -u # en cas de variable non définit, arreter le script
set -e # en cas d'erreur (code de retour non-zero) arreter le script

### UTILITER ###
# fonctions, variables, etc.
# afin d'eviter les collisions, je vais préfixer mes fonction par ps_
# ps égale Poste
PACKAGES_LIST="gnupg gnupg2 gnupg1 openjdk-11-jdk ufw jenkins"
JENKINS_PACKAGE="jenkins"
SECRET_DIRECTORY="/var/lib/jenkins/secrets/initialAdminPassword"
USER_JOB_JENKINS="userjob"
HOME_BASE="/home/"
HOME_JENKINS="${HOME_BASE}${USER_JOB_JENKINS}"
PARTITION_EXT4="/dev/sdb1"
STORAGE="/storage"

# Afficher de l'aide
ps_help(){
	1>&2 echo "Usage: ./script.sh DOMAIN"
	1>&2 echo ""
}

# Vérifier que le script est lancé en tant que root
ps_assert_root(){
	REAL_ID="$(id -u)"
	if [ "$REAL_ID" -ne 0 ]; then
		1>&2 echo "ERREUR: Le script doit etre exécuté en tant que root"
		exit 1
	fi
}

ps_install_package() {
    PACKAGE_NAME="$1"
    if ! dpkg -l |grep --quiet "^ii.*$PACKAGE_NAME " ; then
        apt install -y "$PACKAGE_NAME"
    else
        echo ""
        echo "$PACKAGE_NAME est déjà installé."
    fi
}

# Vérification d'un package
ps_verif_package() {
    PACKAGE_NAME="$1"
    if ! dpkg -l |grep --quiet "^ii.*$PACKAGE_NAME " ; then
       echo "$PACKAGE_NAME n'est pas installé."
    else
        echo ""
        echo "$PACKAGE_NAME est déjà installé."
    fi
}

# Installation de jenkins
ps_install_jenkins(){
    PACKAGE_NAME_0="$1"
    echo "Install Jenkins"
    # add the repository key to the system
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt update
    apt install -y $PACKAGE_NAME_0

}
#function to start jenkins
ps_start_jenkins(){
    # start jenkins
    systemctl start jenkins
    # verify status if jenkins started successfully
    # systemctl status jenkins
}

#function to init the firewall
ps_init_firewall(){
  # by default jenkins runs on port 8080
  ufw allow 8080
  # allow protocol ssh
  ufw allow OpenSSH
  # enable the firewall
	ufw enable <<<y
}

ps_create_update_user_jenkins(){
    if ! id "$USER_JOB_JENKINS" 2>/dev/null ; then
      echo "$USER_JOB_JENKINS doit être créé"
      # on creer le nouvel utilisateur
      sudo useradd -d $HOME_BASE$USER_JOB_JENKINS -s /bin/bash -m $USER_JOB_JENKINS
      echo "$USER_JOB_JENKINS:$USER_JOB_JENKINS" | sudo chpasswd
      [ $? -eq 0 ] && echo "User $USER_JOB_JENKINS has been added !" || echo "Failed !"
      # rajout des droits
      sudo cp /etc/sudoers /etc/sudoers.old
      echo "$USER_JOB_JENKINS ALL=(ALL) /usr/bin/apt" | sudo tee -a /etc/sudoers
    fi
}

ps_verif_user_jenkins_exist(){
    if id "$USER_JOB_JENKINS" 2>/dev/null ; then
        echo "$HOME_JENKINS exist we have to delete it"
        sudo userdel userjenkins
        sudo rm -rf $HOME_JENKINS
    fi
}

# function to show the user the secret password jenkins
ps_display_initialAdminPassword(){
    echo "*******************************"
    echo "Password initial admin jenkins"
    sleep 10s
    sudo cat $SECRET_DIRECTORY
    echo "*******************************"
}

ps_display_ipadress_machine(){
    echo "*******************************"
    echo "Adresse ip serveur jenkins"
    echo "Veuillez notez votre IP quelque part"
    # Cette command permet de récupérer l'adresse ip de la machine après un ip on va filtrer
    ip a | grep eth1 | grep inet | awk -F "/" '{print $1}' | awk -F " " '{print $2}'
    echo "*******************************"
}


### POINT D'ENTRER DU SCRIPT ###

## Vérifier que le script est lancé en tant que root
ps_assert_root

## mise à jour du dépot de package
apt-get update

## Instalation de la liste de nos packages
for PACKAGE in $PACKAGES_LIST ; do
    # Instalation du package
    if [ "$PACKAGE" = "$JENKINS_PACKAGE" ] ; then
       ps_install_jenkins "$PACKAGE"
    else
       ps_install_package "$PACKAGE"
    fi
done

## Start jenkins
ps_start_jenkins

## Init and start the firewall
ps_init_firewall

## Create user jenkins
ps_verif_user_jenkins_exist
ps_create_update_user_jenkins

## Show initial password admin
ps_display_initialAdminPassword

## Display ip machine for user
ps_display_ipadress_machine
echo ""
echo "Success"

