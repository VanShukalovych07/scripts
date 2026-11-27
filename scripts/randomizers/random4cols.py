import random

input_data = """

18
18
18
18
18
18
18
18
18
18
18
18
18
18
18
22
22
22
32
32

""".strip().splitlines()

numbers = [float(x) for x in input_data]

col1 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]
col2 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]
col3 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]
col4 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]

print("\nPortside1")
for n in col1:
    print(n)

print("\nStarboard1")
for n in col2:
    print(n)

print("\nPortside2")
for n in col3:
    print(n)
print("\nStarboard2")
for n in col4:
    print(n)

# python Desktop\Scripts\random4cols.py
