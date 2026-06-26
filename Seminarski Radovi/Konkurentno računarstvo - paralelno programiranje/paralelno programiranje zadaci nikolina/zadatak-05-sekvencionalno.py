import time

texts = [
    "Programiranje u Pythonu je korisno. " * 300_000,
    "Paralelizam ubrzava nezavisne zadatke. " * 300_000,
    "Sekvencijalni kod se izvrsava redom. " * 300_000
]

def word_count(text):
    return len(text.split())

start = time.perf_counter()
counts = [word_count(text) for text in texts]
end = time.perf_counter()

print("Ukupno rijeci:", sum(counts))
print("Sekvencijalno vrijeme:", end - start)
