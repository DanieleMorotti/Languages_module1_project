#from minizinc import Instance, Model, Solver
import pymzn
import sys, time



def execute_model(choice, test_name):
    print("\nComputing the solution ... \n")
    start_time = time.time() 
    if choice == 'd':
        solution = pymzn.minizinc("./nurikabe_single.mzn", f"./tests/single/{test_name}.dzn", output_mode="dzn", two_pass=0) # data={} to add data manually
        end_time = time.time() 
        print("The solution is: ", solution, f"\nand it has been found in {end_time-start_time}.") 
    else:
        input_raw = dzn2dict(f"./tests/multi/{test_name}.dzn")
        input_encoded = encode_input(input_raw)
        solution = pymzn.minizinc("./nurikabe_multi.mzn", f"./tests/multi/{test_name}.dzn", data={"init":input_encoded}, output_mode="dzn", two_pass=0) # data={} to add data manually
        end_time = time.time() 
        print("The solution is: ", solution, f"\nand it has been found in {end_time-start_time}.") 
    

def main():
    try:
        test_name = sys.argv[1]
    except IndexError:
        print("ERROR: You must enter the name of the test you want to run.")
        sys.exit(1)
    # TODO: se rimane tempo aggiungiamo delle flag da linea di comando con cui si può lanciare il file con isole diverse o uguali e ottimizzare con "cells"
    allowed_choice = ['d', 'e']
    while (choice := input("Insert the type of the test, d (different) or e (equal): ")) not in allowed_choice:
        print("WARNING: You have not entered a valid option.")
        
    execute_model(choice, test_name)
   
if __name__ == "__main__":
   main()
    
