import time
from concurrent.futures import ProcessPoolExecutor

def process_row(row):
    return [min(pixel + 30, 255) for pixel in row]

if __name__ == "__main__":
    image = [[i % 256 for i in range(1200)] for _ in range(1200)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        processed = list(executor.map(process_row, image))
    end = time.perf_counter()

    print("Dimenzije slike:", len(processed), "x", len(processed[0]))
    print("Paralelno vrijeme:", end - start)
