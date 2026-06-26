import time
import hashlib
from concurrent.futures import ProcessPoolExecutor

def make_hash(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()

if __name__ == "__main__":
    values = [f"korisnik_{i}" for i in range(400_000)]

    start = time.perf_counter()

    with ProcessPoolExecutor() as executor:
        hashes = list(executor.map(make_hash, values, chunksize=1000))

    end = time.perf_counter()

    print("Broj hash vrijednosti:", len(hashes))
    print("Paralelno vrijeme:", end - start)