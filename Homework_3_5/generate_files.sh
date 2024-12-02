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
ls -lh *.txt > generated_file_list.txt 

# Вывод времени работы скрипта в формате unixtime
echo "Script execution time: $(date +%s)"

# Удаление lock-файла
# rm "$LOCK_FILE"



