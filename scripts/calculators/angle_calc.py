def angle_weight(web, flange, tw, tf, length_m=1.0, correction=1.0126):
    
    area_mm2 = (web * tw) + (flange * tf) - (tw * tf)

    weight = area_mm2 * 0.00785 * correction

    return weight * length_m


if __name__ == "__main__":
    print("")
    web = float(input("WEB mm: "))
    flange = float(input("FLANGE mm: "))
    tw = float(input("WEB thickness: "))
    tf = float(input("FLANGE thickness: "))

    result = angle_weight(web, flange, tw, tf)

    print(f"\nWeight per meter: ~ {result:.3f} kg/m")

# python Desktop\scripts\angle_calc.py

