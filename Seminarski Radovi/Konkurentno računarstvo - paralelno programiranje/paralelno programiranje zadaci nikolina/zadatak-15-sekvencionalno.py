import time

image = [[i % 256 for i in range(1200)] for _ in range(1200)]

start = time.perf_counter()
processed = [
    [min(pixel + 30, 255) for pixel in row]
    for row in image
]
end = time.perf_counter()

print("Dimenzije slike:", len(processed), "x", len(processed[0]))
print("Sekvencijalno vrijeme:", end - start)
