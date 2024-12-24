### Д3 3.13 
- При помощи утилиты nc отправить-принять с одного на другой сервер любое сообщение по TCP и по UDP. 
- При помощи tcpdump посмотреть как устанавливается подключение, сообщение пересылается.
- Поменять mac-address, параллельно посмотреть tcpdump-ом что происходит


### Использование nc (netcat) для локального тестирования  

### 3.13.1 При помощи утилиты nc отправить-принять с одного на другой сервер любое сообщение по TCP и по UDP. 

*Терминал 1*
```bash
# 1) TCP | Запускаем nc в режиме прослушивания на определенном порту (например, 12345):
nc -l -p 12345
Тест TCP

# 2) UDP
nc -u -l -p 12345
nест UDP!
```

*Терминал 2*
```bash
# 1) TCP | В другом терминале на том же сервере отправляем сообщение на прослушиваемый порт:
echo "Тест TCP" | nc localhost 12345

# 2) UDP
echo "Тест UDP!" | nc -u localhost 12345

```

### 3.13.2 ри помощи tcpdump посмотреть как устанавливается подключение, сообщение пересылается.

*Терминал 1*
```bash
[root@Zero ~]# nc -l -p 12345
Тест SemainonP
```

*Терминал 2*
```bash
# Захваченные пакеты: Каждая строка, начинающаяся с временной метки (например, 22:06:39.483018), представляет собой захваченный пакет. Основные компоненты:
# IP-адреса: 127.0.0.1.40246 > 127.0.0.1.italk указывает, что пакет отправляется с локального адреса (localhost) с порта 40246 на порт italk (что соответствует порту 12345).
# Flags: Например, Flags [S] означает, что это SYN-пакет, который используется для инициации TCP-соединения. Flags [S.] означает, что это SYN-ACK, подтверждающий получение SYN.
# seq и ack: Эти значения показывают последовательность и подтверждение пакетов, что важно для управления соединением TCP.
# length: Указывает длину данных в пакете.


sudo tcpdump -i any -n -vv port 12345 
dropped privs to tcpdump
tcpdump: listening on any, link-type LINUX_SLL (Linux cooked v1), capture size 262144 bytes  # tcpdump запущен и слушает на всех интерфейсах (any)

22:06:39.483018 IP (tos 0x0, ttl 64, id 51292, offset 0, flags [DF], proto TCP (6), length 60)
    127.0.0.1.40246 > 127.0.0.1.italk: Flags [S], cksum 0xfe30 (incorrect -> 0x48fa), seq 2457934660, win 65495, options [mss 65495,sackOK,TS val 3438657244 ecr 0,nop,wscale 7], length 0
22:06:39.483035 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
    127.0.0.1.italk > 127.0.0.1.40246: Flags [S.], cksum 0xfe30 (incorrect -> 0xbe89), seq 1829015956, ack 2457934661, win 65483, options [mss 65495,sackOK,TS val 3438657244 ecr 3438657244,nop,wscale 7], length 0
22:06:39.483049 IP (tos 0x0, ttl 64, id 51293, offset 0, flags [DF], proto TCP (6), length 52)
    127.0.0.1.40246 > 127.0.0.1.italk: Flags [.], cksum 0xfe28 (incorrect -> 0xe545), seq 1, ack 1, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0
22:06:39.483096 IP (tos 0x0, ttl 64, id 51294, offset 0, flags [DF], proto TCP (6), length 71)
    127.0.0.1.40246 > 127.0.0.1.italk: Flags [P.], cksum 0xfe3b (incorrect -> 0xd2e3), seq 1:20, ack 1, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 19
22:06:39.483408 IP (tos 0x0, ttl 64, id 9300, offset 0, flags [DF], proto TCP (6), length 52)
    127.0.0.1.italk > 127.0.0.1.40246: Flags [F.], cksum 0xfe28 (incorrect -> 0xe530), seq 1, ack 21, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0
22:06:39.483417 IP (tos 0x0, ttl 64, id 51296, offset 0, flags [DF], proto TCP (6), length 52)
    127.0.0.1.40246 > 127.0.0.1.italk: Flags [.], cksum 0xfe28 (incorrect -> 0xe530), seq 21, ack 2, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0
```

*Терминал 3*
```bash
[root@Zero ~]# echo "Тест SemainonP" | nc -4 localhost 12345
22:06:39.483019 IP 127.0.0.1.40246 > 127.0.0.1.italk: Flags [S], seq 2457934660, win 65495, options [mss 65495,sackOK,TS val 3438657244 ecr 0,nop,wscale 7], length 0
22:06:39.483037 IP 127.0.0.1.italk > 127.0.0.1.40246: Flags [S.], seq 1829015956, ack 2457934661, win 65483, options [mss 65495,sackOK,TS val 3438657244 ecr 3438657244,nop,wscale 7], length 0
22:06:39.483050 IP 127.0.0.1.40246 > 127.0.0.1.italk: Flags [.], ack 1, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0
22:06:39.483096 IP 127.0.0.1.40246 > 127.0.0.1.italk: Flags [P.], seq 1:20, ack 1, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 19
22:06:39.483408 IP 127.0.0.1.italk > 127.0.0.1.40246: Flags [F.], seq 1, ack 21, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0
22:06:39.483417 IP 127.0.0.1.40246 > 127.0.0.1.italk: Flags [.], ack 2, win 512, options [nop,nop,TS val 3438657244 ecr 3438657244], length 0

```

### 3.13.3 Поменять mac-address, параллельно посмотреть tcpdump-ом что происходит
```bash



