#!/bin/bash

# Упрощенный инсталляционный скрипт для быстрой установки

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Установка MFC Stats App             ${NC}"
echo -e "${BLUE}========================================${NC}"

# Определяем дистрибутив
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    OS=$(uname -s)
    VER=$(uname -r)
fi

echo -e "${YELLOW}Операционная система: $OS $VER${NC}"

# Проверяем Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Ошибка: Python3 не найден${NC}"
    echo -e "${YELLOW}Установка Python3...${NC}"

    case $ID in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y python3 python3-pip python3-tk
            ;;
        fedora)
            sudo dnf install -y python3 python3-pip python3-tkinter
            ;;
        centos|rhel)
            sudo yum install -y python3 python3-pip python3-tkinter
            ;;
        *)
            echo -e "${RED}Неизвестный дистрибутив. Установите Python3 вручную.${NC}"
            exit 1
            ;;
    esac
fi

# Устанавливаем зависимости Python
echo -e "${YELLOW}Установка зависимостей Python...${NC}"
pip3 install pandas openpyxl chardet

# Создаем директорию для приложения
INSTALL_DIR="$HOME/.local/share/mfc-stats-app"
echo -e "${YELLOW}Установка в $INSTALL_DIR...${NC}"
mkdir -p "$INSTALL_DIR"

# Копируем исходный код
echo -e "${YELLOW}Копирование файлов...${NC}"
cp -r src/* "$INSTALL_DIR/"
cp README.md "$INSTALL_DIR/"

# Создаем launch скрипт
echo -e "${YELLOW}Создание launch скрипта...${NC}"
cat > "$INSTALL_DIR/launch.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
python3 mfc_stats_app.py
EOF

chmod +x "$INSTALL_DIR/launch.sh"

# Создаем символическую ссылку
echo -e "${YELLOW}Создание символической ссылки...${NC}"
mkdir -p "$HOME/.local/bin"
ln -sf "$INSTALL_DIR/launch.sh" "$HOME/.local/bin/mfc-stats-app"

# Добавляем ~/.local/bin в PATH если его там нет
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}Добавление ~/.local/bin в PATH...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
    export PATH="$HOME/.local/bin:$PATH"
fi

# Создаем desktop файл для меню приложений
echo -e "${YELLOW}Создание ярлыка в меню приложений...${NC}"
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/mfc-stats-app.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MFC Stats App
Comment=Приложение для анализа статистики филиалов МФЦ
Exec=$HOME/.local/bin/mfc-stats-app
Icon=utilities-terminal
Terminal=false
Categories=Utility;Office;
Keywords=MFC;статистика;анализ;филиалы;
StartupNotify=true
EOF

# Обновляем кэш desktop файлов
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Установка завершена успешно!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Запустить приложение можно следующими способами:${NC}"
echo "1. Из терминала: mfc-stats-app"
echo "2. Из меню приложений: MFC Stats App"
echo ""
echo -e "${YELLOW}Для удаления приложения выполните:${NC}"
echo "  rm -rf $INSTALL_DIR"
echo "  rm -f $HOME/.local/bin/mfc-stats-app"
echo "  rm -f $HOME/.local/share/applications/mfc-stats-app.desktop"
echo ""
echo -e "${BLUE}========================================${NC}"