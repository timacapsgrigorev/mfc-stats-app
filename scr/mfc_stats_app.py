import pandas as pd
import tkinter as tk
from tkinter import filedialog, messagebox, ttk
import chardet
import os
from tkinter import ttk
import sys


class MFCStatsApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Статистика филиалов МФЦ")
        self.root.geometry("700x600")

        # Центрируем окно
        self.center_window()

        # Создаем Notebook (вкладки)
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Создаем первую вкладку - Восстановление
        self.tab1 = tk.Frame(self.notebook)
        self.notebook.add(self.tab1, text="Восстановление")

        # Создаем вторую вкладку - Создание + Подтверждение
        self.tab2 = tk.Frame(self.notebook)
        self.notebook.add(self.tab2, text="Создание + Подтверждение")

        # Инициализируем вкладки
        self.init_tab1()
        self.init_tab2()

        # Создаем меню
        self.create_menu()

    def center_window(self):
        """Центрировать окно на экране"""
        self.root.update_idletasks()
        width = self.root.winfo_width()
        height = self.root.winfo_height()
        x = (self.root.winfo_screenwidth() // 2) - (width // 2)
        y = (self.root.winfo_screenheight() // 2) - (height // 2)
        self.root.geometry(f'{width}x{height}+{x}+{y}')

    def create_menu(self):
        """Создать меню приложения"""
        menubar = tk.Menu(self.root)
        self.root.config(menu=menubar)

        # Меню Файл
        file_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Файл", menu=file_menu)
        file_menu.add_command(label="Выход", command=self.root.quit)

        # Меню Справка
        help_menu = tk.Menu(menubar, tearoff=0)
        menubar.add_cascade(label="Справка", menu=help_menu)
        help_menu.add_command(label="О программе", command=self.show_about)

    def show_about(self):
        """Показать информацию о программе"""
        about_text = """Статистика филиалов МФЦ
Версия 1.0

Программа для анализа статистики операций по филиалам МФЦ.

Функции:
- Вкладка "Восстановление": анализ одного CSV файла
- Вкладка "Создание + Подтверждение": анализ двух CSV файлов с суммированием

Поддерживаемые форматы: CSV файлы с разделителем ';'
Результаты сохраняются в Excel формат."""

        messagebox.showinfo("О программе", about_text)

    def init_tab1(self):
        """Инициализация вкладки Восстановление"""
        self.tab1_file_path = None
        self.tab1_data = None

        # Фрейм для кнопок
        button_frame = tk.Frame(self.tab1, padx=10, pady=10)
        button_frame.pack(fill=tk.X)

        # Кнопка открытия файла
        self.tab1_open_button = tk.Button(button_frame, text="Открыть CSV файл",
                                          command=lambda: self.open_file('tab1'), width=25)
        self.tab1_open_button.pack(side=tk.LEFT, padx=5)

        # Кнопка подсчета
        self.tab1_count_button = tk.Button(button_frame, text="Посчитать количество",
                                           command=lambda: self.count_statistics('tab1'),
                                           width=25, state=tk.DISABLED)
        self.tab1_count_button.pack(side=tk.LEFT, padx=5)

        # Кнопка сохранения
        self.tab1_save_button = tk.Button(button_frame, text="Сохранить в Excel",
                                          command=lambda: self.save_to_excel('tab1'),
                                          width=25, state=tk.DISABLED)
        self.tab1_save_button.pack(side=tk.LEFT, padx=5)

        # Область информации о файле
        info_frame = tk.LabelFrame(self.tab1, text="Информация о файле", padx=10, pady=10)
        info_frame.pack(fill=tk.X, padx=10, pady=5)

        self.tab1_file_label = tk.Label(info_frame, text="Файл не выбран", anchor="w")
        self.tab1_file_label.pack(fill=tk.X)

        self.tab1_stats_label = tk.Label(info_frame, text="", anchor="w")
        self.tab1_stats_label.pack(fill=tk.X)

        # Область для отображения результатов
        results_frame = tk.LabelFrame(self.tab1, text="Результаты подсчета", padx=10, pady=10)
        results_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)

        # Создаем Treeview для отображения таблицы
        self.tab1_tree = ttk.Treeview(results_frame, columns=('Филиал', 'Количество'),
                                      show='headings', height=15)

        # Настраиваем колонки
        self.tab1_tree.heading('Филиал', text='Филиал')
        self.tab1_tree.heading('Количество', text='Количество')

        # Настраиваем ширину колонок
        self.tab1_tree.column('Филиал', width=450)
        self.tab1_tree.column('Количество', width=150)

        # Добавляем прокрутку
        scrollbar = ttk.Scrollbar(results_frame, orient=tk.VERTICAL, command=self.tab1_tree.yview)
        self.tab1_tree.configure(yscrollcommand=scrollbar.set)

        self.tab1_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

    def init_tab2(self):
        """Инициализация вкладки Создание + Подтверждение"""
        self.tab2_file1_path = None
        self.tab2_file2_path = None
        self.tab2_data1 = None
        self.tab2_data2 = None
        self.tab2_stats = None

        # Фрейм для файла 1
        file1_frame = tk.LabelFrame(self.tab2, text="Первый файл (Создание)", padx=10, pady=10)
        file1_frame.pack(fill=tk.X, padx=10, pady=5)

        self.tab2_file1_button = tk.Button(file1_frame, text="Выбрать файл",
                                           command=lambda: self.open_file('tab2_file1'), width=20)
        self.tab2_file1_button.pack(side=tk.LEFT, padx=5)

        self.tab2_file1_label = tk.Label(file1_frame, text="Файл не выбран", anchor="w")
        self.tab2_file1_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)

        # Фрейм для файла 2
        file2_frame = tk.LabelFrame(self.tab2, text="Второй файл (Подтверждение)", padx=10, pady=10)
        file2_frame.pack(fill=tk.X, padx=10, pady=5)

        self.tab2_file2_button = tk.Button(file2_frame, text="Выбрать файл",
                                           command=lambda: self.open_file('tab2_file2'), width=20)
        self.tab2_file2_button.pack(side=tk.LEFT, padx=5)

        self.tab2_file2_label = tk.Label(file2_frame, text="Файл не выбран", anchor="w")
        self.tab2_file2_label.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)

        # Фрейм для кнопок управления
        control_frame = tk.Frame(self.tab2, padx=10, pady=10)
        control_frame.pack(fill=tk.X)

        # Кнопка подсчета суммы
        self.tab2_count_button = tk.Button(control_frame, text="Посчитать сумму по филиалам",
                                           command=self.count_tab2_statistics,
                                           width=30, state=tk.DISABLED)
        self.tab2_count_button.pack(side=tk.LEFT, padx=5)

        # Кнопка сохранения
        self.tab2_save_button = tk.Button(control_frame, text="Сохранить в Excel",
                                          command=lambda: self.save_to_excel('tab2'),
                                          width=20, state=tk.DISABLED)
        self.tab2_save_button.pack(side=tk.LEFT, padx=5)

        # Область информации
        info_frame = tk.LabelFrame(self.tab2, text="Информация", padx=10, pady=10)
        info_frame.pack(fill=tk.X, padx=10, pady=5)

        self.tab2_stats_label = tk.Label(info_frame, text="Выберите два файла для подсчета суммы", anchor="w")
        self.tab2_stats_label.pack(fill=tk.X)

        # Область для отображения результатов
        results_frame = tk.LabelFrame(self.tab2, text="Суммарные результаты", padx=10, pady=10)
        results_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)

        # Создаем Treeview для отображения таблицы
        self.tab2_tree = ttk.Treeview(results_frame, columns=('Филиал', 'Файл 1', 'Файл 2', 'Сумма'),
                                      show='headings', height=15)

        # Настраиваем колонки
        self.tab2_tree.heading('Филиал', text='Филиал')
        self.tab2_tree.heading('Файл 1', text='Файл 1 (Создание)')
        self.tab2_tree.heading('Файл 2', text='Файл 2 (Подтверждение)')
        self.tab2_tree.heading('Сумма', text='Сумма')

        # Настраиваем ширину колонки
        self.tab2_tree.column('Филиал', width=300)
        self.tab2_tree.column('Файл 1', width=100)
        self.tab2_tree.column('Файл 2', width=100)
        self.tab2_tree.column('Сумма', width=100)

        # Добавляем прокрутку
        scrollbar = ttk.Scrollbar(results_frame, orient=tk.VERTICAL, command=self.tab2_tree.yview)
        self.tab2_tree.configure(yscrollcommand=scrollbar.set)

        self.tab2_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

    def open_file(self, tab_type):
        """Открыть CSV файл для соответствующей вкладки"""
        file_path = filedialog.askopenfilename(
            title="Выберите CSV файл",
            filetypes=[("CSV файлы", "*.csv"), ("Все файлы", "*.*")]
        )

        if not file_path:
            return

        try:
            # Определяем кодировку файла
            with open(file_path, 'rb') as f:
                result = chardet.detect(f.read())
            encoding = result['encoding']

            # Читаем CSV файл с разделителем ';'
            data = pd.read_csv(file_path, sep=';', encoding=encoding)

            # Проверяем, что во втором столбце есть данные
            if len(data.columns) < 2:
                messagebox.showerror("Ошибка", "Файл должен содержать как минимум 2 столбца")
                return

            if tab_type == 'tab1':
                # Вкладка Восстановление
                self.tab1_file_path = file_path
                self.tab1_data = data
                self.tab1_file_label.config(text=f"Файл: {os.path.basename(file_path)}")
                self.tab1_stats_label.config(text=f"Строк в файле: {len(data)}")
                self.tab1_count_button.config(state=tk.NORMAL)
                messagebox.showinfo("Успех", f"Файл загружен успешно!\nКоличество строк: {len(data)}")

            elif tab_type == 'tab2_file1':
                # Первый файл для вкладки 2
                self.tab2_file1_path = file_path
                self.tab2_data1 = data
                self.tab2_file1_label.config(text=f"Файл: {os.path.basename(file_path)} ({len(data)} строк)")
                self.check_tab2_files()

            elif tab_type == 'tab2_file2':
                # Второй файл для вкладки 2
                self.tab2_file2_path = file_path
                self.tab2_data2 = data
                self.tab2_file2_label.config(text=f"Файл: {os.path.basename(file_path)} ({len(data)} строк)")
                self.check_tab2_files()

        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось загрузить файл:\n{str(e)}")

    def check_tab2_files(self):
        """Проверить, загружены ли оба файла для вкладки 2"""
        if self.tab2_data1 is not None and self.tab2_data2 is not None:
            self.tab2_count_button.config(state=tk.NORMAL)
            self.tab2_stats_label.config(text="Оба файла загружены. Нажмите 'Посчитать сумму по филиалам'")

    def count_statistics(self, tab_type):
        """Подсчитать статистику для вкладки"""
        if tab_type == 'tab1':
            data = self.tab1_data
            tree = self.tab1_tree
            stats_label = self.tab1_stats_label
            save_button = self.tab1_save_button
        else:
            return

        if data is None:
            messagebox.showerror("Ошибка", "Сначала откройте файл")
            return

        try:
            # Очищаем старые данные в таблице
            for item in tree.get_children():
                tree.delete(item)

            # Получаем название второго столбца
            column_name = data.columns[1] if len(data.columns) >= 2 else None

            if column_name is None:
                messagebox.showerror("Ошибка", "Не удалось определить второй столбец")
                return

            # Подсчитываем количество строк для каждого уникального значения в столбце
            stats = data[column_name].value_counts().reset_index()
            stats.columns = ['Филиал', 'Количество']

            # Сортируем по количеству (по убыванию)
            stats = stats.sort_values('Количество', ascending=False)

            # Сохраняем статистику
            if tab_type == 'tab1':
                self.tab1_stats = stats

            # Добавляем данные в Treeview
            for _, row in stats.iterrows():
                tree.insert('', 'end', values=(row['Филиал'], row['Количество']))

            # Обновляем информацию
            total_count = stats['Количество'].sum()
            unique_filials = len(stats)
            stats_label.config(text=f"Строк в файле: {len(data)} | "
                                    f"Уникальных филиалов: {unique_filials} | "
                                    f"Всего операций: {total_count}")

            # Активируем кнопку сохранения
            save_button.config(state=tk.NORMAL)

        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось подсчитать статистику:\n{str(e)}")

    def count_tab2_statistics(self):
        """Подсчитать суммарную статистику для вкладки 2"""
        if self.tab2_data1 is None or self.tab2_data2 is None:
            messagebox.showerror("Ошибка", "Сначала загрузите оба файла")
            return

        try:
            # Очищаем старые данные в таблице
            for item in self.tab2_tree.get_children():
                self.tab2_tree.delete(item)

            # Получаем названия второго столбца для обоих файлов
            column_name1 = self.tab2_data1.columns[1] if len(self.tab2_data1.columns) >= 2 else None
            column_name2 = self.tab2_data2.columns[1] if len(self.tab2_data2.columns) >= 2 else None

            if column_name1 is None or column_name2 is None:
                messagebox.showerror("Ошибка", "В одном из файлов не удалось определить второй столбец")
                return

            # Подсчитываем количество строк для каждого уникального значения в столбце
            stats1 = self.tab2_data1[column_name1].value_counts().reset_index()
            stats1.columns = ['Филиал', 'Количество1']

            stats2 = self.tab2_data2[column_name2].value_counts().reset_index()
            stats2.columns = ['Филиал', 'Количество2']

            # Объединяем данные по филиалам (полное внешнее соединение)
            merged_stats = pd.merge(stats1, stats2, on='Филиал', how='outer')

            # Заполняем пропущенные значения нулями
            merged_stats['Количество1'] = merged_stats['Количество1'].fillna(0).astype(int)
            merged_stats['Количество2'] = merged_stats['Количество2'].fillna(0).astype(int)

            # Считаем сумму
            merged_stats['Сумма'] = merged_stats['Количество1'] + merged_stats['Количество2']

            # Сортируем по сумме (по убыванию)
            merged_stats = merged_stats.sort_values('Сумма', ascending=False)

            # Сохраняем статистику
            self.tab2_stats = merged_stats

            # Добавляем данные в Treeview
            for _, row in merged_stats.iterrows():
                self.tab2_tree.insert('', 'end', values=(
                    row['Филиал'],
                    row['Количество1'],
                    row['Количество2'],
                    row['Сумма']
                ))

            # Обновляем информацию
            total_sum = merged_stats['Сумма'].sum()
            total1 = merged_stats['Количество1'].sum()
            total2 = merged_stats['Количество2'].sum()
            unique_filials = len(merged_stats)

            self.tab2_stats_label.config(
                text=f"Уникальных филиалов: {unique_filials} | "
                     f"Всего в файле 1: {total1} | "
                     f"Всего в файле 2: {total2} | "
                     f"Общая сумма: {total_sum}"
            )

            # Активируем кнопку сохранения
            self.tab2_save_button.config(state=tk.NORMAL)

        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось подсчитать статистику:\n{str(e)}")

    def save_to_excel(self, tab_type):
        """Сохранить результаты в Excel файл"""
        if tab_type == 'tab1':
            if not hasattr(self, 'tab1_stats') or self.tab1_stats is None:
                messagebox.showerror("Ошибка", "Сначала выполните подсчет статистики")
                return

            stats = self.tab1_stats
            default_name = "статистика_восстановление.xlsx"

        elif tab_type == 'tab2':
            if not hasattr(self, 'tab2_stats') or self.tab2_stats is None:
                messagebox.showerror("Ошибка", "Сначала выполните подсчет статистики")
                return

            stats = self.tab2_stats
            default_name = "статистика_создание_подтверждение.xlsx"

        else:
            return

        file_path = filedialog.asksaveasfilename(
            title="Сохранить результаты в Excel",
            defaultextension=".xlsx",
            initialfile=default_name,
            filetypes=[("Excel файлы", "*.xlsx"), ("Все файлы", "*.*")]
        )

        if file_path:
            try:
                # Сохраняем в Excel с кодировкой UTF-8
                with pd.ExcelWriter(file_path, engine='openpyxl') as writer:
                    if tab_type == 'tab1':
                        # Сохраняем статистику восстановления
                        stats.to_excel(writer, sheet_name='Статистика восстановления', index=False)

                        # Также сохраняем исходные данные
                        if self.tab1_data is not None:
                            self.tab1_data.to_excel(writer, sheet_name='Исходные данные', index=False)

                    elif tab_type == 'tab2':
                        # Сохраняем суммарную статистику
                        stats.to_excel(writer, sheet_name='Суммарная статистика', index=False)

                        # Сохраняем отдельные статистики по файлам
                        if self.tab2_data1 is not None:
                            column_name1 = self.tab2_data1.columns[1]
                            stats1 = self.tab2_data1[column_name1].value_counts().reset_index()
                            stats1.columns = ['Филиал', 'Количество']
                            stats1.to_excel(writer, sheet_name='Статистика файла 1', index=False)

                        if self.tab2_data2 is not None:
                            column_name2 = self.tab2_data2.columns[1]
                            stats2 = self.tab2_data2[column_name2].value_counts().reset_index()
                            stats2.columns = ['Филиал', 'Количество']
                            stats2.to_excel(writer, sheet_name='Статистика файла 2', index=False)

                messagebox.showinfo("Успех", f"Результаты сохранены в файл:\n{file_path}")

            except Exception as e:
                messagebox.showerror("Ошибка", f"Не удалось сохранить файл:\n{str(e)}")


def main():
    try:
        root = tk.Tk()
        app = MFCStatsApp(root)
        root.mainloop()
    except Exception as e:
        print(f"Ошибка при запуске приложения: {e}")
        import traceback
        traceback.print_exc()
        input("Нажмите Enter для выхода...")


if __name__ == "__main__":
    main()