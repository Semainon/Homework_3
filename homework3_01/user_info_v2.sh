#!/bin/bash

# user_info.sh v.2
# Скрипт выводит информацию о пользователе и применяет изменения по запросу. 

# Запрос имени пользователя
read -p "Введите имя пользователя: " username

# Получение информации о пользователе
user_info=$(getent passwd "$username")

if [ -z "$user_info" ]; then
    echo "Пользователь $username не найден."
    exit 1
fi

# Вывод информации о пользователе
IFS=':' read -r user _ uid gid _ home shell <<< "$user_info"
echo "Информация о пользователе $username (UID: $uid)"
echo "Шелл: $shell"
echo "Домашняя директория: $home"
echo "Группы: $(groups "$username")"

# Запрос на изменение параметров
echo "Что вы хотите изменить? (uid, домашнюю директорию, группу)"
read -p "Введите ваш выбор: " change_option

case $change_option in
    uid)
        while true; do
            read -p "Введите новый UID: " new_uid
            if ! id -u "$new_uid" >/dev/null 2>&1; then
                echo "Итоговая команда: sudo usermod -u $new_uid $username"
                sudo usermod -u "$new_uid" "$username"
                echo "UID пользователя $username изменен на $new_uid."
                break
            else
                echo "UID $new_uid уже занят. Попробуйте другой."
            fi
        done
        ;;
    "домашнюю директорию")
        read -p "Введите новую домашнюю директорию: " new_home
        read -p "Переместить текущую домашнюю директорию? (y/n): " move_home
        if [ "$move_home" == "y" ]; then
            echo "Итоговая команда: sudo usermod -d $new_home -m $username"
            sudo usermod -d "$new_home" -m "$username"
            echo "Домашняя директория пользователя $username изменена на $new_home и перемещена."
        else
            echo "Итоговая команда: sudo usermod -d $new_home $username"
            sudo usermod -d "$new_home" "$username"
            echo "Домашняя директория пользователя $username изменена на $new_home."
        fi
        ;;
    "группу")
        read -p "Введите новую группу: " new_group
        read -p "Меняем ли мы основную группу или дополнительную? (основная/дополнительная): " group_type
        if getent group "$new_group" >/dev/null; then
            if [ "$group_type" == "основная" ]; then
                echo "Итоговая команда: sudo usermod -g $new_group $username"
                sudo usermod -g "$new_group" "$username"
                echo "Основная группа пользователя $username изменена на $new_group."
            elif [ "$group_type" == "дополнительная" ]; then
                echo "Итоговая команда: sudo usermod -aG $new_group $username"
                sudo usermod -aG "$new_group" "$username"
                echo "Пользователь $username добавлен в дополнительную группу $new_group."
            else
                echo "Ошибка: неверный тип группы. Пожалуйста, выберите 'основная' или 'дополнительная'."
            fi
        else
            echo "Ошибка: группа '$new_group' не существует."
        fi
        ;;
    *)
        echo "Неверный выбор. Пожалуйста, выберите uid, домашнюю директорию или группу."
        exit 1
        ;;
esac