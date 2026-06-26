import time
import random

numbers = [random.randint(1, 100_000_000) for _ in range(5_000_000)]

start = time.perf_counter()
maximum = max(numbers)
end = time.perf_counter()

print("Maksimum:", maximum)
print("Sekvencijalno vrijeme:", end - start)
