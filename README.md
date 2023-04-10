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

**Спринт №2**

1. Дополняем playbook srv-deploy.yml секцией сборки и доставки приложения на srv. Чувствительные данные храним в файле .var, расположенном в директории .metadata, котороя исключена
   из отслеживания git. Файл .var передаем в docker-compose директивой env_file.   

   ![env_file](https://github.com/SergeyErshov/SF-Summory/blob/main/RAW/1_env_file.png "env_file")  

2. Выполняем playbook srv-deploy с тегом app_deploy ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t app_deploy ./playbooks/srv-deploy.yml```  
   
3. Подключаемся на сервер srv и деплоим наше приложение с помощью docker-compose ```docker-compose up -d``` проверяем, что приложение поднялось, проверяем лог docker-compose
   на предмет отсутсвия ошибок.  

4.  Дополняем playbook srv-deploy.yml секцией установки gitlab-runner на машину srv. Выполняем playbook ```ansible-playbook -i ./inventory -u <user> --private-key <path_to_key> -t runner_inst ./playbooks/srv-deploy.yml```  

5. В GitLab создаем новый [проект](https://gitlab.com/sf-devops32/fs-summury) и настраиваем в нем CI, получаем токен.    

6. Подключаемся к srv, регистрируем наш раннер, проверяем его доступность в GitLab.  

7. Создаем [pipeline](https://github.com/SergeyErshov/SF-Summory/blob/main/.gitlab-ci.yml), который будет автоматически запускаться при пуше нового тега в репозиторий, билдить наше     приложение и пушить его в докерхаб с тем тегом, который был запушен в репозиторий.  
   
8. Подготовим манифесты для кластера kubernetes, выполним playbook kub-deploy.yml с тегом manifest для копирования манифестов на мастер ноду.  
   
9. Подключаемся к master ноде по ssh, создаем отдельный неймспейс для наших приложений, переходим в директорию с манифестами и выполняем ```kubectl apply -f .```. Проверяем, что поды с нашими контейнерами поднялись командой ```kubectl get pods```   
    
10. Выполняем ```ansible-playbook -i ./inventory -u esm --private-key ~/.ssh/id_ed25519 -t helm ./playbooks/kub-deploy.yml``` для установки helm на мастер-ноду.  

11. Подготавливаем структуру helm-чарта из ранее созданных манифестов.  
    
12. Выполняем ```ansible-playbook -i ./inventory -u esm --private-key ~/.ssh/id_ed25519 -t helm_chart ./playbooks/kub-deploy.yml``` для копирования helm-чарта на мастер ноду.  

13. Подключаемся пл ssh к мастер ноде, удаляем все ранее созданные ресурсы в текущем наймспейсе, переходим в директорию с нашим helm-чартом и выполняем ```helm upgrade --install myapp .```  

14. Проверяем, что поды с нашими контейнерами поднялись командой ```kubectl get pods```. Проверяем доступность нашего приложения.
   
15. Деплоим ingress controller на мастер ноде ```kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.7.0/deploy/static/provider/cloud/deploy.yaml```  

16. Регистрируем агента gitlab по [этому мануалу](https://docs.gitlab.com/ee/user/clusters/agent/install/index.html) (альтернативно helm чарт агента получаем [отсюда](https://cloud.yandex.com/en/docs/managed-kubernetes/operations/applications/gitlab-agent))  

17. Упаковываем helm chart нашего приложения в архив ```helm package ./myapp/chart/``` и заливаем в архив репозиторий.  

18. Добавляем стадию деплоя в [pipeline](https://gitlab.com/sf-devops32/fs-summury/-/blob/main/.gitlab-ci.yml) и необходимые переменные.  
    
19. С помощью запуска [playbook](https://github.com/SergeyErshov/SF-Summory/blob/main/ansible/playbooks/srv-deploy.yml) устанавливаем на srv kubectl и helm, конфигурируем доступ к кластеру.  
   
20. Сохраняем kubeconfig в файл /usr/share/config и даем на него доступ для пользователя gitlab-runner.  

21. Заливаем изменения в репозиторий и добавляем тег. Проверяем, что pipeline запустился, дожидаемся его завершения.  

22. Проверяем, что все стадии pipeline успешно отпработали:  
    ![pipeline_result](https://github.com/SergeyErshov/SF-Summory/blob/main/RAW/2_pipeline_result.png "pipeline_result")  

    Приложение задеплоилось в кластер с новой версией билда:  
    ![pods](https://github.com/SergeyErshov/SF-Summory/blob/main/RAW/3_pods.png "pods")  

    А также доступность нашего прилождения браузере:  
    ![web](https://github.com/SergeyErshov/SF-Summory/blob/main/RAW/4_myapp_web.png "web")

Спринт №2 завершен







