import time

matrix = [[i for i in range(1000)] for _ in range(3000)]

start = time.perf_counter()
row_sums = [sum(row) for row in matrix]
end = time.perf_counter()

print("Broj redova:", len(row_sums))
print("Sekvencijalno vrijeme:", end - start)
