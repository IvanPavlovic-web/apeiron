import time
from concurrent.futures import ProcessPoolExecutor

def word_count(text):
    return len(text.split())

if __name__ == "__main__":
    texts = [
        "Programiranje u Pythonu je korisno. " * 300_000,
        "Paralelizam ubrzava nezavisne zadatke. " * 300_000,
        "Sekvencijalni kod se izvrsava redom. " * 300_000
    ]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        counts = list(executor.map(word_count, texts))
    end = time.perf_counter()

    print("Ukupno rijeci:", sum(counts))
    print("Paralelno vrijeme:", end - start)
