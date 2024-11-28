### Д3 3.3. Написать скрипт, который должен принять на вход путь до блочного устройства, проверить примонтировано оно или нет.

**Дополнительно:**

-  Если примонтировано - завершиться с exitCode 90,
-  Если не примонтировано, то при помощи программы mktemp создать директорию, примонтировать в неё.


### Команды 

- Просмотр информации о разделах: fdisk -l выводит список всех подключенных дисков и их разделов.
```bash 
[root@Zero scripts]# fdisk -l
Disk /dev/vda: 25 GiB, 26843545600 bytes, 52428800 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: B224EFA6-B833-4A14-8B26-47B2D17C0630
Device      Start      End  Sectors Size Type
/dev/vda1    2048   104447   102400  50M EFI System
/dev/vda2  104448 52428766 52324319  25G Linux filesystem
```
- Создаем файл скрипта, делаем его исполняемым и запускаем.
```bash
[root@Zero scripts]# nano check_mount.sh
[root@Zero scripts]# ./check_mount.sh
[root@Zero scripts]# chmod +x check_mount.sh
[root@Zero scripts]# ./check_mount.sh
Введите путь до блочного устройства:
/dev/vda2
Устройство /dev/vda2 уже примонтировано. ExitCode: 90
```

### check_mount.sh | Скрипт принимает на вход путь до блочного устройства, проверяет примонтировано оно или нет.
```bash
#!/bin/bash

# Получаем путь до блочного устройства от пользователя
echo "Введите путь до блочного устройства:"
read block_device

# Проверяем, что устройство существует
if ! stat "$block_device" &> /dev/null; then
    echo "Устройство $block_device не существует."
    exit 1
fi

# Проверяем, примонтировано ли устройство
if mount | grep -q "$block_device"; then
    echo "Устройство $block_device уже примонтировано. ExitCode: 90"
    exit 90
fi

# Создаем временную директорию для монтирования при помощи mktemp
mount_dir=$(mktemp -d)

# Монтируем устройство в созданную директорию
mount "$block_device" "$mount_dir"

echo "Устройство $block_device примонтировано в $mount_dir. ExitCode: 0"
exit 0




```