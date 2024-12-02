#!/bin/bash

# Функция для вывода помощи
show_help() {
    cat << EOF
Использование: $0 [процент]

Этот скрипт проверяет свободное место на примонтированных разделах дисков.
Если свободного места осталось менее указанного процента, отправляет сообщение в Telegram.

Аргументы:
  процент   Минимальный процент свободного пространства для отправки уведомления.
EOF
}

# Запрос справки у пользователя
read -p "Нужна справка? (y/n): " need_help
if [[ "$need_help" == "y" ]]; then
    show_help
fi


# Запрос ввода процента
read -p "Введите минимальный процент свободного пространства (например, 10): " THRESHOLD

# Проверка, является ли аргумент числом
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: аргумент должен быть целым числом."
    exit 1
fi

# Получение информации о свободном месте на дисках
df -h --output=source,pcent | grep -vE '^Filesystem|tmpfs|cdrom' | while read -r line; do
    PARTITION=$(echo $line | awk '{print $1}')
    USAGE=$(echo $line | awk '{print $2}' | sed 's/%//')

    # Вычисление свободного места
    FREE_SPACE=$((100 - USAGE))

    # Проверка, если свободное место меньше порога
    if [ "$FREE_SPACE" -lt "$THRESHOLD" ]; then
        MESSAGE="Внимание! На разделе $PARTITION осталось менее $THRESHOLD% свободного места."
        
        # Отправка сообщения в Telegram
        curl -s -X POST "https://api.telegram.org/bot*******************/sendMessage" \
        -d "chat_id=***********" \
        -d "text=$MESSAGE"

        echo "Свободное место на диске $PARTITION - меньше $THRESHOLD%. Сообщение отправлено в Telegram."
    else
        echo "Свободное место на диске $PARTITION - больше $THRESHOLD%. Сообщение в Telegram не отправлено."
    fi
done 