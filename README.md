# Локальная очередь Telegram-уведомлений для OpenWrt

Комплект содержит неблокирующий постановщик сообщений, последовательный worker и `procd`-сервис. Очередь переживает перезагрузку, успешность проверяется по коду `curl`, HTTP 200 и `"ok": true`.

## Установка

Скопируйте каталог на роутер и выполните:

```sh
opkg update
opkg install curl ca-bundle
chmod +x install.sh
./install.sh
```

`jsonfilter` используется, если доступен; предусмотрена ограниченная резервная проверка JSON без него.

## Telegram и настройка

1. Создайте бота через `@BotFather`, сохраните выданный token.
2. Напишите боту сообщение. Получите `chat_id` запросом `https://api.telegram.org/bot<TOKEN>/getUpdates` (поле `message.chat.id`). Для группы добавьте бота в группу и отправьте туда сообщение.
3. Отредактируйте `/etc/config/notify` либо задайте значения командами:

```sh
uci set notify.main.token='123456:secret'
uci set notify.main.chat_id='123456789'
uci commit notify
chmod 600 /etc/config/notify
/etc/init.d/notify-worker enable
/etc/init.d/notify-worker restart
```

Token не записывается в журнал. Файл конфигурации должен оставаться с правами `600`.

## Использование и диагностика

```sh
notify "Тестовое сообщение"
notify -l warning "Интернет недоступен"
find /overlay/notify-queue/new -type f
find /overlay/notify-queue/failed -type f
logread -e notify
/etc/init.d/notify-worker status
```

Пользовательский текст ограничен 4096 байт (служебный заголовок файла имеет небольшой отдельный запас). Telegram также учитывает добавляемые hostname, время и уровень; слишком длинный итоговый текст может быть отклонён API и после лимита попыток попадёт в `failed`. По умолчанию очередь ограничена 5000 файлами и 10 MiB. При переполнении удаляется самое старое сообщение уровня `info`; если такого нет, новое сообщение отклоняется. `error` и `critical` автоматически не удаляются.

Очистка (останавливайте worker, чтобы избежать гонки):

```sh
/etc/init.d/notify-worker stop
find /overlay/notify-queue/new -type f -name '*.msg' -delete
find /overlay/notify-queue/failed -type f -name '*.msg' -delete
/etc/init.d/notify-worker start
```

Каталог можно перенести на USB, изменив `notify.main.queue_dir`. Незавершённые файлы остаются в `tmp` и worker их не читает.
