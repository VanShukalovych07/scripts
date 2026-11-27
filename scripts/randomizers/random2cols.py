import random

input_data = """

15
18
18
18
14.5
14.5
14.5
14.5
14.5
14.5
14.5
18
22
20



""".strip().splitlines()

numbers = [float(x) for x in input_data]

col1 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]
col2 = [round(random.uniform(num - 0.3, num), 1) for num in numbers]

print("\nPortside")
for n in col1:
    print(n)

print("\nStarboard")
for n in col2:
    print(n)

# python Desktop\Scripts\random2cols.py

