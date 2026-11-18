"""Главное окно интерфейса"""
#QAPP - управление приложением
from PySide6.QtWidgets import QApplication, QComboBox, QLabel, QVBoxLayout, QWidget

# Для запуска с этого файла
if __name__ == "__main__":
    app = QApplication([])
    window = QWidget() 
    window.setWindowTitle("Конфигуратор шкафов")


# Кнопки, надписи, прочая тема

    label1 = QLabel("Выберите тип шкафа")
    layout = QVBoxLayout(window) # вертикальная расскладка для window
    layout.addWidget(label1)
    cabinet_selector = QComboBox()
    cabinet_selector.addItems(["Шкаф 1", "Шкаф 2", "Шкаф 3", "Шкаф 4"]) # type: ignore
    layout.addWidget(cabinet_selector) # type: ignore

# Настройка

    selected_label = QLabel()
    layout.addWidget(selected_label) # новая надпись под списком

    def update_selection(cabinet_name: str) -> None:
        selected_label.setText(f"Выбран шкав: {cabinet_name}")

    cabinet_selector.currentTextChanged.connect(update_selection)
    update_selection(cabinet_selector.currentText())




    window.show() # делает окно видимым
    app.exec() # цикл событий
