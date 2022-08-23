# gate-pars-install
Скрипт установки службы gate_pars.

Данная служба выступает в качестве шлюза запросов в процессинговые центры топливных компаний. Подробнее [здесь](https://github.com/riazmey/gate-pars-modules).

## Минимальные требования:
Операционная система: Ubuntu 20.04

RAM: от 2048 Mb

CPU: от 2 ядер, с частотой от 1Gz

## Установка
```
git clone https://github.com/riazmey/gate-pars-install.git
cd gate-pars-install
./install.sh
```
Этапы установки:
- Обновление системы - опционально (можно отказаться);
- Проверка на наличие и установка, при отсутствии, необходимых пакетов для работы [gate-pars-modules](https://github.com/riazmey/gate-pars-modules);
- Создание/обновление пользователя gate_pars;
- Создание/обновление файла службы - `/etc/systemd/system/gate_pars.service`;
- Настройка конфигурационого файла Веб-сервиса nginx - `/etc/nginx/nginx.conf`;
- Создание/обновление файла сайта Веб-сервиса nginx - `/etc/nginx/sites-available/gate_pars`;
- Добавление в автозапуск Веб-сервиса nginx и его старт;
- Остановка сервиса gate_pars, если он активен;
- Создание дерева каталогов сервиса gate_pars: `/srv/gate_pars/`, `/srv/gate_pars/bin`, `/srv/gate_pars/bin`, `/srv/gate_pars/run`, `/srv/gate_pars/data`, `/srv/gate_pars/opt`;
- Создание файла определения исполняемого файла сервиса gate_pars - `/srv/gate_pars/app.ini`;
- Создание виртальной среды исполнения python (также скачиваются и устанавливаются необходимые пакеты для [gate-pars-modules](https://github.com/riazmey/gate-pars-modules)) - `/srv/gate_pars/env`;
- Установка модулей сервиса [gate-pars-modules](https://github.com/riazmey/gate-pars-modules);
- Старт сервиса gate_pars;
- Установка/обновление браузера Chrome Browser;
- Установка/обновление драйвера Chrome Browser;
