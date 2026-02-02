from setuptools import setup, find_packages
import os

# Читаем README.md для описания
with open('README.md', 'r', encoding='utf-8') as f:
    long_description = f.read()

setup(
    name="mfc-stats-app",
    version="1.0.0",
    author="MFC Statistics Team",
    author_email="",
    description="Приложение для анализа статистики филиалов МФЦ",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="",
    packages=find_packages(),
    package_dir={'': 'src'},
    include_package_data=True,
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
        "Development Status :: 4 - Beta",
        "Intended Audience :: End Users/Desktop",
        "Topic :: Office/Business",
        "Topic :: Scientific/Engineering :: Information Analysis",
    ],
    python_requires=">=3.6",
    install_requires=[
        "pandas>=1.3.0",
        "openpyxl>=3.0.0",
        "chardet>=4.0.0",
    ],
    entry_points={
        'console_scripts': [
            'mfc-stats=mfc_stats_app:main',
        ],
        'gui_scripts': [
            'mfc-stats-gui=mfc_stats_app:main',
        ]
    },
    data_files=[
        ('share/applications', ['mfc-stats-app.desktop']),
        ('share/icons/hicolor/256x256/apps', ['icons/mfc-stats-app.png']),
        ('share/icons/hicolor/128x128/apps', ['icons/mfc-stats-app-128.png']),
        ('share/icons/hicolor/64x64/apps', ['icons/mfc-stats-app-64.png']),
    ],
)