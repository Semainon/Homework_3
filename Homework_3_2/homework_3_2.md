### Д3 3.2. Написать скрипт, который будет спрашивать название и создавать файл, затем спрашивать права для этого файла и задавать их.

### Команды 

Создаем файл скрипта, делаем его исполняемым и запускаем. 
```bash 
nano create_file.sh
chmod +x create_file.sh
./create_file.sh
```
```bash
[root@Zero scripts]# nano create_file.sh
[root@Zero scripts]# ls -l
total 8
-rw-r--r--. 1 root     root  681 ноя 28 00:16 create_file.sh
drwx------. 2 testuser dev    62 ноя 27 13:53 delme
-rwxr-xr-x. 1 root     root 3882 ноя 27 22:46 user_info.sh
[root@Zero scripts]# chmod +x create_file.sh
[root@Zero scripts]# ./create_file.sh
Введите название файла:
testfile
Введите права доступа (например, 644):
644
Файл 'testfile' создан с правами доступа '644' в директории '/root/scripts'
[root@Zero scripts]# ls -l
total 8
-rwxr-xr-x. 1 root     root  681 ноя 28 00:16 create_file.sh
drwx------. 2 testuser dev    62 ноя 27 13:53 delme
-rw-r--r--. 1 root     root    0 ноя 28 00:17 testfile
-rwxr-xr-x. 1 root     root 3882 ноя 27 22:46 user_info.sh
```

### user_info.sh v.2 | Скрипт создает в текущей директории файл с требуемыми правами. 

```bash
#!/bin/bash

# Запрашиваем название файла у пользователя
echo "Введите название файла:"
read filename

# Создаем файл
touch "$filename"

# Запрашиваем права доступа у пользователя
echo "Введите права доступа (например, 644):"
read permissions

# Устанавливаем права доступа на файл
chmod "$permissions" "$filename"

# Получаем текущую директорию
current_dir=$(pwd)

echo "Файл '$filename' создан с правами доступа '$permissions' в директории '$current_dir'"
```