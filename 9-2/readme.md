# Домашнее задание к занятию 9.2 «Zabbix. Часть 1»


### Задание 1 

Установите Zabbix Server с веб-интерфейсом.

*Приложите скриншот авторизации в админке.*

![task2 screen1](https://github.com/paive-media/dz9/blob/main/9-2/dz9_2_screen1.png "zabbix login")

*Приложите текст использованных команд в GitHub.*

Делал через `terraform` &mdash; [main.tf](main.tf)

Все взлетело, кроме команд к СУБД, видимо из-за вложенности кавычек.

Потом подключался и донастроил сервер, и агент.

```sh
# Подключение к новым ВМ

-- z-server
ssh -i /Users/ivan/.ssh/id_ed25519 artemiev@51.250.30.233
-- z-agent
ssh -i /Users/ivan/.ssh/id_ed25519 artemiev@51.250.26.207

# Опустошение -> Смена пароля root
sudo nano /etc/passwd
su -
passwd

# Донастройка PgSQL на сервере

sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix 
sudo nano /etc/zabbix/zabbix_server.conf


# Разрешение сервера на Агенте
sudo nano /etc/zabbix/zabbix_agentd.conf
```


---

### Задание 2 

Установите Zabbix Agent на два хоста.

*Приложите скриншот раздела Configuration > Hosts, где видно, что агенты подключены к серверу.*
*Приложите скриншот лога zabbix agent, где видно, что он работает с сервером.*
*Приложите скриншот раздела Monitoring > Latest data для обоих хостов, где видны поступающие от агентов данные.*
*Приложите текст использованных команд в GitHub.*

