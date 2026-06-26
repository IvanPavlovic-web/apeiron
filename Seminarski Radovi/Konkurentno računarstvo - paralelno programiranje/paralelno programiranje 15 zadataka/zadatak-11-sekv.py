import time

size = 200

A = [[1 for _ in range(size)] for _ in range(size)]
B = [[2 for _ in range(size)] for _ in range(size)]

start = time.perf_counter()

C = [[0 for _ in range(size)] for _ in range(size)]

for i in range(size):
    for j in range(size):
        for k in range(size):
            C[i][j] += A[i][k] * B[k][j]

end = time.perf_counter()

print("Dimenzija rezultata:", len(C), "x", len(C[0]))
print("Sekvencijalno vrijeme:", end - start)