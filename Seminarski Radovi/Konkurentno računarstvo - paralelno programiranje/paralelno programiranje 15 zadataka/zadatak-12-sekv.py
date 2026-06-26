import time
import math

numbers = [50_000, 51_000, 52_000, 53_000]

start = time.perf_counter()

results = [math.factorial(n) for n in numbers]

end = time.perf_counter()

print("Broj izračunatih faktorijela:", len(results))
print("Sekvencijalno vrijeme:", end - start)