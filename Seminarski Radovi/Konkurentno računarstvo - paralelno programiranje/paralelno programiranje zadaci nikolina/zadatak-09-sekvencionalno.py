import time
import hashlib

def make_hash(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()

values = [f"korisnik_{i}" for i in range(400_000)]

start = time.perf_counter()
hashes = [make_hash(value) for value in values]
end = time.perf_counter()

print("Broj hash vrijednosti:", len(hashes))
print("Sekvencijalno vrijeme:", end - start)
