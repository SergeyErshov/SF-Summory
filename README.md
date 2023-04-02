# 🎉 Дипломный проект!

### ⚙️ вводные данные  


Среда выполнения представляет собой три ВМ в облаке Яндекс:

|        vm        |                 roles               |                                           description                                     |
| ---------------- | ----------------------------------- | ----------------------------------------------------------------------------------------- |
| srv              | deploing, logging, monitoring       | Vm for deploing apps, with logging and moniroting contenerized tools                      |
| kup-master       | master node                         | Master node for Kubernets cluster                                                         |
| kub-app          | worker node                         | Worker node for kubernetes cluster                                                        |

**Спринт №1**

Подготовка среды в облаке выполняется с помощью [terraform](https://github.com/SergeyErshov/SF-Summory/tree/main/terraform)  
Конфигурация виртуальных машин - с помощью [Ansible](https://github.com/SergeyErshov/SF-Summory/tree/main/ansible)  

Порядок деплоя:  

1. Выполнить ```cd ./terraform && terraform init && terraform apply```
   В результате выполнения данных комманд будут созданы 3 ВМ, описанные в таблице выше  

2. Перейти в каталог ansible
   
3. Выполнить playbook srv-deploy с тегом predeploy ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t predeploy ./playbooks/srv-deploy.yml```  
   В результате на ВМ srv установятся необходимые пакеты, docker, docker-compose  

4. Выполнить playbook kub-deploy с тегами kubinstall, master_init ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t kubinstall -t master_init ./playbooks/srv-deploy.yml```  
   В результате на обе ноды будут установлены необходимые пакеты, а также инициализирован кластер k8s  

5. Выполнить playbook kub-deploy с тегом worker_join ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t worker_join ./playbooks/kub-deploy.yml```  
   В рещультате worker нода будет добавоена в кластер  

6. Выполнить playbook kub-deploy с тегом master_cni ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t master_cni ./playbooks/kub-deploy.yml```  
   В рещультате на мастер ноде будут установлены необходимые инструменты для работы кластера

7. Зайти на мастер ноду по SSH, проверить статус узлов калстера командой ```kubectl get nodes```. В кластера должен быть один мастер и один воркер, оба со статусом Ready  

Конфигурация кластера:  

| hostname | role | internal ip |
| ------------------ | ------------------------- | ------------------ |
| master.ru-central1.internal | master-node | 10.128.0.35 |
| worker.ru-central1.internal | worker      | 10.128.0.21 |

На данном этапе окружения подготовлено к работе, спринт №1 завершен

