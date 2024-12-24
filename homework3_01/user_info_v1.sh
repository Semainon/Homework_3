#!/bin/bash

# user_info.sh v.1
# Скрипт только выводит информацию о пользователе, прменение ихменений реализовано в user_info.sh v.2 (см. файл user_info_v2.sh)


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
echo "Информация о пользователе $username:"
echo "UID: $uid"
echo "Группа: $gid"
echo "Домашняя директория: $home"
echo "Шелл: $shell"

# Вывод списка групп
groups=$(groups "$username")
echo "Группы: $groups"

# Запрос на изменение параметров
echo "Что вы хотите изменить? (uid, домашнюю директорию, группу)"
read -p "Введите ваш выбор: " change_option

case $change_option in
    uid)
        while true; do
            read -p "Введите новый UID: " new_uid
            if ! id -u "$new_uid" >/dev/null 2>&1; then
                break
            else
                echo "UID $new_uid уже занят. Попробуйте другой."
            fi
        done
        echo "Итоговая команда: usermod -u $new_uid $username"
        ;;
    домашнюю директорию)
        read -p "Введите новую домашнюю директорию: " new_home
        read -p "Переместить текущую домашнюю директорию? (y/n): " move_home
        if [ "$move_home" == "y" ]; then
            echo "Итоговая команда: usermod -d $new_home -m $username"
        else
            echo "Итоговая команда: usermod -d $new_home $username"
        fi
        ;;
    группу)
        read -p "Введите новую группу: " new_group
        read -p "Меняем основную группу? (y/n): " change_primary
        if [ "$change_primary" == "y" ]; then
            echo "Итоговая команда для изменения основной группы юзера: usermod -g $new_group $username"
        else
            echo "Итоговая команда для добавления пользователя в дополнительнуж группу: usermod -aG $new_group $username"
        fi
        ;;
    *)
        echo "Неверный выбор."
        ;;
esac