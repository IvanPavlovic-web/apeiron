import time

def count_words(text):
    return len(text.split())

texts = [
    "Python je programski jezik. " * 500_000,
    "Paralelno programiranje koristi vise procesa. " * 500_000,
    "Sekvencijalni program radi korak po korak. " * 500_000
]

start = time.perf_counter()

results = [count_words(text) for text in texts]

end = time.perf_counter()

print("Ukupno riječi:", sum(results))
print("Sekvencijalno vrijeme:", end - start)
