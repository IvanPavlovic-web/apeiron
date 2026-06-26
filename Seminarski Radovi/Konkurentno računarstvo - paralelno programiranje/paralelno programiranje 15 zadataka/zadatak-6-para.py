import time
from multiprocessing import Pool

def count_words(text):
    return len(text.split())

if __name__ == "__main__":
    texts = [
        "Python je programski jezik. " * 500_000,
        "Paralelno programiranje koristi vise procesa. " * 500_000,
        "Sekvencijalni program radi korak po korak. " * 500_000
    ]

    start = time.perf_counter()

    with Pool() as pool:
        results = pool.map(count_words, texts)

    end = time.perf_counter()

    print("Ukupno riječi:", sum(results))
    print("Paralelno vrijeme:", end - start)
