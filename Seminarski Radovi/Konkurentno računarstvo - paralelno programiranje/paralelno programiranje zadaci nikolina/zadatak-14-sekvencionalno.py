import time
import random

arrays = [
    [random.randint(1, 1_000_000) for _ in range(150_000)]
    for _ in range(6)
]

start = time.perf_counter()
sorted_arrays = [sorted(array) for array in arrays]
end = time.perf_counter()

print("Broj sortiranih nizova:", len(sorted_arrays))
print("Sekvencijalno vrijeme:", end - start)
