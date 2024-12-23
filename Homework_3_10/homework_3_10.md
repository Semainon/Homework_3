### Д3 3.10. Напиcать скрипт, который использует один текстовый файл как источник данных.

### Файл имеет формат:
- userName creationDate deletionDate homeDir
- userName записывается в виде одного слова
- creationDate записывается в формате unix timestamp
- deletionDate записывается в формате unix timestamp, если пользователь не удалён, то используется символ тире
- homeDir - путь к домашней директории пользователя

### Написать функции:
- просмотра информации о пользователе(1), 
- создания пользователя(2), 
- удаления пользователя (3). 

### Используйте case для аргументов скрипта. Аргументы скрипта:
-s имяПользователя  # выводит информацию о пользователе
-c имяПользователя  # добавляет пользователя с указанной в аргументе h домашней директории в файл и текущей датой
-d имяПользователя  # изменяет deletionDate с тире на текущую дату
-h путьКДомашнейДиректории
-a                  # выводит список всех пользователей в формате: Номер строки: имяПользователя датаСоздания датаУдаления путьКДомашнейДиректории

### Терминал 

```bash
# cоздаем в директории скрипта тестовый файл 
[root@Zero scripts]# nano users.txt
[root@Zero scripts]# cat users.txt
zero 1633036800 - /home/zero
petrov 1633123200 1635705600 /home/petrov
ivanov 1633209600 - /home/ivanov
sidorov 1633296000 1635888000 /home/sidorov
noname 1633382400 - /home/noname

[root@Zero scripts]# nano user_managе.sh
[[root@Zero scripts]# chmod +x user_managе.sh


# Тест 1: Вывод информации о пользователе
[root@Zero scripts]# cat users.txt   # выводим содержимое тестового файла users.txt
zero 1633036800 - /home/zero
petrov 1633123200 1635705600 /home/petrov
ivanov 1733182416 1733234988 /home/ivanov
sidorov 1633296000 1635888000 /home/sidorov
noname 1633382400 - /home/noname
new_user 1733182370 - /home/newuser

[root@Zero scripts]# ./user_managе.sh -s zero   #  выводим информацию о пользователе zero
zero 1633036800 - /home/zero
Завершение работы скрипта...


# Тест 2: Добавление нового пользователя с указанной в аргументе h домашней директории в файл и текущей датой
[root@Zero scripts]# ./user_managе.sh -c test_user -h /home/testuser
Пользователь 'test_user' успешно создан.
Завершение работы скрипта...

[root@Zero scripts]# cat users.txt   # пользователь test_user был добавлен с домашней директорией /home/testuser и текущей датой
zero 1633036800 - /home/zero
petrov 1633123200 1635705600 /home/petrov
ivanov 1733182416 1733234988 /home/ivanov
sidorov 1633296000 1635888000 /home/sidorov
noname 1633382400 - /home/noname
new_user 1733182370 - /home/newuser
test_user 1733235817 - /home/testuser


# Тест 3:  Удаление пользователя: в файле deletionDate меняем с тире на текущую дату
[root@Zero scripts]# ./user_managе.sh -d ivanov
Пользователь 'ivanov' успешно удалён.
Завершение работы скрипта...

[root@Zero scripts]# cat users.txt   # запись о польззователе ivanov обновлена, тире заменено на текущую дату
zero 1633036800 - /home/zero
petrov 1633123200 1635705600 /home/petrov
ivanov 1733182416 1733234988 /home/ivanov
sidorov 1633296000 1635888000 /home/sidorov
noname 1633382400 - /home/noname
new_user 1733182370 - /home/newuser


# Тест 4: Вывод списка всех пользователей в формате: Номер строки: имяПользователя датаСоздания датаУдаления путьКДомашнейДиректории
[root@Zero scripts]# ./user_managе.sh -a
1: zero 1633036800 - /home/zero
2: petrov 1633123200 1635705600 /home/petrov
3: ivanov 1733182416 1733234988 /home/ivanov
4: sidorov 1633296000 1635888000 /home/sidorov
5: noname 1633382400 - /home/noname
6: new_user 1733182370 - /home/newuser
7: test_user 1733235817 - /home/testuser
Завершение работы скрипта...
```

### user_managе.sh 

```bash
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
```
