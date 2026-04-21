#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Скрипт для перевода exercises.json на русский язык (первые 500 элементов)
"""
import json
import re

def translate_instruction(text):
    """Перевод инструкций упражнений на русский язык"""
    
    translations = {
        # Общие фразы
        "Stand with your feet shoulder-width apart": "Встаньте, поставив ноги на ширине плеч",
        "Stand with your feet hip-width apart": "Встаньте, поставив ноги на ширине бёдер",
        "feet shoulder-width apart": "ноги на ширине плеч",
        "feet hip-width apart": "ноги на ширине бёдер",
        "Keep your back straight": "Держите спину прямо",
        "keeping your back straight": "держа спину прямо",
        "core engaged": "мышцы кора напряжены",
        "Slowly lower": "Медленно опустите",
        "slowly lower": "медленно опустите",
        "Return to the starting position": "Вернитесь в исходное положение",
        "return to the starting position": "вернитесь в исходное положение",
        "starting position": "исходное положение",
        "Repeat for the desired number of repetitions": "Повторите нужное количество раз",
        "Pause for a moment": "Сделайте паузу на мгновение",
        "pause for a moment": "сделайте паузу на мгновение",
        "Hold the contraction for a moment": "Задержитесь в точке напряжения на мгновение",
        "hold the contraction for a moment": "задержитесь в точке напряжения на мгновение",
        "for a moment": "на мгновение",
        "with a controlled motion": "контролируемым движением",
        "With a controlled motion": "Контролируемым движением",
        "In one fluid motion": "Одним плавным движением",
        "in one fluid motion": "одним плавным движением",
        
        # Начальные позиции
        "Stand": "Встаньте",
        "stand": "встаньте",
        "Sit on": "Сядьте на",
        "sit on": "сядьте на",
        "Lie on": "Лягте на",
        "lie on": "лягте на",
        "Lie flat on your back": "Лягте на спину",
        "lie flat on your back": "лягте на спину",
        "Lie face down": "Лягте лицом вниз",
        "lie face down": "лягте лицом вниз",
        "Lie on your side": "Лягте на бок",
        "lie on your side": "лягте на бок",
        
        # Хваты
        "holding": "держа",
        "Hold": "Возьмите",
        "hold": "держите",
        "with an overhand grip": "хватом сверху",
        "with an underhand grip": "хватом снизу",
        "with a neutral grip": "нейтральным хватом",
        "with a close grip": "узким хватом",
        "with a wide grip": "широким хватом",
        "palms facing forward": "ладонями вперёд",
        "palms facing backward": "ладонями назад",
        "palms facing each other": "ладонями друг к другу",
        "palms facing down": "ладонями вниз",
        "palms facing up": "ладонями вверх",
        
        # Действия
        "Bend your knees": "Согните колени",
        "bend your knees": "согните колени",
        "Extend your arms": "Разогните руки",
        "extend your arms": "разогните руки",
        "Lift": "Поднимите",
        "lift": "поднимите",
        "Lower": "Опустите",
        "lower": "опустите",
        "Raise": "Поднимите",
        "raise": "поднимите",
        "Push": "Вытолкните",
        "push": "вытолкните",
        "Pull": "Тяните",
        "pull": "тяните",
        "Squeeze": "Сожмите",
        "squeeze": "сожмите",
        "Engage your": "Напрягите",
        "engage your": "напрягите",
        "Step forward": "Сделайте шаг вперёд",
        "step forward": "шаг вперёд",
        "Step backward": "Сделайте шаг назад",
        "step backward": "шаг назад",
        "Step to the side": "Сделайте шаг в сторону",
        "step to the side": "шаг в сторону",
        
        # Части тела
        "your feet": "ваши ступни",
        "your legs": "ваши ноги",
        "your knees": "ваши колени",
        "your thighs": "ваши бёдра",
        "your hips": "ваши бёдра",
        "your back": "вашу спину",
        "your chest": "вашу грудь",
        "your shoulders": "ваши плечи",
        "your arms": "ваши руки",
        "your elbows": "ваши локти",
        "your hands": "ваши кисти",
        "your head": "вашу голову",
        "your neck": "вашу шею",
        "your core": "ваш кор",
        "your abs": "ваш пресс",
        "your glutes": "ваши ягодицы",
        "your calves": "ваши икры",
        
        # Направления
        "upward": "вверх",
        "downward": "вниз",
        "forward": "вперёд",
        "backward": "назад",
        "to the side": "в сторону",
        "out to the sides": "в стороны",
        "straight down": "прямо вниз",
        "straight up": "прямо вверх",
        "parallel to the ground": "параллельно полу",
        "perpendicular to the ground": "перпендикулярно полу",
        
        # Оборудование
        "barbell": "штанга",
        "dumbbell": "гантель",
        "dumbbells": "гантели",
        "kettlebell": "гиря",
        "kettlebells": "гири",
        "band": "эспандер",
        "cable": "трос",
        "machine": "тренажёр",
        "bench": "скамья",
        "mat": "коврик",
        "ball": "мяч",
        "stability ball": "фитбол",
        "pull-up bar": "турник",
        "box": "бокс/платформа",
        
        # Описания
        "slightly": "слегка",
        "fully": "полностью",
        "controlled": "контролируемый",
        "explosive": "взрывной",
        "smooth": "плавный",
        "steady": "ровный",
        
        # Дыхание
        "exhale": "выдох",
        "inhale": "вдох",
        "as you exhale": "на выдохе",
        "as you inhale": "на вдохе",
        "while breathing": "во время дыхания",
        
        # Связки
        "then": "затем",
        "next": "далее",
        "after": "после",
        "before": "перед",
        "while": "в то время как",
        "when": "когда",
        "until": "до тех пор пока",
        "by": "путём",
        "with": "с",
    }
    
    result = text
    
    # Применяем переводы от самых длинных к коротким
    sorted_translations = sorted(translations.items(), key=lambda x: len(x[0]), reverse=True)
    
    for eng, rus in sorted_translations:
        # Используем regex для замены с учётом регистра
        pattern = re.compile(re.escape(eng), re.IGNORECASE)
        result = pattern.sub(rus, result)
    
    # Очищаем Step:N формат
    result = re.sub(r'Step:\s*\d+\s*', '', result)
    
    return result.strip()

def main():
    # Загружаем данные
    with open('/workspace/backend/src/data/exercises.json', 'r', encoding='utf-8') as f:
        exercises = json.load(f)
    
    print(f"Всего упражнений: {len(exercises)}")
    print("Начинаем перевод первых 500 элементов...")
    
    translated_exercises = []
    
    for i, exercise in enumerate(exercises[:500]):
        translated_exercise = exercise.copy()
        
        # Переводим name (оставляем slug как есть - это будет старый name)
        # В данном случае name уже на русском, но instructions на английском
        if 'instructions' in exercise:
            translated_instructions = []
            for instruction in exercise['instructions']:
                translated_instr = translate_instruction(instruction)
                translated_instructions.append(translated_instr)
            translated_exercise['instructions'] = translated_instructions
        
        translated_exercises.append(translated_exercise)
        
        if (i + 1) % 100 == 0:
            print(f"Переведено {i + 1} упражнений")
    
    # Сохраняем результат
    output_file = '/workspace/backend/src/data/exercises_part1.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(translated_exercises, f, ensure_ascii=False, indent=2)
    
    print(f"\nПеревод завершён! Результат сохранён в {output_file}")
    print(f"Переведено упражнений: {len(translated_exercises)}")
    
    # Показываем пример
    print("\nПример переведённого упражнения:")
    print(json.dumps(translated_exercises[0], ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()
