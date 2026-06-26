import time
import math

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

numbers = range(200_000, 230_000)

start = time.perf_counter()
prime_flags = [is_prime(n) for n in numbers]
end = time.perf_counter()

print("Broj prostih:", sum(prime_flags))
print("Sekvencijalno vrijeme:", end - start)
