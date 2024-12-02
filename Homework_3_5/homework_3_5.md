### Д3 3.5. При помощи HEREDOC "сгенерировать" баш-скрипт, который на вход принимает три аргумента:
- вывод usage ( как пользоваться скриптом )
- количество генерируемых файлов
- маску имени генерируемых файлов

### Функционал скрипта:
1. Проверяет существование файла с именем скрипта и расширением lock:
  - если файл существует, вывести содержимое файла и завершить работу с кодом 64;
  - если файла не существует, то записать в него pid скрипта.
2. Переходит в домашнюю директорию пользователя root;
3. Создает именованный пайп;
4. Создает файлы различного размера ( от 10 КБ до 800 КБ ) по маске имени, количество берется из аргумента "количество генерируемых файлов";
5. Переходит в директорию /tmp;
6. Архивирует созданные файлы при помощи созданного именованного пайпа;
7. Выводит список файлов ( без директорий ) одновременно и на экран, и в файл;
8. Выводит на экран время всей работы скрипта в формате unixtime.


### Терминал

```bash
#[root@Zero scripts]# sudo ./generate_files.sh
Нужна справка? (y/n): y
Этот скрипт генерирует заданное количество текстовых файлов с указанной маской имен.

Программа создаст файлы в домашней директории пользователя root.

Аргументы:
- <количество_генерируемых_файлов>: Количество файлов, которые нужно создать (должно быть положительным целым числом).
- <маска_имени_файлов>: Маска для имен создаваемых файлов (например, "gen_file_%d.txt").
Введите количество генерируемых файлов: 7
Введите маску имени генерируемых файлов (например, gen_file_%d.txt): gen7_file_%d.txt       
Создан именованный пайп: my_fifo
Создание файла: gen7_file_1.txt размером 349K
Создан файл: gen7_file_1.txt
Создание файла: gen7_file_2.txt размером 306K
Создан файл: gen7_file_2.txt
Создание файла: gen7_file_3.txt размером 136K
Создан файл: gen7_file_3.txt
Создание файла: gen7_file_4.txt размером 680K
Создан файл: gen7_file_4.txt
Создание файла: gen7_file_5.txt размером 128K
Создан файл: gen7_file_5.txt
Создание файла: gen7_file_6.txt размером 14K
Создан файл: gen7_file_6.txt
Создание файла: gen7_file_7.txt размером 279K
Создан файл: gen7_file_7.txt
Архивирование завершено.
-rw-r--r--. 1 root root 349K ноя 29 13:17 gen7_file_1.txt
-rw-r--r--. 1 root root 306K ноя 29 13:17 gen7_file_2.txt
-rw-r--r--. 1 root root 136K ноя 29 13:17 gen7_file_3.txt
-rw-r--r--. 1 root root 680K ноя 29 13:17 gen7_file_4.txt
-rw-r--r--. 1 root root 128K ноя 29 13:17 gen7_file_5.txt
-rw-r--r--. 1 root root  14K ноя 29 13:17 gen7_file_6.txt
-rw-r--r--. 1 root root 279K ноя 29 13:17 gen7_file_7.txt
-rw-r--r--. 1 root root    0 ноя 29 13:17 generated_file_list.txt
Script execution time: 1732886279
[root@Zero scripts]# ls -l
total 24
-rwxr-xr-x. 1 root     root  981 ноя 28 01:33 check_mount.sh
-rwxr-xr-x. 1 root     root  681 ноя 28 00:16 create_file.sh
drwx------. 2 testuser dev    62 ноя 27 13:53 delme
-rwxr-xr-x. 1 root     root 3365 ноя 29 13:15 generate_files.sh
-rwxr-xr-x. 1 root     root  519 ноя 28 18:43 get_users.sh
-rw-r--r--. 1 root     root  232 ноя 28 18:47 list_users.txt
-rw-r--r--. 1 root     root    0 ноя 28 00:17 testfile
-rwxr-xr-x. 1 root     root 3882 ноя 27 22:46 user_info.sh
[root@Zero scripts]# cd /root && ls
my_fifo  scripts
[root@Zero ~]# cd /tmp && ls
gen7_file_1.txt  gen7_file_3.txt  gen7_file_5.txt  gen7_file_7.txt          generated_files_20241129_131759.tar.gz
gen7_file_2.txt  gen7_file_4.txt  gen7_file_6.txt  generated_file_list.txt

# тест при повторном вызове скрипта (файл с именем скрипта и расширением lock существует)
root@Zero scripts]# ./generate_files.sh
Нужна справка? (y/n): 
Введите количество генерируемых файлов: 3
Введите маску имени генерируемых файлов (например, gen_file_%d.txt): test_file_%d.txt
Содержимое lock-файла:
9472    
```

### generate_files.sh

```bash
#!/bin/bash

# Функция для вывода информации о использовании скрипта
show_help() {
    cat << EOF
Этот скрипт сгенерирует заданное количество файлов различного размера (от 10 КБ до 800 КБ) с указанной маской имен и архивирует их.

Программа создаст файлы в домашней директории пользователя root.

Аргументы:
- <количество_генерируемых_файлов>: Количество файлов, которые нужно создать (должно быть положительным целым числом).
- <маска_имени_файлов>: Маска для имен создаваемых файлов (например, "gen_file_%d.txt").
EOF
}

# Запрос справки у пользователя
read -p "Нужна справка? (y/n): " need_help
if [[ "$need_help" == "y" ]]; then
    show_help
fi

# Запрос количества генерируемых файлов
read -p "Введите количество генерируемых файлов: " NUM_FILES
if ! [[ "$NUM_FILES" =~ ^[0-9]+$ ]] || [ "$NUM_FILES" -le 0 ]; then
    echo "Ошибка: количество файлов должно быть положительным целым числом."
    exit 1
fi

# Запрос маски имени генерируемых файлов
read -p "Введите маску имени генерируемых файлов (например, gen_file_%d.txt): " FILENAME_MASK

# Имя lock-файла
LOCK_FILE="/tmp/$(basename "$0").lock"

# Проверка существования lock-файла
if [ -e "$LOCK_FILE" ]; then
    echo "Содержимое lock-файла:"
    cat "$LOCK_FILE"
    exit 64
else
    echo $$ > "$LOCK_FILE"  # Запись PID в lock-файл
fi

# Переход в домашнюю директорию пользователя root
cd /root || exit

# Создание именованного пайпа
FIFO_NAME="file_archive_pipe"
mkfifo "$FIFO_NAME"
echo "Создан именованный пайп: $FIFO_NAME"

# Переход в директорию /tmp
cd /tmp || exit

# Генерация файлов размером от 10 КБ до 800 КБ
for ((i=1; i<=NUM_FILES; i++)); do
    FILE_SIZE=$((RANDOM % 790 + 10))  # Размер от 10 до 800 КБ
    FILE_NAME=$(printf "$FILENAME_MASK" "$i")
    echo "Создание файла: $FILE_NAME размером ${FILE_SIZE}K"
    dd if=/dev/zero of="$FILE_NAME" bs=1K count="$FILE_SIZE" status=none
    echo "Создан файл: $FILE_NAME"
done

# Архивирование созданных файлов с использованием именованного пайпа
(
    ls *.txt > "$FIFO_NAME" &
    tar -czf "generated_files_$(date +%Y%m%d_%H%M%S).tar.gz" -T "$FIFO_NAME"
)

# Удаление именованного пайпа
rm "$FIFO_NAME"
echo "Архивирование завершено."

# Вывод списка файлов (без директорий) одновременно на экран и в файл
# ls -lh *.txt | tee generated_file_list.txt  
ls -lh *.txt > generated_file_list.txt 

# Вывод времени работы скрипта в формате unixtime
echo "Script execution time: $(date +%s)"

# Удаление lock-файла
# rm "$LOCK_FILE"
```


