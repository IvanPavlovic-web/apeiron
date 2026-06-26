import time
from concurrent.futures import ProcessPoolExecutor

def sum_row(row):
    return sum(row)

if __name__ == "__main__":
    matrix = [[i for i in range(1000)] for _ in range(3000)]

    start = time.perf_counter()
    with ProcessPoolExecutor() as executor:
        row_sums = list(executor.map(sum_row, matrix))
    end = time.perf_counter()

    print("Broj redova:", len(row_sums))
    print("Paralelno vrijeme:", end - start)
