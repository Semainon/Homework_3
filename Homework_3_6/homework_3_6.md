### Д3 3.4. Создайте файл со списком пользователей. С помощью for выведите на экран содержимое файла с нумерацией строк


### Команды 

**`getent passwd | cut -d: -f1 | nl > "$filename"`**: 
- getent passwd: получаем информацию обо всех пользователях из системной БД пользователей;
- cut -d: -f1 | nl > "$filename" - извлекаем их имена и добавляем нумерацию строк, сохраняя результат в файл.

### get_users.sh v.1 | Скрипт cоздает файл list_users.txt с нумерованным списком пользователей или перезаписывает, если он уже существует. С помощью for выводится на экран содержимое файла с нумерацией строк

```bash
#!/bin/bash

# Имя файла для списка пользователей
filename="list_users.txt"

# Получить список пользователей и сохранить в файл
getent passwd | cut -d: -f1 > "$filename"

# Вывод содержимого файла в терминал с нумерацией строк
echo "Список пользователей:"
count=1
for line in $(cat "$filename"); do
  echo "$count. $line"
  ((count++))  # Увеличение счетчика
done
```

### get_users.sh v.2 | Без использованием for (строки нумеруем командой nl)

```bash
#!/bin/bash

# Имя файла для списка пользователей
filename="list_users.txt"

# Получить список пользователей и сохранить в файл с нумерацией
getent passwd | cut -d: -f1 | nl > "$filename"

# Вывод содержимого файла в терминал
echo "Список пользователей:"
cat "$filename"
```

```bash
[root@Zero scripts]# nano get_users.sh
[root@Zero scripts]# chmod +x get_users.sh
[root@Zero scripts]# ls -l
total 16
-rwxr-xr-x. 1 root     root  981 ноя 28 01:33 check_mount.sh
-rwxr-xr-x. 1 root     root  681 ноя 28 00:16 create_file.sh
drwx------. 2 testuser dev    62 ноя 27 13:53 delme
-rwxr-xr-x. 1 root     root  403 ноя 28 18:20 get_users.sh
-rw-r--r--. 1 root     root    0 ноя 28 00:17 testfile
-rwxr-xr-x. 1 root     root 3882 ноя 27 22:46 user_info.sh
[root@Zero scripts]# ./get_users.sh
Список пользователей:
     1  root
     2  bin
     3  daemon
     4  adm
     5  lp
     6  sync
     7  shutdown
     8  halt
     9  mail
    10  operator
    11  games
    12  ftp
    13  nobody
    14  dbus
    15  systemd-coredump
    16  systemd-resolve
    17  tss
    18  polkitd
    19  clevis
    20  unbound
    21  libstoragemgmt
    22  setroubleshoot
    23  cockpit-ws
    24  cockpit-wsinstance
    25  sssd
    26  chrony
    27  sshd
    28  tcpdump
    29  testuser
[root@Zero scripts]# ls -l
total 20
-rwxr-xr-x. 1 root     root  981 ноя 28 01:33 check_mount.sh
-rwxr-xr-x. 1 root     root  681 ноя 28 00:16 create_file.sh
drwx------. 2 testuser dev    62 ноя 27 13:53 delme
-rwxr-xr-x. 1 root     root  403 ноя 28 18:20 get_users.sh
-rw-r--r--. 1 root     root  435 ноя 28 18:28 list_users.txt
-rw-r--r--. 1 root     root    0 ноя 28 00:17 testfile
-rwxr-xr-x. 1 root     root 3882 ноя 27 22:46 user_info.sh

```
