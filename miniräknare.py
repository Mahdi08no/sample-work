import os
os.system("cls") 

while True: 
    tal1 = float(input("Skriv ditt första tal: "))
    tal2 = float(input("Skriv ditt andra tal: "))

    räkne = input("Vilken vill du välja: +, -, * eller /: ")

    if räkne == "+": 
        svar = tal1 + tal2
    elif räkne == "-": 
        svar = tal1 - tal2
    elif räkne == "*":  
        svar = tal1 * tal2
    elif räkne == "/":  
        svar = tal1 / tal2
    else:
        svar = "Fel."
    print("Svar:", svar)

    igen = input("Vill du göra det igen? (ja/nej): ")
    if igen == "nej":  
        print("Hejdå!")
        break
