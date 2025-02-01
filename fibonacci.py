import os
os.system("cls") 

a = 1
b = 1
print(a) 
print(b) 

while b < 800000: 
    c = a + b
    print(c)
    a = b  
    b = c  
