#!/bin/bash

# Инсталляционный скрипт для RED OS 7.3

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Установка MFC Stats App на RED OS 7.3${NC}"
echo -e "${BLUE}========================================${NC}"

# Определяем менеджер пакетов
if command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo -e "${RED}Ошибка: Не найден менеджер пакетов (dnf/yum)${NC}"
    exit 1
fi

echo -e "${YELLOW}Используется менеджер пакетов: $PKG_MANAGER${NC}"

# Проверяем, запущен ли скрипт от root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Внимание: Рекомендуется запускать скрипт с правами root${NC}"
    echo -e "${YELLOW}Запустите: sudo ./install-redos.sh${NC}"
    exit 1
fi

# Устанавливаем зависимости системы
echo -e "${YELLOW}1. Установка системных зависимостей...${NC}"
$PKG_MANAGER install -y python3 python3-devel python3-tkinter gcc gcc-c++ make

# Проверяем установку Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Ошибка: Python3 не установлен${NC}"
    exit 1
fi

echo -e "${GREEN}Python3 установлен: $(python3 --version)${NC}"

# Устанавливаем pip
echo -e "${YELLOW}2. Установка pip...${NC}"
if ! command -v pip3 &> /dev/null; then
    # Устанавливаем pip из репозитория
    if $PKG_MANAGER search python3-pip &> /dev/null; then
        $PKG_MANAGER install -y python3-pip
    else
        # Устанавливаем pip вручную
        echo -e "${YELLOW}Установка pip вручную...${NC}"
        curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        python3 /tmp/get-pip.py
        rm -f /tmp/get-pip.py
    fi
else
    echo -e "${GREEN}Pip уже установлен${NC}"
fi

echo -e "${GREEN}Pip установлен: $(pip3 --version)${NC}"

# Устанавливаем зависимости Python
echo -e "${YELLOW}3. Установка зависимостей Python...${NC}"
pip3 install pandas openpyxl chardet

# Проверяем установку зависимостей
echo -e "${YELLOW}4. Проверка установленных пакетов...${NC}"
python3 -c "import pandas; print(f'✓ pandas: {pandas.__version__}')"
python3 -c "import openpyxl; print(f'✓ openpyxl: {openpyxl.__version__}')"
python3 -c "import chardet; print(f'✓ chardet: {chardet.__version__}')"

# Создаем директорию для приложения
INSTALL_DIR="/opt/mfc-stats-app"
echo -e "${YELLOW}5. Создание директории приложения...${NC}"
mkdir -p "$INSTALL_DIR"

# Копируем файлы приложения
echo -e "${YELLOW}6. Копирование файлов приложения...${NC}"
cp -r src/* "$INSTALL_DIR/" 2>/dev/null || echo "Копирование src/*"
cp mfc_stats_app.py "$INSTALL_DIR/" 2>/dev/null || echo "Копирование основного файла"
cp README.md "$INSTALL_DIR/" 2>/dev/null || echo "Копирование README"

# Проверяем, что основной файл существует
if [ ! -f "$INSTALL_DIR/mfc_stats_app.py" ]; then
    echo -e "${RED}Ошибка: Основной файл приложения не найден${NC}"
    echo "Поместите файл mfc_stats_app.py в текущую директорию"
    exit 1
fi

# Создаем скрипт запуска
echo -e "${YELLOW}7. Создание скрипта запуска...${NC}"
cat > /usr/local/bin/mfc-stats-app << 'EOF'
#!/bin/bash
cd /opt/mfc-stats-app
python3 mfc_stats_app.py
EOF

chmod +x /usr/local/bin/mfc-stats-app

# Создаем desktop файл
echo -e "${YELLOW}8. Создание ярлыка в меню приложений...${NC}"
DESKTOP_FILE="/usr/share/applications/mfc-stats-app.desktop"
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MFC Stats App
Comment=Приложение для анализа статистики филиалов МФЦ
Exec=/usr/local/bin/mfc-stats-app
Icon=utilities-terminal
Terminal=false
Categories=Utility;Office;
Keywords=MFC;статистика;анализ;филиалы;
StartupNotify=true
EOF

# Создаем ярлык на рабочем столе для текущего пользователя
if [ -d "$HOME/Desktop" ]; then
    USER_DESKTOP="$HOME/Desktop/mfc-stats-app.desktop"
    cp "$DESKTOP_FILE" "$USER_DESKTOP"
    chown $(whoami):$(whoami) "$USER_DESKTOP"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Установка завершена успешно!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Запустить приложение можно следующими способами:${NC}"
echo "1. Из терминала: mfc-stats-app"
echo "2. Из меню приложений: MFC Stats App"
echo "3. Ярлык на рабочем столе: MFC Stats App"
echo ""
echo -e "${YELLOW}Директория приложения: $INSTALL_DIR${NC}"
echo ""
echo -e "${YELLOW}Для тестирования запустите:${NC}"
echo "  mfc-stats-app"
echo ""
echo -e "${BLUE}========================================${NC}"