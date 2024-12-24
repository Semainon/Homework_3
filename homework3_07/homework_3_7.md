### Д3 3.7. Написать скрипт, который принимает на вход в виде аргумента IP-адрес. 

Скрипт должен проверить доступность адреса посредством ping три раза и записать в лог один раз за все три проверки:
- доступность хоста
- трассировку до хоста
- с какого роутера получен маршрут

### Терминал 

```bash
# Проверем утилиты, которые будем использовать в скрипте 
[root@Zero scripts]# ping -V
[ping utility, iputils-s20180629
[root@Zero scripts]# traceroute -V
Modern traceroute for Linux, version 2.1.0
Copyright (c) 2016  Dmitry Butskoy,   License: GPL v2 or any later
[root@Zero scripts]# nano ping_trace.  
[root@Zero scripts]#  chmod +x ping_trace.sh   
# [root@Zero scripts]#  chmod +t logs  # опционально, устанавливаем Sticky bit на папку logs   
[root@Zero scripts]# ./ping_trace.sh google.com
Хост google.com доступен
Трассировка до google.com:
traceroute to google.com (216.58.207.206), 30 hops max, 60 byte packets
 1  78.140.243.253 (78.140.243.253)  0.957 ms  1.030 ms  1.167 ms
 2  ae14-229.RT.DL.MSK.RU.retn.net (46.46.140.24)  1.127 ms  1.096 ms  1.182 ms
 3  72.14.222.22 (72.14.222.22)  1.035 ms  1.121 ms  1.091 ms
 4  192.178.241.57 (192.178.241.57)  2.649 ms  2.619 ms 192.178.241.243 (192.178.241.243)  1.337 ms
 5  192.178.241.232 (192.178.241.232)  1.578 ms 192.178.243.132 (192.178.243.132)  1.802 ms 192.178.241.146 (192.178.241.146)  1.907 ms
 6  209.85.255.116 (209.85.255.116)  24.236 ms  24.552 ms  49.843 ms
 7  142.250.235.229 (142.250.235.229)  21.639 ms  21.521 ms 72.14.234.106 (72.14.234.106)  20.600 ms
 8  142.251.250.251 (142.251.250.251)  21.307 ms 192.178.73.203 (192.178.73.203)  21.717 ms  21.902 ms
 9  209.85.246.27 (209.85.246.27)  21.938 ms  21.907 ms 209.85.246.57 (209.85.246.57)  22.354 ms
10  arn11s04-in-f14.1e100.net (216.58.207.206)  21.718 ms  21.545 ms  21.510 ms
Маршрут получен от роутера: 216.58.207.206
Логи записаны в /root/scripts/logs/ping_log.txt

# тестируем работу без указанаия IP 
[root@Zero scripts]# ./ping_trace.sh 
Ошибка: не введен IP-адрес.
Использование: ./ping_trace.sh <IP-адрес или имя  домена>.
Скрипт проверяет доступность IP-адреса, выполняет трассировку и записывает результаты в лог.
./ping_trace.sh: строка 22: LOG_FILE: не заданы границы переменной
```

### ping_trace.sh  

```bash
#!/bin/bash

# Устанавливаем параметры для надежного выполнения скрипта
set -Eeuo pipefail

# Обработка сигналов для корректного завершения
trap cleanup SIGINT SIGTERM ERR EXIT

# Определяем директорию скрипта
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Функция для отображения использования скрипта
usage() {
    echo "Использование: $0 <IP-адрес или имя  домена>."
    echo "Скрипт проверяет доступность IP-адреса, выполняет трассировку и записывает результаты в лог."
    exit 1
}

# Добавляем заглушку для очистки ресурсов при завершении 
cleanup() {
    # echo "Скрипт завершен. Очистка ресурсов..."
    echo "Логи записаны в $LOG_FILE"    
    # Здесь можно добавить дополнительные действия по очистке
    # if [ -d "$LOG_DIR" ]; then
    #   rm -rf "$LOG_DIR"
    #   echo "Директория с логами удалена: $LOG_DIR"
    # fi
}

# Проверяем, передан ли IP-адрес в качестве аргумента
if [ $# -ne 1 ]; then
    echo "Ошибка: не введен IP-адрес."
    usage
fi

IP_ADDRESS="$1"
LOG_DIR="$script_dir/logs"
LOG_FILE="$LOG_DIR/ping_log.txt"

# Создаем директорию для логов, если она не существует
mkdir -p "$LOG_DIR"

# Функция для проверки доступности хоста и трассировки
check_host() {
    # Пингуем хост 3 раза
    ping_result=$(ping -c 3 "$IP_ADDRESS" 2>&1)
    ping_status=$?

    # Проверяем, доступен ли хост
    if [ $ping_status -eq 0 ]; then
        echo "Хост $IP_ADDRESS доступен"
        echo "Хост $IP_ADDRESS доступен" >> "$LOG_FILE"
    else
        echo "Хост $IP_ADDRESS недоступен"
        echo "Хост $IP_ADDRESS недоступен" >> "$LOG_FILE"
    fi

    # Выполняем трассировку
    traceroute_result=$(traceroute "$IP_ADDRESS" 2>&1)
    echo "Трассировка до $IP_ADDRESS:"
    echo "$traceroute_result"
    echo "Трассировка до $IP_ADDRESS:" >> "$LOG_FILE"
    echo "$traceroute_result" >> "$LOG_FILE"

    # Определяем роутер из трассировки
    router=$(echo "$traceroute_result" | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
    echo "Маршрут получен от роутера: $router"
    echo "Маршрут получен от роутера: $router" >> "$LOG_FILE"
}

# Вызываем функцию check_host
check_host
```