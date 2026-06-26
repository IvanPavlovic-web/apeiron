import time
from concurrent.futures import ProcessPoolExecutor

def to_upper(text):
    return text.upper()

if __name__ == "__main__":
    texts = [f"tekstualni podatak broj {i}" for i in range(1_000_000)]

    start = time.perf_counter()

    with ProcessPoolExecutor() as executor:
        upper_texts = list(executor.map(to_upper, texts, chunksize=1000))

    end = time.perf_counter()

    print("Broj elemenata:", len(upper_texts))
    print("Paralelno vrijeme:", end - start)