#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import re

def translate_instruction(text):
    text = re.sub(r'Step:\s*\d+\s*', '', text).strip()
    
    # Полные фразы (порядок важен - сначала самые длинные)
    phrases = [
        ("Stand with your feet shoulder-width apart and place", "Встаньте, поставив ноги на ширине плеч, и поместите"),
        ("Stand with your feet shoulder-width apart", "Встаньте, поставив ноги на ширине плеч"),
        ("Stand with your feet hip-width apart", "Встаньте, поставив ноги на ширине бёдер"),
        ("hands slightly wider than shoulder-width apart", "руки чуть шире плеч"),
        ("Keep your arms straight and relaxed", "Держите руки прямыми и расслабленными"),
        ("keeping your arms straight and relaxed", "держа руки прямыми и расслабленными"),
        ("Keep your back straight and core engaged", "Держите спину прямо, мышцы кора напряжены"),
        ("keeping your back straight and core engaged", "держа спину прямо, мышцы кора напряжены"),
        ("Lie flat on your back on a mat", "Лягте на спину на коврик"),
        ("Lie flat on your back", "Лягте на спину"),
        ("Lower your body by bending both knees", "Опустите тело, согнув оба колена"),
        ("until your thigh is parallel to the ground", "пока бедро не станет параллельно полу"),
        ("until your thighs are parallel to the ground", "пока бёдра не станут параллельны полу"),
        ("Push through your heel to return", "Оттолкнитесь пяткой, чтобы вернуться"),
        ("Push through your heels to return", "Оттолкнитесь пятками, чтобы вернуться"),
        ("Push through your heel", "Оттолкнитесь пяткой"),
        ("Push through your heels", "Оттолкнитесь пятками"),
        ("return to the starting position", "вернитесь в исходное положение"),
        ("Return to the starting position", "Вернитесь в исходное положение"),
        ("Repeat for the desired number of repetitions", "Повторите нужное количество раз"),
        ("Hold the contraction for a moment", "Задержитесь в точке напряжения на мгновение"),
        ("hold the contraction for a moment", "задержитесь в точке напряжения на мгновение"),
        ("Pause for a moment", "Сделайте паузу на мгновение"),
        ("pause for a moment", "сделайте паузу на мгновение"),
        ("with a controlled motion", "контролируемым движением"),
        ("With a controlled motion", "Контролируемым движением"),
        ("In one fluid motion", "Одним плавным движением"),
        ("in one fluid motion", "одним плавным движением"),
        ("keeping your elbows high and out to the sides", "держа локти высоко и разведёнными в стороны"),
        ("keeping your elbows close to your body", "держа локти близко к телу"),
        ("keeping your back straight", "держа спину прямо"),
        ("keeping your core engaged", "держа мышцы кора напряжёнными"),
        ("as you exhale", "на выдохе"),
        ("as you inhale", "на вдохе"),
        ("palms facing forward", "ладонями вперёд"),
        ("palms facing backward", "ладонями назад"),
        ("palms facing each other", "ладонями друг к другу"),
        ("palms facing down", "ладонями вниз"),
        ("palms facing up", "ладонями вверх"),
        ("overhand grip", "хватом сверху"),
        ("underhand grip", "хватом снизу"),
        ("neutral grip", "нейтральным хватом"),
        ("close grip", "узким хватом"),
        ("wide grip", "широким хватом"),
        ("both hands", "обеими руками"),
        ("out to the sides", "в стороны"),
        ("to the sides", "в стороны"),
        ("to the side", "в сторону"),
        ("straight down", "прямо вниз"),
        ("straight up", "прямо вверх"),
        ("parallel to the ground", "параллельно полу"),
        ("perpendicular to the ground", "перпендикулярно полу"),
        ("at a 45-degree angle", "под углом 45 градусов"),
        ("at shoulder height", "на высоте плеч"),
        ("at chest level", "на уровне груди"),
        ("as high as possible", "как можно выше"),
        ("back down to", "обратно в"),
        ("shoulder-width apart", "на ширине плеч"),
        ("hip-width apart", "на ширине бёдер"),
    ]
    
    result = text
    for eng, rus in phrases:
        result = result.replace(eng, rus)
    
    # Слова (от длинных к коротким)
    words = [
        ("Standing", "Встаньте"), ("Stand", "Встаньте"), ("Sitting", "Сядьте"), ("Sit", "Сядьте"),
        ("Lying", "Лягте"), ("Lie", "Лягте"), ("Holding", "Держа"), ("Hold", "Возьмите"),
        ("Grip", "Возьмите"), ("Place", "Поместите"), ("Position", "Расположите"),
        ("Bend", "Согните"), ("Extend", "Разогните"), ("Lift", "Поднимите"), ("Lower", "Опустите"),
        ("Raise", "Поднимите"), ("Push", "Вытолкните"), ("Pull", "Тяните"), ("Squeeze", "Сожмите"),
        ("Contract", "Напрягите"), ("Engage", "Напрягите"), ("Rotate", "Поверните"),
        ("Twist", "Скрутите"), ("Step", "Шаг"), ("Jump", "Прыжок"), ("Swing", "Мах"),
        ("Press", "Выжмите"), ("Curl", "Сгибание"), ("Row", "Тяга"), ("Squat", "Присед"),
        ("Lunge", "Выпад"), ("Kick", "Удар"), ("Reach", "Потянитесь"), ("Lean", "Наклон"),
        ("Hinge", "Наклон"), ("Pivot", "Поворот"), ("Shift", "Перемещение"), ("Bring", "Подведите"),
        ("Move", "Переместите"), ("Turn", "Поверните"), ("Face", "Лицом"), ("Point", "Направьте"),
        ("Align", "Выровняйте"), ("Brace", "Стабилизируйте"), ("Tuck", "Подтяните"),
        ("Arch", "Прогните"), ("Round", "Округлите"), ("Flare", "Разведите"),
        ("Drive", "Направьте"), ("Descend", "Опуститесь"), ("Ascend", "Поднимитесь"),
        ("standing", "стоя"), ("stand", "встаньте"), ("sitting", "сидя"), ("sit", "сядьте"),
        ("lying", "лёжа"), ("lie", "лягте"), ("holding", "держа"), ("hold", "держите"),
        ("grip", "хват"), ("place", "поместите"), ("position", "расположение"),
        ("bend", "согните"), ("bending", "сгибая"), ("extend", "разогните"), ("extending", "разгибая"),
        ("lift", "поднимите"), ("lifting", "поднимая"), ("lower", "опустите"), ("lowering", "опуская"),
        ("raise", "поднимите"), ("raising", "поднимая"), ("push", "вытолкните"), ("pushing", "выталкивая"),
        ("pull", "тяните"), ("pulling", "тяня"), ("squeeze", "сожмите"), ("squeezing", "сжимая"),
        ("contract", "напрягите"), ("engaging", "напрягая"), ("engage", "напрягите"),
        ("rotate", "поверните"), ("rotating", "вращая"), ("twist", "скрутите"), ("twisting", "скручивая"),
        ("step", "шаг"), ("steps", "шаги"), ("jump", "прыжок"), ("jumping", "прыгая"),
        ("swing", "мах"), ("swinging", "махая"), ("press", "выжмите"), ("pressing", "выжимая"),
        ("curl", "сгибание"), ("curling", "сгибая"), ("row", "тяга"), ("rowing", "тяня"),
        ("squat", "присед"), ("squatting", "приседая"), ("lunge", "выпад"), ("lunging", "выпад"),
        ("kick", "удар"), ("kicking", "удар"), ("reach", "потянитесь"), ("reaching", "тянясь"),
        ("lean", "наклон"), ("leaning", "наклоняясь"), ("hinge", "наклон"), ("hinging", "наклон"),
        ("pivot", "поворот"), ("pivoting", "поворачивая"), ("shift", "перемещение"), ("shifting", "перемещая"),
        ("bring", "подведите"), ("bringing", "подводя"), ("move", "переместите"), ("moving", "перемещая"),
        ("turn", "поверните"), ("turning", "поворачивая"), ("face", "лицом"), ("facing", "лицом"),
        ("point", "направьте"), ("pointing", "направляя"), ("align", "выровняйте"), ("aligning", "выравнивая"),
        ("brace", "стабилизируйте"), ("bracing", "стабилизируя"), ("tuck", "подтяните"), ("tucking", "подтягивая"),
        ("arch", "прогните"), ("arching", "прогибая"), ("round", "округлите"), ("rounding", "округляя"),
        ("flare", "разведите"), ("flaring", "разводя"), ("drive", "направьте"), ("driving", "направляя"),
        ("descend", "опуститесь"), ("descending", "опускаясь"), ("ascend", "поднимитесь"), ("ascending", "поднимаясь"),
        ("band", "эспандер"), ("barbell", "штанга"), ("dumbbell", "гантель"), ("dumbbells", "гантели"),
        ("kettlebell", "гиря"), ("kettlebells", "гири"), ("cable", "трос"), ("cables", "тросы"),
        ("machine", "тренажёр"), ("bench", "скамья"), ("mat", "коврик"), ("ball", "мяч"),
        ("stability ball", "фитбол"), ("pull-up bar", "турник"), ("box", "бокс"), ("platform", "платформа"),
        ("step platform", "степ-платформа"), ("rope", "канат"), ("handles", "рукояти"), ("handle", "рукоять"),
        ("feet", "ступни"), ("foot", "ступня"), ("legs", "ноги"), ("leg", "нога"),
        ("knees", "колени"), ("knee", "колено"), ("thighs", "бёдра"), ("thigh", "бедро"),
        ("hips", "бёдра"), ("hip", "бедро"), ("back", "спина"), ("chest", "грудь"),
        ("shoulders", "плечи"), ("shoulder", "плечо"), ("arms", "руки"), ("arm", "рука"),
        ("elbows", "локти"), ("elbow", "локоть"), ("hands", "кисти"), ("hand", "кисть"),
        ("head", "голова"), ("neck", "шея"), ("core", "кор"), ("abs", "пресс"),
        ("glutes", "ягодицы"), ("glute", "ягодица"), ("calves", "икры"), ("calf", "икра"),
        ("ankles", "лодыжки"), ("ankle", "лодыжка"), ("wrists", "запястья"), ("wrist", "запястье"),
        ("forearms", "предплечья"), ("forearm", "предплечье"), ("upper body", "верхняя часть тела"),
        ("lower body", "нижняя часть тела"), ("torso", "корпус"), ("waist", "талия"),
        ("spine", "позвоночник"), ("traps", "трапеции"), ("lats", "широчайшие"), ("biceps", "бицепсы"),
        ("triceps", "трицепсы"), ("quads", "квадрицепсы"), ("hamstrings", "бицепсы бёдер"),
        ("pectorals", "грудные мышцы"), ("shoulder-width", "на-ширине-плеч"), ("hip-width", "на-ширине-бёдер"),
        ("straight", "прямыми"), ("relaxed", "расслабленными"), ("slightly", "слегка"),
        ("fully", "полностью"), ("completely", "полностью"), ("controlled", "контролируемым"),
        ("explosive", "взрывным"), ("smooth", "плавным"), ("steady", "ровным"), ("slowly", "медленно"),
        ("quickly", "быстро"), ("carefully", "осторожно"), ("firmly", "плотно"), ("gently", "мягко"),
        ("upward", "вверх"), ("downwards", "вниз"), ("downward", "вниз"), ("forward", "вперёд"),
        ("backwards", "назад"), ("backward", "назад"), ("sideways", "в-сторону"), ("together", "вместе"),
        ("apart", "врозь"), ("then", "затем"), ("next", "далее"), ("after", "после"),
        ("before", "перед"), ("while", "в-то-время-как"), ("when", "когда"), ("until", "до-тех-пор-пока"),
        ("by", "путём"), ("with", "с"), ("and", "и"), ("or", "или"), ("but", "но"),
        ("as", "как"), ("for", "для"), ("from", "от"), ("to", "к"), ("in", "в"),
        ("on", "на"), ("at", "у"), ("your", "ваши"), ("the", ""),
    ]
    
    for eng, rus in words:
        result = result.replace(eng, rus)
    
    # Очистка
    result = re.sub(r'\s+', ' ', result).strip()
    result = result.replace("  ", " ").replace(" .", ".").replace(" ,", ",")
    result = result.replace("- ", "-").replace(" -", "-")
    result = result.replace("на-ширине-плеч", "на ширине плеч").replace("на-ширине-бёдер", "на ширине бёдер")
    result = result.replace("в-сторону", "в сторону").replace("в-то-время-как", "в то время как")
    result = result.replace("до-тех-пор-пока", "до тех пор пока")
    
    return result

def main():
    with open('/workspace/backend/src/data/exercises.json', 'r', encoding='utf-8') as f:
        exercises = json.load(f)
    
    print(f"Всего упражнений: {len(exercises)}")
    print("Перевод первых 500 элементов...")
    
    translated = []
    for i, ex in enumerate(exercises[:500]):
        t_ex = ex.copy()
        if 'instructions' in ex:
            t_ex['instructions'] = [translate_instruction(instr) for instr in ex['instructions']]
        translated.append(t_ex)
        if (i + 1) % 100 == 0:
            print(f"Переведено {i + 1}")
    
    with open('/workspace/backend/src/data/exercises_part1.json', 'w', encoding='utf-8') as f:
        json.dump(translated, f, ensure_ascii=False, indent=2)
    
    print(f"\nГотово! Сохранено в exercises_part1.json")
    print(f"Переведено: {len(translated)}")
    
    # Примеры
    for idx in [0, 1, 5]:
        ex = translated[idx]
        print(f"\n{'='*60}")
        print(f"{ex['name']}:")
        for instr in ex['instructions'][:2]:
            print(f"  • {instr}")

if __name__ == '__main__':
    main()
