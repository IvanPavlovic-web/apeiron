import time
import random

def simulate(points):
    inside = 0
    for _ in range(points):
        x = random.random()
        y = random.random()
        if x * x + y * y <= 1:
            inside += 1
    return inside

points = 2_500_000

start = time.perf_counter()
inside = simulate(points)
pi_estimate = 4 * inside / points
end = time.perf_counter()

print("Procjena broja pi:", pi_estimate)
print("Sekvencijalno vrijeme:", end - start)
