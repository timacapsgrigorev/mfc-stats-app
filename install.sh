#!/bin/bash

# Инсталляционный скрипт для RED OS 7.3

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}   Установка MFC Stats App на RED OS 7.3${NC}"
echo -e "${RED}========================================${NC}"

# Проверяем, запущен ли скрипт от root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Внимание: Рекомендуется запускать скрипт с правами root (sudo)${NC}"
    read -p "Продолжить установку в домашнюю директорию? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Запустите скрипт снова с sudo: sudo ./install.sh"
        exit 1
    fi
    USER_INSTALL=true
else
    USER_INSTALL=false
fi

# Устанавливаем зависимости системы
echo -e "${YELLOW}Установка системных зависимостей...${NC}"
yum install -y python3 python3-devel python3-tkinter gcc gcc-c++ make

# Проверяем установку Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Ошибка: Python3 не установлен${NC}"
    exit 1
fi

# Устанавливаем или обновляем pip
echo -e "${YELLOW}Установка/обновление pip...${NC}"
if ! command -v pip3 &> /dev/null; then
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py
    rm -f get-pip.py
else
    pip3 install --upgrade pip
fi

# Устанавливаем зависимости Python
echo -e "${YELLOW}Установка зависимостей Python...${NC}"
pip3 install pandas openpyxl chardet

# Определяем директорию установки
if [ "$USER_INSTALL" = true ]; then
    INSTALL_DIR="$HOME/mfc-stats-app"
    BIN_DIR="$HOME/.local/bin"
    DESKTOP_DIR="$HOME/.local/share/applications"
    ICON_DIR="$HOME/.local/share/icons"
else
    INSTALL_DIR="/opt/mfc-stats-app"
    BIN_DIR="/usr/local/bin"
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/icons"
fi

# Создаем директории
echo -e "${YELLOW}Создание директорий...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR/hicolor/256x256/apps"

# Копируем файлы приложения
echo -e "${YELLOW}Копирование файлов приложения...${NC}"
cp -r src/* "$INSTALL_DIR/"
cp README.md "$INSTALL_DIR/"

# Создаем иконку если нет
if [ ! -f "icons/mfc-stats-app.png" ]; then
    echo -e "${YELLOW}Создание иконки приложения...${NC}"
    # Создаем простую иконку с помощью Python
    python3 -c "
import tkinter as tk
from PIL import Image, ImageDraw, ImageFont
import os

# Создаем изображение 256x256
img = Image.new('RGB', (256, 256), color=(0, 120, 215))
draw = ImageDraw.Draw(img)

# Сохраняем
os.makedirs('icons', exist_ok=True)
img.save('icons/mfc-stats-app.png')
print('Иконка создана')
" || echo "Создание иконки пропущено"
fi

# Копируем иконку если существует
if [ -f "icons/mfc-stats-app.png" ]; then
    cp icons/mfc-stats-app.png "$ICON_DIR/hicolor/256x256/apps/"
fi

# Создаем launch скрипт
echo -e "${YELLOW}Создание launch скрипта...${NC}"
cat > "$INSTALL_DIR/mfc-stats-app" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
python3 mfc_stats_app.py
EOF

chmod +x "$INSTALL_DIR/mfc-stats-app"

# Создаем символическую ссылку
echo -e "${YELLOW}Создание символической ссылки...${NC}"
ln -sf "$INSTALL_DIR/mfc-stats-app" "$BIN_DIR/mfc-stats-app"

# Создаем desktop файл
echo -e "${YELLOW}Создание файла запуска для меню приложений...${NC}"
cat > "$DESKTOP_DIR/mfc-stats-app.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MFC Stats App
Comment=Приложение для анализа статистики филиалов МФЦ
Exec=$BIN_DIR/mfc-stats-app
Icon=mfc-stats-app
Terminal=false
Categories=Utility;Office;
Keywords=MFC;статистика;анализ;филиалы;
StartupNotify=true
EOF

# Обновляем кэш иконок и desktop файлов
echo -e "${YELLOW}Обновление кэша системы...${NC}"
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f "$ICON_DIR/hicolor"
fi

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi

# Добавляем BIN_DIR в PATH если его там нет (для пользовательской установки)
if [ "$USER_INSTALL" = true ] && [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}Добавление $BIN_DIR в PATH...${NC}"
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$PATH:$BIN_DIR\"" >> "$HOME/.bash_profile"
    export PATH="$PATH:$BIN_DIR"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Установка завершена успешно!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Запустить приложение можно следующими способами:${NC}"
echo "1. Из терминала: mfc-stats-app"
echo "2. Из меню приложений: MFC Stats App"
echo ""
echo -e "${YELLOW}Директория установки: $INSTALL_DIR${NC}"
echo ""
if [ "$USER_INSTALL" = true ]; then
    echo -e "${YELLOW}Для обновления PATH выполните:${NC}"
    echo "  source ~/.bashrc"
    echo ""
fi
echo -e "${YELLOW}Для удаления приложения выполните:${NC}"
if [ "$USER_INSTALL" = true ]; then
    echo "  rm -rf $INSTALL_DIR"
    echo "  rm -f $BIN_DIR/mfc-stats-app"
    echo "  rm -f $DESKTOP_DIR/mfc-stats-app.desktop"
    echo "  rm -f $ICON_DIR/hicolor/256x256/apps/mfc-stats-app.png"
else
    echo "  sudo rm -rf $INSTALL_DIR"
    echo "  sudo rm -f $BIN_DIR/mfc-stats-app"
    echo "  sudo rm -f $DESKTOP_DIR/mfc-stats-app.desktop"
    echo "  sudo rm -f $ICON_DIR/hicolor/256x256/apps/mfc-stats-app.png"
fi
echo ""
echo -e "${BLUE}========================================${NC}"