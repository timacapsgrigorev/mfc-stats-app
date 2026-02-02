#!/bin/bash

# Простой инсталляционный скрипт для RED OS 7.3

echo "========================================"
echo "Установка MFC Stats App на RED OS 7.3"
echo "========================================"

# Установка системных пакетов
echo "1. Установка системных зависимостей..."
yum install -y python3 python3-tkinter

# Установка pip
echo "2. Установка pip..."
curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Установка Python библиотек
echo "3. Установка Python библиотек..."
pip3 install pandas openpyxl chardet

# Создание директории приложения
echo "4. Создание директории приложения..."
APP_DIR="/opt/mfc-stats-app"
mkdir -p $APP_DIR
cp -r src/* $APP_DIR/

# Создание скрипта запуска
echo "5. Создание скрипта запуска..."
cat > /usr/local/bin/mfc-stats-app << EOF
#!/bin/bash
cd $APP_DIR
python3 mfc_stats_app.py
EOF

chmod +x /usr/local/bin/mfc-stats-app

# Создание ярлыка на рабочем столе (опционально)
echo "6. Создание ярлыка на рабочем столе..."
DESKTOP_FILE="$HOME/Desktop/mfc-stats-app.desktop"
cat > $DESKTOP_FILE << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MFC Stats App
Comment=Анализ статистики филиалов МФЦ
Exec=/usr/local/bin/mfc-stats-app
Icon=utilities-terminal
Terminal=false
Categories=Utility;
EOF

chmod +x $DESKTOP_FILE

echo "========================================"
echo "Установка завершена!"
echo "========================================"
echo ""
echo "Запуск приложения:"
echo "1. Команда в терминале: mfc-stats-app"
echo "2. Ярлык на рабочем столе: MFC Stats App"
echo ""
echo "Директория приложения: $APP_DIR"