import time
import hashlib
from multiprocessing import Pool

def create_hash(text):
    return hashlib.sha256(text.encode()).hexdigest()

if __name__ == "__main__":
    data = [f"tekst_{i}" for i in range(500_000)]

    start = time.perf_counter()

    with Pool() as pool:
        hashes = pool.map(create_hash, data)

    end = time.perf_counter()

    print("Broj hash vrijednosti:", len(hashes))
    print("Paralelno vrijeme:", end - start)