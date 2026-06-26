import time
import random

def monte_carlo_pi(points):
    inside = 0

    for _ in range(points):
        x = random.random()
        y = random.random()

        if x * x + y * y <= 1:
            inside += 1

    return inside

points = 2_000_000

start = time.perf_counter()

inside = monte_carlo_pi(points)
pi = 4 * inside / points

end = time.perf_counter()

print("Približna vrijednost pi:", pi)
print("Sekvencijalno vrijeme:", end - start)