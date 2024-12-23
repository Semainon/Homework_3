#!/bin/bash

# Функция для логирования
log_command() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$timestamp $1 $2 $3 $4 $5" >> server_log.txt
}

# Функция для вывода информации о скрипте
print_help() {
    cat << EOF
Скрипт TCP-сервера

Этот скрипт слушает на порту 60 и обрабатывает следующие команды:

- getDate: выводит текущую дату в формате ГОД-МЕСЯЦ-ДЕНЬ ЧАС-МИНУТА-СЕКУНДА
- getEpoch: выводит текущее время в формате unixtime
- getInetStats: выводит статистику всех сетевых интерфейсов
- getInetStats <имяКарты>: выводит статистику указанного сетевого интерфейса
- bye: завершает сессию

Логи команд записываются в файл server_log.txt.
EOF
}

# Основной код сервера
print_help  # Выводим информацию о скрипте

while true; do
    {
        echo "Сервер запущен на порту 60..."
        nc -l -p 60 | while read line; do
            local_ip=$(hostname -I | awk '{print $1}')
            remote_ip=$(echo $REPLY | awk '{print $1}')
            pid=$$

            # Приветствие клиенту
            echo "Добро пожаловать на сервер! Введите команду:" | nc -N $remote_ip 60

            case "$line" in
                "bye")a
                    echo "Завершение сессии."
                    log_command $pid $local_ip $remote_ip "bye" "Сессия завершена"
                    break
                    ;;
                "getDate")
                    result=$(date +"%Y-%m-%d %H-%M-%S")
                    ;;
                "getEpoch")
                    result=$(date +%s)
                    ;;
                "getInetStats")
                    result=$(ifconfig 2>/dev/null)
                    if [ $? -ne 0 ]; then
                        result="Ошибка при получении статистики интерфейсов."
                    fi
                    ;;
                "getInetStats "*)
                    interface=${line#getInetStats }
                    result=$(ifconfig "$interface" 2>/dev/null || echo "Интерфейс '$interface' не найден.")
                    ;;
                *)
                    result="Неизвестная команда"
                    ;;
            esac

            echo "$result"
            log_command $pid $local_ip $remote_ip "$line" "$result"
        done
    }
done