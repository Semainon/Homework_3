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