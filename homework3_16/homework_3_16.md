### Д3 3.16. firewalld

### Нарисовать правило сервиса с указанным портом (см. ниже) для публичной зоны в виде файла, который необходимо положить в то место, из которого firewalld читает правила.
- На машине 1 запустить nc на любом порту в режиме прослушивания. На этой машине должно быть правило из пункта выше
- На машине 2 запустить nc с подключением к машине 1
- Изменить правило сервиса так, что бы подключение с машины 2 к машине 1 отбрасывалось iptables
- Написать правила для доступа к порту 22/tcp только для выделенного списка адресов, всем остальным адресам доступ запрещен


### Терминал

```bash
# Создаем  файл правила сервиса в /etc/firewalld/services/:
[root@Zero ~]# cd /etc/firewalld/services 
[root@Zero services]# sudo nano nc_service.xml
# Проверяем статус firewalld:
root@Zero services]# sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

[root@Zero services]# sudo systemctl start firewalld
[root@Zero services]# sudo systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: active (running) since Mon 2024-12-23 17:58:12 UTC; 29s ago
     Docs: man:firewalld(1)
 Main PID: 355555 (firewalld)
    Tasks: 2 (limit: 12292)
   Memory: 37.1M
   CGroup: /system.slice/firewalld.service
           └─355555 /usr/libexec/platform-python -s /usr/sbin/firewalld --nofork --nopid

дек 23 17:58:12 Zero.local systemd[1]: Starting firewalld - dynamic firewall daemon...
дек 23 17:58:12 Zero.local systemd[1]: Started firewalld - dynamic firewall daemon.
дек 23 17:58:12 Zero.local firewalld[355555]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will b>
# Перезагружаем firewalld
[root@Zero services]# sudo firewall-cmd --reload 
success
# Добавим новый сервис в публичную зону и перезагружаем конфигурацию 
[root@Zero services]# sudo firewall-cmd --zone=public --add-service=nc_service --permanent
success
[root@Zero services]# sudo firewall-cmd --reload
success
#  Добавляем новый порт в SELinux и проверяем, что порт добавлен:
[root@Zero services]# sudo semanage port -a -t http_port_t -p tcp 8888
[root@Zero services]# sudo semanage port -l | grep 8888
http_port_t                    tcp      8888, 4589, 80, 81, 443, 488, 8008, 8009, 8443, 9000

#  На сервере (машина 1)  запускаем nc на  порту 8888 в режиме прослушивания
[root@Zero services]# nc -l 8888  
Привет, машина 1   # получаем сообщение при выполнении в терммнале на локальном компьютера (машина 2) echo "Привет, машина 1" | nc 78.140.243.19 8888

# Изменение правила сервиса для блокировки соединений c машины 2: будут отбрасываться все входящие соединения на порт 8888
[root@Zero services]# sudo iptables -A INPUT -s **.***.***.** -p tcp --dport 8888 -j DROP  # где **.***.***.** ip локального компьютера
# при выполнении в термиинале на локальном компьютера (машина 2) echo "Привет, машина 1" | nc 78.140.243.19 8888  сообщение не передается 

# Настройка доступа к порту 22/tcp для выделенного списка адресов
[root@Zero services]# sudo iptables -A INPUT -p tcp --dport 22 -s 88.201.181.0/24 -j ACCEPT 
# Блокируем все остальные подключения к порту 22: 
[root@Zero services]# sudo iptables -A INPUT -p tcp --dport 22 -j DROP
# Смотрим, что новые правила отобразилсь в таблице  
[root@Zero services]# sudo iptables -L -n -v
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 DROP       tcp  --  *      *       192.168.1.100        0.0.0.0/0            tcp dpt:8888
   13   784 DROP       tcp  --  *      *       **.***.***.**        0.0.0.0/0            tcp dpt:8888
   10   736 ACCEPT     tcp  --  *      *       88.201.181.0/24      0.0.0.0/0            tcp dpt:22
    3   180 DROP       tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination  
```
