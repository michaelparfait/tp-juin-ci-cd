# k8s-cluster-vagrant-ansible

## Description

Ce projet vous permet de déployer un cluster kubernetes multi-nœuds à l'aide de Vagrantfile et Ansible

## Comment

### Déployer et exécuter les nœuds

```sh
vagrant up
```

### Configurer le cluster k8s

Vous pouvez configurer votre cluster k8s en éditant les `CONFIGURATION VARIABLES` disponibles dans le `Vagrantfile`

### Configurez votre kubectl

Voici comment configurer l'outil kubectl sur votre machine locale pour communiquer avec l'API kubernetes :

```sh
scp -r vagrant@192.168.50.10:/home/vagrant/.kube $HOME/
password = vagrant
```
Testez votre config comme dans l'exemple ci-dessous :

```sh
kubectl get nodes
```

Résultat :

```
NAME       STATUS   ROLES    AGE   VERSION
master     Ready    master   35m   v1.15.1
worker-1   Ready    <none>   30m   v1.15.1
```

### Se connecter au maître via ssh

Soit vous êtes au même niveau que votre Vagrantfile, dans ce cas vous lancez la commande suivante :

```sh
vagrant ssh master
```

Soit vous êtes dans un autre dossier :

```sh
ssh -r vagrant@192.168.50.10
password = vagrant
```
