#!/bin/bash
# Создание ярлыка с иконкой для MFC Stats App

echo "Создание ярлыка для MFC Stats App..."

# Пути
USER_HOME="$HOME"
DESKTOP_FILE="$USER_HOME/Desktop/mfc-stats-app.desktop"
ICON_DIR="$USER_HOME/.local/share/icons"
ICON_PATH="$ICON_DIR/mfc-stats-app.png"

# Создаем иконку если её нет
if [ ! -f "$ICON_PATH" ]; then
    echo "Создание иконки..."
    mkdir -p "$ICON_DIR"

    # Создаем простую иконку с помощью Python
    python3 -c "
import tkinter as tk
from PIL import Image, ImageDraw, ImageFont
import os

# Создаем изображение 256x256
img = Image.new('RGB', (256, 256), color=(0, 120, 215))
draw = ImageDraw.Draw(img)

# Добавляем текст
try:
    font = ImageFont.truetype('/usr/share/fonts/liberation/LiberationSans-Regular.ttf', 80)
except:
    font = ImageFont.load_default()

# Рисуем текст MFC
text = 'MFC'
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (256 - text_width) / 2
y = (256 - text_height) / 2

draw.text((x, y), text, fill='white', font=font)

# Сохраняем
img.save('$ICON_PATH')
print('Иконка создана')
" || echo "Иконка создана без PIL"

    # Если Python не сработал, создаем простую иконку другим способом
    if [ ! -f "$ICON_PATH" ]; then
        echo "Создание простой иконки..."
        convert -size 256x256 xc:#0078D7 -fill white -pointsize 60 \
                -gravity center -draw "text 0,0 'MFC'" "$ICON_PATH" 2>/dev/null || \
        echo "Установите imagemagick для создания иконки: sudo dnf install ImageMagick"
    fi
fi

# Создаем desktop файл
echo "Создание desktop файла..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MFC Stats App
GenericName=Анализатор статистики МФЦ
Comment=Приложение для анализа статистики филиалов МФЦ
Exec=/usr/local/bin/mfc-stats-app
Icon=$ICON_PATH
Terminal=false
StartupNotify=true
Categories=Utility;Office;
Keywords=MFC;статистика;филиалы;анализ;
MimeType=
Path=/opt/mfc-stats-app
EOF

# Устанавливаем права
chmod +x "$DESKTOP_FILE"
chown $USER:$USER "$DESKTOP_FILE"

echo "Ярлык создан: $DESKTOP_FILE"
echo ""
echo "Если ярлык не отображается правильно, попробуйте:"
echo "1. Нажмите правой кнопкой на рабочем столе → 'Обновить'"
echo "2. Перезайдите в систему"
echo "3. В терминале: gtk-update-icon-cache"