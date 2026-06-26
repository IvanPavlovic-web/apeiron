import time
import math

def is_prime(n):
    if n < 2:
        return False

    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False

    return True

numbers = list(range(100_000, 120_000))

start = time.perf_counter()

results = [is_prime(n) for n in numbers]

end = time.perf_counter()

print("Broj prostih:", sum(results))
print("Sekvencijalno vrijeme:", end - start)
