import time
import random

lists = [
    [random.randint(1, 1_000_000) for _ in range(100_000)]
    for _ in range(8)
]

start = time.perf_counter()

sorted_lists = [sorted(lst) for lst in lists]

end = time.perf_counter()

print("Broj sortiranih lista:", len(sorted_lists))
print("Sekvencijalno vrijeme:", end - start)
