import time
from multiprocessing import Pool

def process_row(row):
    return [255 - pixel for pixel in row]

if __name__ == "__main__":
    image = [[i % 256 for i in range(1000)] for _ in range(1000)]

    start = time.perf_counter()

    with Pool() as pool:
        processed = pool.map(process_row, image)

    end = time.perf_counter()

    print("Broj redova:", len(processed))
    print("Paralelno vrijeme:", end - start)