import time
import hashlib

def create_hash(text):
    return hashlib.sha256(text.encode()).hexdigest()

data = [f"tekst_{i}" for i in range(500_000)]

start = time.perf_counter()

hashes = [create_hash(text) for text in data]

end = time.perf_counter()

print("Broj hash vrijednosti:", len(hashes))
print("Sekvencijalno vrijeme:", end - start)