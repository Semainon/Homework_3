#!/bin/bash

# Устанавливаем параметры для надежного выполнения скрипта
set -Eeuo pipefail

# Файл, в котором хранится информация о пользователях
USER_FILE="${USER_FILE:-users.txt}"

# Функция для вывода справки
usage() {
    cat << EOF
Использование: $0 -c имяПользователя -h путьКДомашнейДиректории
               $0 -s имяПользователя
               $0 -d имяПользователя
               $0 -a

Команды:
  -s имяПользователя                Выводит информацию о пользователе.
  -c имяПользователя -h путьКДомашнейДиректории  Создает нового пользователя с указанной домашней директорией.
  -d имяПользователя                Удаляет пользователя, обновляя дату удаления на текущую.
  -a                                Выводит список всех пользователей.

Пример:
  $0 -c new_user -h /home/newuser
  $0 -s existing_user
  $0 -d existing_user
  $0 -a
EOF
}

# Функция для обработки завершения скрипта
cleanup() {
    echo "Завершение работы скрипта..."
    exit 0
}

# Обработка сигналов для корректного завершения
trap cleanup SIGINT SIGTERM ERR EXIT

# Проверка наличия файла пользователей
if [ ! -f "$USER_FILE" ]; then
    touch "$USER_FILE"  # Создаем файл, если он не существует
fi

# Функция для вывода информации о пользователе
view_user() {
    local username="$1"
    if grep -q "^$username " "$USER_FILE"; then
        grep "^$username " "$USER_FILE"
    else
        echo "Пользователь '$username' не найден."
    fi
}

# Функция для создания пользователя
create_user() {
    local username="$1"
    local home_dir="$2"
    local creation_date=$(date +%s)  # Используем Unix timestamp
    echo "$username $creation_date - $home_dir" >> "$USER_FILE"
    echo "Пользователь '$username' успешно создан."
}


# Функция для удаления пользователя
delete_user() {
    local username="$1"
    local current_timestamp=$(date +%s)  # Получаем текущую дату в формате Unix timestamp

    # Проверяем, существует ли пользователь в файле
    if grep -q "^$username " "$USER_FILE"; then
        # Обновляем запись, если дата удаления не является числом
        awk -v user="$username" -v timestamp="$current_timestamp" '
        {
            if ($1 == user && !($3 ~ /^[0-9]+$/)) {
                $3 = timestamp  # Заменяем 3-й элемент на текущую дату
            }
            print $0  # Печатаем строку (обновленную или нет)
        }' "$USER_FILE" > temp_users.txt

        # Перезаписываем файл
        mv temp_users.txt "$USER_FILE"
        echo "Пользователь '$username' успешно удалён."
    else
        echo "Пользователь '$username' не найден."
    fi
}

# Функция для вывода списка всех пользователей
list_users() {
    local line_number=1
    while IFS= read -r line; do
        echo "$line_number: $line"
        ((line_number++))
    done < "$USER_FILE"
}

# Проверка аргументов
if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

# Обработка аргументов
while getopts ":s:c:h:d:a" opt; do
    case "$opt" in
        s)  # Вывод информации о пользователе
            view_user "$OPTARG"
            ;;
        c)  # Создание пользователя
            username="$OPTARG"
            ;;
    h)  # Путь к домашней директории
            home_dir="$OPTARG"
            ;;
    d)  # Удаление пользователя
            delete_user "$OPTARG"
            ;;
    a)  # Вывод списка всех пользователей
            list_users
            ;;
    \?) # Неверная команда
            echo "Ошибка: неверная команда."
            usage
            exit 1
            ;;
    esac
done

# Если указаны флаги -c и -h, создаем пользователя
if [[ -n "${username:-}" && -n "${home_dir:-}" ]]; then
    create_user "$username" "$home_dir"
fi

