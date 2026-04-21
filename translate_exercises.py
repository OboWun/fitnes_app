#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Скрипт для перевода exercises.json (элементы 1-500) на русский язык.
Переводит name и instructions, сохраняя slug из name.
"""

import json
import re
import time
from deep_translator import GoogleTranslator
from typing import List, Dict, Any

translator = GoogleTranslator(source='en', target='ru')

def translate_text(text: str) -> str:
    """Переводит текст на русский язык."""
    if not text or not isinstance(text, str):
        return text
    
    # Если текст уже содержит русские буквы, пропускаем
    if re.search(r'[а-яА-ЯёЁ]', text):
        return text
    
    try:
        translated = translator.translate(text)
        return translated
    except Exception as e:
        print(f"Ошибка перевода: {e}")
        return text

def translate_instructions(instructions: List[str]) -> List[str]:
    """Переводит список инструкций."""
    translated = []
    for instruction in instructions:
        trans = translate_text(instruction)
        translated.append(trans)
    return translated

def main():
    # Загружаем данные
    with open('/workspace/backend/src/data/exercises.json', 'r', encoding='utf-8') as f:
        exercises = json.load(f)
    
    print(f"Всего упражнений: {len(exercises)}")
    print("Начинаем перевод элементов 0-499...")
    
    count = 0
    # Переводим первые 500 элементов (индексы 0-499)
    for i in range(min(500, len(exercises))):
        exercise = exercises[i]
        
        # Сохраняем оригинальное имя как slug (если еще не сохранено)
        if 'original_name' not in exercise:
            exercise['original_name'] = exercise.get('name', '')
        
        # Переводим name только если он на английском
        name = exercise.get('name', '')
        if name and not re.search(r'[а-яА-ЯёЁ]', name):
            translated_name = translate_text(name)
            print(f"[{i}] Name: '{name[:50]}...' -> '{translated_name[:50]}...'")
            exercise['name'] = translated_name
            count += 1
        
        # Переводим инструкции
        instructions = exercise.get('instructions', [])
        if instructions:
            # Проверяем, нужно ли переводить (если первая инструкция на английском)
            first_instr = instructions[0] if instructions else ''
            if first_instr and not re.search(r'[а-яА-ЯёЁ]', first_instr):
                translated_instructions = translate_instructions(instructions)
                exercise['instructions'] = translated_instructions
                print(f"    Instructions переведены: {len(instructions)} шагов")
        
        # Пауза чтобы не превысить лимиты API
        if (i + 1) % 20 == 0:
            print(f"Обработано {i + 1} упражнений...")
            time.sleep(2)
    
    # Сохраняем результат в новый файл
    output_path = '/workspace/backend/src/data/exercises_translated_0_499.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(exercises, f, ensure_ascii=False, indent=2)
    
    print(f"\nГотово! Переведенные данные сохранены в {output_path}")
    print(f"Обработано упражнений: {min(500, len(exercises))}")
    print(f"Переведено имен: {count}")

if __name__ == '__main__':
    main()
