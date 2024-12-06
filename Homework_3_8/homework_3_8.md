### Д3 3.8. Собрать nginx из исходников с модулем. 

Источник: https://github.com/ritchie-wang/nginx-upstream-dynamic-servers

### Примечание:  
- Убедиться в доступности nginx (страничку отдает или нет)
- Положить nginx в созданный namespace ядра
- Убедиться в доступности nginx (страничку отдает или нет)
- Написать конфигурацию reverse-proxy для сайта https://mokm51.ru/ 

### Терминал 

```bash

# Установка необходимых зависимостей 
# gcc: Компилятор для C (компиляция исходного кода Nginx)
# make: Утилита для автоматизации сборки программ. Она управляет процессом компиляции и связывания, используя файлы Makefile, которые описывают, как собирать проек
# pcre-devel: Библиотека для работы с регулярными выражениями, Nginx использует PCRE (Perl Compatible Regular Expressions) для обработки регулярных выражений в конфигурации и для обработки URL

[root@Zero ~]# sudo dnf update -y
[root@Zero ~]# sudo dnf install -y gcc make pcre-devel zlib-devel openssl-devel
[root@Zero ~]# sudo yum update
[root@Zero ~]# sudo yum install git

# Скачивание исходников Nginx и модуля
[root@Zero ~]# cd /usr/local/ 
[root@Zero local]# sudo mkdir nginx
[root@Zero local]# cd nginx
[root@Zero nginx]# wget http://nginx.org/download/nginx-1.25.0.tar.gz
[root@Zero nginx]# tar -xzvf nginx-1.25.0.tar.gz
[root@Zero nginx]# cd nginx-1.25.0

# Скачиваем модуль
[root@Zero local]# sudo mkdir nginx-modules  # cаоздаем отдельную папку для модулей nginx в /usr/local
[root@Zero local]# cd nginx-modules && git clone https://github.com/ritchie-wang/nginx-upstream-dynamic-servers.git

# Конфигурация и сборка Nginx с использованием установленного модуля:
[root@Zero local]# cd /usr/local/nginx/nginx-1.25.0  # переходим в папку с исходниками nginx
[root@Zero nginx-1.25.0]# ./configure --add-module=/usr/local/nginx-modules/nginx-upstream-dynamic-servers
[root@Zero nginx-1.25.0]# make
[root@Zero nginx-1.25.0]# sudo make install

# Проверка доступности Nginx
[root@Zero sbin]# curl -I http://localhost:80
HTTP/1.1 200 OK
Server: nginx/1.25.0
Date: Tue, 03 Dec 2024 18:40:26 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Tue, 03 Dec 2024 17:26:29 GMT
Connection: keep-alive
ETag: "674f3f45-267"
Accept-Ranges: bytes
[root@Zero ~]# sudo /usr/local/nginx/sbin/nginx -s stop # останавливаем  nginx

#  Создание namespace ядра 
[root@Zero nginx-1.25.0]# sudo ip netns add nginx_namespace
[root@Zero nginx-1.25.0]# ip netns list # проверяем, что создан 
nginx_namespace

# Запускаем Nginx в новом namespace
[root@Zero sbin]# ls -l /usr/local/nginx/sbin/nginx  # проверяем, что файл существует 
-rwxr-xr-x. 1 root root 5182120 дек  3 17:26 /usr/local/nginx/sbin/nginx
sudo ip netns exec nginx_namespace /usr/local/nginx/sbin/nginx
# Убедились, что конфигурационный файл Nginx имеет правильные права доступа:
root@Zero sbin]# sudo chown root:root /usr/local/nginx/conf/nginx.conf 
[root@Zero sbin]# sudo chmod 644 /usr/local/nginx/conf/nginx.conf
# редактируем nginx.conf
[root@Zero nginx]# nano /usr/local/nginx/conf/nginx.conf   
[root@Zero sbin]# sudo /usr/local/nginx/sbin/nginx -s reload # обновляем конфигурацию 

[root@Zero sbin]# sudo ip netns exec nginx_namespace /usr/local/nginx/sbin/nginx


# Создаем пару виртуальных интерфейсов (veth0, veth1):
[root@Zero nginx]# sudo ip link add veth0 type veth peer name veth1
# Перемеoftv один из интерфейсов (veth1) в пространство имен nginx_namespace:
[root@Zero nginx]# sudo ip link set veth1 netns nginx_namespace
# Активируем итерфейсы:
[root@Zero nginx]# sudo ip link set veth0 up
[root@Zero nginx]# sudo ip netns exec nginx_namespace ip link set veth1 up

[root@Zero sbin]# ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether ca:0b:f0:53:77:ea brd ff:ff:ff:ff:ff:ff
6: veth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 5e:51:8d:70:17:20 brd ff:ff:ff:ff:ff:ff link-netns nginx_namespace


# Настройка доступа: для доступа к Nginx, запущенному в пространстве имен, нужно настроить маршрутизацию или использовать iptables, для перенаправления трафика на нужный порт (например, 80):

# команда в общем виде: sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination <IP_адрес_вашего_контейнера>:80

sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.100:80 

# Проверка настройки iptables: убедимся, что правило было успешно добавлено:
[root@Zero sbin]# sudo iptables -t nat -L -n -v
Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
   21   884 DNAT       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:192.168.1.100:80

Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination    

# -------------------------------------------------------------------------------
# Здесь были всякие проверки, эксперименты и ошибки при подклчении:  

# Проверка с использованием IP-адреса: 
# [root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://127.0.0.1
# curl: (7) Couldn't connect to server

# С явным указанием порта:
# [root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://localhost:80
# curl: (7) Couldn't connect to server

# Статус интерфейса в пространстве имен:
#  [root@Zero sbin]# sudo ip netns exec nginx_namespace ip addr
# 1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 5: veth1@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
#     link/ether e2:f7:c3:9e:eb:36 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#     inet 192.168.1.100/24 scope global veth1
#        valid_lft forever preferred_lft forever

# Проверка прослушивания портов:
# sudo ip netns exec nginx_namespace netstat -tulpn | grep :80 
#   tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      196637/nginx: maste 

# Проверка маршрутизации:
# sudo ip netns exec nginx_namespace ip route
# [root@Zero sbin]# sudo ip netns exec nginx_namespace ip route
# 192.168.1.0/24 dev veth1 proto kernel scope link src 192.168.1.100


# Вывод: 
# Loopback интерфейс (lo) находится в состоянии DOWN
# Nginx слушает на 0.0.0.0:80, но локальный интерфейс не поднят
# -------------------------------------------------------------------------------

# Исправляем ошибки 
# Поднимаем  loopback интерфейс:
[root@Zero sbin]# sudo ip netns exec nginx_namespace ip link set lo up
# Проверяем статус после поднятия интерфейса:
[root@Zero sbin]# sudo ip netns exec nginx_namespace ip addr show lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
# Делаем запрос через IP-адрес вашего veth интерфейса:      
[root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://192.168.1.100
HTTP/1.1 200 OK
Server: nginx/1.25.0
Date: Thu, 05 Dec 2024 23:03:02 GMT
Content-Type: application/octet-stream
Content-Length: 2
Connection: keep-alive
Content-Type: text/plain

# Все остальные вариаанты тоже теперь работают (скрин, nginx_namespace_1.png): 

[root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://127.0.0.1
HTTP/1.1 200 OK
Server: nginx/1.25.0
Date: Fri, 06 Dec 2024 00:19:31 GMT
Content-Type: application/octet-stream
Content-Length: 2
Connection: keep-alive
Content-Type: text/plain

[root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://localhost
HTTP/1.1 200 OK
Server: nginx/1.25.0
Date: Fri, 06 Dec 2024 00:20:41 GMT
Content-Type: application/octet-stream
Content-Length: 2
Connection: keep-alive
Content-Type: text/plain

[root@Zero sbin]# sudo ip netns exec nginx_namespace curl -I http://localhost:80
HTTP/1.1 200 OK
Server: nginx/1.25.0
Date: Fri, 06 Dec 2024 00:20:51 GMT
Content-Type: application/octet-stream
Content-Length: 2
Connection: keep-alive
Content-Type: text/plain


```

### Команды:
```bash
# запуск  Nginx в пространстве имен, с указанием полного пути к конфигурационному файлу::
sudo ip netns exec nginx_namespace /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf 

# проверка конфигурации на наличие ошибок, рекомендуемтся перед запуском Nginx, если все ок, видим соотв. сообщения:
sudo ip netns exec nginx_namespace /usr/local/nginx/sbin/nginx -t -c /usr/local/nginx/conf/nginx.conf
nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful

# обновление конфигурацию после внесения изменений 
sudo /usr/local/nginx/sbin/nginx -s reload 

# оставновка nginx 
sudo /usr/local/nginx/sbin/nginx -s stop   

# ошибки
sudo ip netns exec nginx_namespace cat /usr/local/nginx/logs/error.log

# проверка, слушает ли Nginx порт 80 в nginx_namespace, и вывод информации о процессе, который использует этот порт.
sudo ip netns exec nginx_namespace netstat -tulpn | grep :80 

# вывод процессов Nginx, работающих в пространстве имен nginx_namespace 
sudo ip netns exec nginx_namespace ps aux | grep nginx 
```
