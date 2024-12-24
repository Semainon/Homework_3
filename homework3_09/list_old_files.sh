#!/bin/bash

# Устанавливаем параметры для надежного выполнения скрипта
set -Eeuo pipefail

# Функция-шаблон для очистки при завершении
cleanup() {
    echo "Завершение работы скрипта..."
     # Дополнительные действия, например, удаление временных файлов
     # m -f /tmp/tempfile
}

# Обработка сигналов для корректного завершения
trap cleanup SIGINT SIGTERM ERR EXIT

# Краткое описание функционала
echo "Этот скрипт выводит список файлов в заданной директории, которые старше установленной даты."

# Функция для проверки формата даты
check_date_format() {
    date -d "$1" +%s >/dev/null 2>&1
}

# Запрос даты у пользователя
while true; do
    read -p "Введите дату (например, '2024-12-01'): " USER_DATE
    if [[ ! "$USER_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && [[ ! "$USER_DATE" =~ ^[0-9]{1,2}\s+[а-яА-Я]+\s+[0-9]{4}$ ]]; then
        echo "Ошибка: неверный формат даты. Завершение работы скрипта."
        exit 1
    fi
    if check_date_format "$USER_DATE"; then
        break
    else
        echo "Ошибка: неверный формат даты. Завершение работы скрипта."
        exit 1
    fi
done

# Преобразование даты в Unix-время
UNIX_TIME=$(date -d "$USER_DATE" +%s)

# Запрос директории у пользователя
while true; do
    read -p "Введите путь к директории: " DIRECTORY
    if [ -d "$DIRECTORY" ]; then
        break
    else
        echo "Ошибка: указанная директория не существует. Завершение работы скрипта."
        exit 1
    fi
done

# Поиск файлов, созданных до указанной даты
echo "Список файлов старше $USER_DATE в директории $DIRECTORY:"
for file in "$DIRECTORY"/*; do
    if [ -f "$file" ]; then  # Проверяем, что это файл
        CREATION_TIME=$(stat -c '%W' "$file")  # Получаем время создания файла
        if [ "$CREATION_TIME" -gt 0 ] && [ "$CREATION_TIME" -lt "$UNIX_TIME" ]; then
            echo "$file"
        fi
    fi
done