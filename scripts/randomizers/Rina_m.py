import random
import subprocess


def generate_measurements():
    original_thk = float(input("Original thickness: "))
    items = int(input("Number of items: "))

    # Type selection (lowercase works automatically)
    while True:
        choice = input("Type (W=Web 25% / F=Flange 20%): ").strip().upper()

        if choice in ["W", "1"]:
            allowed_percent = 25
            break
        elif choice in ["F", "2"]:
            allowed_percent = 20
            break
        else:
            print("Enter W or F")

    for item in range(1, items + 1):

        while True:
            points = int(input(f"\nHow many points for item {item}?: "))
            if points >= 1:
                break
            print("Enter at least 1 point")

        output_lines = []

        for point in range(1, points + 1):
            port = round(random.uniform(original_thk - 0.3, original_thk), 1)
            starboard = round(random.uniform(original_thk - 0.3, original_thk), 1)

            row = f"{point}\t{allowed_percent}\t{port:.1f}\t{starboard:.1f}"
            output_lines.append(row)

        final_output = "\n".join(output_lines)

        subprocess.run("clip", input=final_output.encode("utf-16le"), shell=True)

        print(f"\nOK: Item {item} copied.")
        input("Press ENTER to continue to next item...")

    print("\nAll items completed.")


generate_measurements()

# python Desktop\scripts\Rina_m.py
