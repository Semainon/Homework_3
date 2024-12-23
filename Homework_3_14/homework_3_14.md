### Д3 3.14. Переводим SELinux в Permissive режим.Пишем скрипт, который слушает 60 порт tcp ( неважно чем - хоть nc ), При подключении клиента к 60 порту ( telnet / nc ), скрипт выдает приветствие.

### Если скрипт на 60 порту получил сообщение от клиента:
- *getDate*, то должен выдать текущую дату в формате ГОД-МЕСЯЦ-ДЕНЬ ЧАС-МИНУТА-СЕКУНДА 
- *getEpoch*,
- *getInetStats*,
- *getInetStats <имяКарты>*,
- *bye*,

В ходе работы должен вестись лог в формате:
ГОД-МЕСЯЦ-ДЕНЬ ЧАС-МИНУТА-СЕКУНДА ПИД локальныйИП удаленныйИП командаОтКлиента результатВыполнения



### Терминал 1

```bash
[root@Zero scripts]# nano tcp_server.sh
[root@Zero scripts]# nano tcp_server.sh
[root@Zero scripts]# chmod +x tcp_server.sh
[root@Zero scripts]# sudo ./tcp_server.sh
Скрипт TCP-сервера

Этот скрипт слушает на порту 60 и обрабатывает следующие команды:

- getDate: выводит текущую дату в формате ГОД-МЕСЯЦ-ДЕНЬ ЧАС-МИНУТА-СЕКУНДА
- getEpoch: выводит текущее время в формате unixtime
- getInetStats: выводит статистику всех сетевых интерфейсов
- getInetStats <имяКарты>: выводит статистику указанного сетевого интерфейса
- bye: завершает сессию

Логи команд записываются в файл server_log.txt.
Сервер запущен на порту 60...
Добро пожаловать на сервер! Введите команду:
Неизвестная команда   # ввод неверной команды 
2024-12-10 10-36-49   # getDate
1733827017            # getEpoch
enp0s5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500   # getInetStats
        inet 78.140.243.19  netmask 255.255.255.0  broadcast 78.140.243.255
        ether ca:0b:f0:53:77:ea  txqueuelen 1000  (Ethernet)
        RX packets 15147170  bytes 941812340 (898.1 MiB)
        RX errors 0  dropped 190  overruns 0  frame 0
        TX packets 153794  bytes 187401178 (178.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 1216583  bytes 60830399 (58.0 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1216583  bytes 60830399 (58.0 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
enp0s5: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500  # getInetStats enp0s5
        inet 78.140.243.19  netmask 255.255.255.0  broadcast 78.140.243.255
        ether ca:0b:f0:53:77:ea  txqueuelen 1000  (Ethernet)
        RX packets 15148990  bytes 941914940 (898.2 MiB)
        RX errors 0  dropped 190  overruns 0  frame 0
        TX packets 153802  bytes 187402682 (178.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
Завершение сессии.  # bye

```


### Терминал 2

```bash
# временно переводим SELinux в Permissive режим

[root@Zero ~]# sudo setenforce 0  
[root@Zero ~]# sestatus  
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      31


[root@Zero ~]# nc 127.0.0.1 60
getDat  # тестируем ввод неверной команды
getDate
getEpoch
getInetStats
getInetStats enp0s5
bye
```

