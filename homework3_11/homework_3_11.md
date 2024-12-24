### Д3 3.11. Написать скрипт, на вход которого подается либо PID, либо имя программы.

### Примечание:
- Скрипт постоянно проверяет что программа находится в памяти
- Каждая проверка записывается в лог в формате:
  день-месяц-год час-минута-секунда mySvcChecker: service <имя_сервиса> [isUP|isDown] 
  [isUP|isDown] - состояние сервиса


### Терминал 1

```bash
# Запускаем процесс sleep в фоновом режиме в другом терминал.
[root@Zero ~]# sleep 100 &
[1] 62546 
```


### Терминал 2

```bash
[root@Zero scripts]# nano service_check.sh
[root@Zero scripts]# chmod +x service_check.sh

# тестирование вызова скрипта без параметра  
[root@Zero scripts]# ./service_check.sh
Использование: ./service_check.sh <PID|имя_программы>
Этот скрипт проверяет, работает ли указанный процесс.

# тестирование вызова скрипта с PID 
[root@Zero scripts]# ./service_check.sh 63056 &
[1] 63060 
[root@Zero scripts]#  cat logs/service_check.log
02-12-2024 20-19-18 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-23 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-28 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-33 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-38 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-43 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-48 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-53 mySvcChecker: service 62546 [isUP]
02-12-2024 20-19-58 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-03 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-08 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-13 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-18 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-23 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-28 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-33 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-38 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-43 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-48 mySvcChecker: service 62546 [isUP]
02-12-2024 20-20-53 mySvcChecker: service 62546 [isDown]
02-12-2024 20-20-58 mySvcChecker: service 62546 [isDown]
02-12-2024 20-21-03 mySvcChecker: service 62546 [isDown]
02-12-2024 20-21-08 mySvcChecker: service 62546 [isDown]
02-12-2024 20-21-13 mySvcChecker: service 62546 [isDown]
...

# после тестов прерываем работу service_check.sh 
root@Zero logs]# kill  -9  63060 

root@Zero logs]# ps aux | grep bash
root       62396  0.0  0.3  30988  6292 pts/3    Ss   20:07   0:00 -bash
root       62438  0.0  0.3  30724  6064 pts/2    Ss+  20:08   0:00 -bash
root       64416  0.0  0.0  12212  1212 pts/3    R+   21:28   0:00 grep --color=auto bash
```


### service_check.sh 

```bash
#!/bin/bash

# Устанавливаем параметры для надежного выполнения скрипта
set -Eeuo pipefail

# Функция для вывода справки
usage() {
    echo "Использование: $0 <PID|имя_программы>"
    echo "Этот скрипт проверяет, работает ли указанный процесс."
    exit 1
}

# Проверка на наличие аргумента
if [ "$#" -ne 1 ]; then
    usage
fi

# Получаем аргумент
TARGET="$1"

# Проверка, существует ли процесс с указанным PID или именем
if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
    if ! ps -p "$TARGET" > /dev/null; then
        echo "Ошибка: Процесс с PID $TARGET не существует."
        exit 1
    fi
else
    if ! pgrep -x "$TARGET" > /dev/null; then
        echo "Ошибка: Процесс с именем '$TARGET' не найден."
        exit 1
    fi
fi

# Создаем директорию для логов, если она не существует
LOG_DIR="$(dirname "$0")/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/service_check.log"

# Функция для записи в лог
log_status() {
    local status="$1"
    local service_name="$2"
    local timestamp
    timestamp=$(date +"%d-%m-%Y %H-%M-%S")
    echo "$timestamp mySvcChecker: service $service_name [$status]" >> "$LOG_FILE"
}

# Обработка сигналов для корректного завершения
cleanup() {
    echo "Завершение работы скрипта..."
    exit 0
}

trap cleanup SIGINT SIGTERM ERR EXIT

# Проверка, является ли аргумент PID или именем программы
if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
    # Если это PID
    while true; do
        if ps -p "$TARGET" > /dev/null; then
            log_status "isUP" "$TARGET"
        else
            log_status "isDown" "$TARGET"
        fi
        sleep 5  # Проверка каждые 5 секунд
    done
else
    # Если это имя программы
    while true; do
        if pgrep -x "$TARGET" > /dev/null; then
            log_status "isUP" "$TARGET"
        else
            log_status "isDown" "$TARGET"
        fi
        sleep 5  # Проверка каждые 5 секунд
    done
fi
```
