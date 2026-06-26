import time
import random

grades = [random.randint(5, 10) for _ in range(3_000_000)]

start = time.perf_counter()
passed = sum(1 for grade in grades if grade >= 6)
end = time.perf_counter()

print("Broj prolaznih ocjena:", passed)
print("Sekvencijalno vrijeme:", end - start)
