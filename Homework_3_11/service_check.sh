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