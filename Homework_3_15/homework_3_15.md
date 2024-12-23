### Д3 3.15.Берём ранее сконфигурированный nginx
- Включаем SELinux в режим Enforcing
- Создаем директорию /pubHtml
- В конфиге web-сервера сменить root-директорию с дефолтной на /pubHtml
- Кладём любой файл в /pubHtml. В качестве примера можно использовать файл index.html с содержимым <html><body><h2>test file
- При помощи утилит audit2allow и setroubleshoot разрешаем работу httpd-демона с /pubHtml
- При обращении к виртуальной машине по IP-адресу на 80/tcp-порт получаем свой файл из директории /pubHtml от web-сервера
- Добавляем в конфигурацию веб-сервера порт 4589
- При обращении к виртуальной машине по IP-адресу на 4589/tcp-порт получаем свой файл из директории /pubHtml от web-сервера
- Разрешаем работу скрипта при помощи утилит audit2allow и setroubleshoot


### Терминал

```bash
[root@Zero ~]# sudo setenforce 1   # Включаем SELinux в режим Enforcing
[root@Zero ~]# sestatus            # Получаем информацию о статусе SELinux 
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing  # нужный режим включен
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      31

# Cоздаем в корне директорию /pubHtml, для реальных задач лучше это делать в /var/www/   
[root@Zero ~]# sudo mkdir /pubHtml 
sudo chmod 755 /pubHtml 
[root@Zero /]# sudo chown nginx:nginx /pubHtml

# Изменяет контекст безопасности (SELinux context) для всех файлов и подкаталогов в директории /pubHtml.  
# Флаг -R указывает на рекурсивное применение, а -t httpd_sys_content_t задает тип контекста, который позволяет Nginx читать содержимое этой директории.
[root@Zero /]# sudo chcon -R -t httpd_sys_content_t /pubHtml

# Добавляем правило для SELinux: все файлы и подкаталоги, созданные в /pubHtml автоматически должны иметь тип контекста httpd_sys_content_t
[root@Zero /]# sudo semanage fcontext -a -t httpd_sys_content_t "/pubHtml(/.*)?"

# Восстанавливаем контекст безопасности для всех файлов и подкаталогов в директории /pubHtml в соответствии с правилами, определенными в базе данных SELinux (для применения изменений, сделанных с помощью semanage fcontext).
[root@Zero /]# sudo restorecon -R /pubHtml

# Создаем файл index.html директории /pubHtml
[root@Zero /]# echo "<html><body><h2>test file</h2></body></html>" | sudo tee /pubHtml/index.html
<html><body><h2>test file</h2></body></html>

# SELinux также блокирует нестандартные порты. Разрешаем порт 4589 для Nginx
[root@Zero ~]# sudo semanage port -a -t http_port_t -p tcp 4589

[root@Zero ~]# sudo semanage port -l | grep 4589
http_port_t                    tcp      4589, 80, 81, 443, 488, 8008, 8009, 8443, 9000


# Редактируем файл nginx.conf, затем запускаем nginx 
[root@Zero ~]# nano /usr/local/nginx/conf/nginx.conf 
[root@Zero ~]# sudo /usr/local/nginx/sbin/nginx


# Удостоевримся, что SELinux в данный момент не блокирует доступ к директории /pubHtml, и нет записей о нарушениях.

# Ищем записи о нарушениях SELinux (AVC) в журнале аудита за последнее время
# Вывод <no matches> указывает на то,  SELinux не блокирует доступ к ресурсам или что нет активных записей
[root@Zero pubHtml]# sudo ausearch -m avc -ts recent
<no matches>  

# Проверяет статус службы auditd, которая отвечает за ведение журнала аудита.
# Статус active (running) указывает на то, что служба работает корректно и ведет запись событий.
[root@Zero pubHtml]# sudo systemctl status auditd
● auditd.service - Security Auditing Service
   Loaded: loaded (/usr/lib/systemd/system/auditd.service; enabled; vendor preset: enabled)
   Active: active (running) since Sun 2024-12-08 23:32:30 UTC; 2 weeks 0 days ago  
     Docs: man:auditd(8)
           https://github.com/linux-audit/audit-documentation
  Process: 618 ExecStartPost=/sbin/augenrules --load (code=exited, status=0/SUCCESS)
  Process: 612 ExecStart=/sbin/auditd (code=exited, status=0/SUCCESS)
 Main PID: 613 (auditd)
    Tasks: 4 (limit: 12292)
   Memory: 38.7M
   CGroup: /system.slice/auditd.service
           ├─613 /sbin/auditd
           └─615 /usr/sbin/sedispatch

дек 20 10:37:22 Zero.local auditd[613]: Audit daemon rotating log files
дек 20 22:07:32 Zero.local auditd[613]: Audit daemon rotating log files
дек 21 06:00:23 Zero.local auditd[613]: Audit daemon rotating log files
дек 21 13:53:29 Zero.local auditd[613]: Audit daemon rotating log files
дек 21 19:15:24 Zero.local auditd[613]: Audit daemon rotating log files
дек 22 05:17:05 Zero.local auditd[613]: Audit daemon rotating log files
дек 22 16:09:41 Zero.local auditd[613]: Audit daemon rotating log files
дек 23 02:39:45 Zero.local auditd[613]: Audit daemon rotating log files
дек 23 06:46:40 Zero.local auditd[613]: Audit daemon rotating log files
дек 23 10:21:28 Zero.local auditd[613]: Audit daemon rotating log files


# Проверяем статус службы setroubleshootd, которая обрабатывает новые журналы отказов SELinux. 
# Статус active (running) показывает, что служба успешно запущена и готова к работе.

[root@Zero pubHtml]# sudo systemctl status setroubleshootd
● setroubleshootd.service - SETroubleshoot daemon for processing new SELinux denial logs
   Loaded: loaded (/usr/lib/systemd/system/setroubleshootd.service; static; vendor preset: disabled)
   Active: active (running) since Mon 2024-12-23 10:52:13 UTC; 9s ago
 Main PID: 344677 (setroubleshootd)
    Tasks: 2 (limit: 12292)
   Memory: 111.9M
   CGroup: /system.slice/setroubleshootd.service
           └─344677 /usr/libexec/platform-python -Es /usr/sbin/setroubleshootd -f

дек 23 10:52:12 Zero.local systemd[1]: Starting SETroubleshoot daemon for processing new SELinux denial >
дек 23 10:52:13 Zero.local systemd[1]: Started SETroubleshoot daemon for processing new SELinux denial l> 
# ... 

# Команда анализирует журнал аудита SELinux с помощью утилиты sealert. 
# Вывод found 0 alerts указывает на то, что в журнале нет записей о нарушениях
[root@Zero pubHtml]# sudo sealert -a /var/log/audit/audit.log
100% done
found 0 alerts in /var/log/audit/audit.log 

# Cервер корректно отдает содержимое страницы по указанному ip на 80 и 4589 порту 
[root@Zero ~]# curl http://78.140.243.19:80/index.html
<html><body><h2>test file</h2></body></html>
[root@Zero ~]# curl http://78.140.243.19:4589/index.html
<html><body><h2>test file</h2></body></html>
```
