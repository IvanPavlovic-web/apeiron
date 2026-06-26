import time

image = [[i % 256 for i in range(1000)] for _ in range(1000)]

def process_pixel(pixel):
    return 255 - pixel

start = time.perf_counter()

processed = [
    [process_pixel(pixel) for pixel in row]
    for row in image
]

end = time.perf_counter()

print("Broj redova:", len(processed))
print("Sekvencijalno vrijeme:", end - start)