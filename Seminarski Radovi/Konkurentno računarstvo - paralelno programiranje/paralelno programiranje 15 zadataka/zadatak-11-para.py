import time
from multiprocessing import Pool

def multiply_row(args):
    row, B = args
    size = len(B)
    result_row = []

    for j in range(size):
        total = 0
        for k in range(size):
            total += row[k] * B[k][j]
        result_row.append(total)

    return result_row

if __name__ == "__main__":
    size = 200

    A = [[1 for _ in range(size)] for _ in range(size)]
    B = [[2 for _ in range(size)] for _ in range(size)]

    tasks = [(row, B) for row in A]

    start = time.perf_counter()

    with Pool() as pool:
        C = pool.map(multiply_row, tasks)

    end = time.perf_counter()

    print("Dimenzija rezultata:", len(C), "x", len(C[0]))
    print("Paralelno vrijeme:", end - start)