from rapidfuzz import process, fuzz
from canon import CANON

def match_to_canon(input_name, threshold=60):  # turunin threshold
    original = input_name
    input_name = input_name.lower().strip()

    match, score, _ = process.extractOne(
        input_name,
        CANON,
        scorer=fuzz.partial_ratio    # <-- GANTI INI
    )

    print("FUZZY DEBUG:", original, "->", match, "| score:", score)

    if score >= threshold:
        return match

    return input_name
