#from minizinc import Instance, Model, Solver
import argparse
import pymzn
import time, math


def multi_puzzle(test_name: str) :
    input_data = pymzn.dzn2dict(f"./tests/multi/{test_name}.dzn")
    init : list = input_data["init"]
    cells_found = {}
    
    for i in range(0, len(init)):
        for j in range(0, len(init[i])):
            val = init[i][j]
            if val > 0:
                inc = 1
                if val in cells_found:
                    cells_found[val] = inc + 1
                    inc = cells_found[val]
                else:
                    cells_found[val] = 1
                init[i][j] = val * 10 + inc

    input_data["digits_encoding"] = 2
    return input_data

def single_puzzle(test_name: str) :
    input_data = pymzn.dzn2dict(f"./tests/single/{test_name}.dzn")
    input_data["digits_encoding"] = 1
    return input_data
                
def optimize_bound(input_data: dict):      
    bound = set()
    init : list = input_data["init"]
    
    for row in init:
        for val in row:
            bound.add(val)

    input_data["cells"] = bound
    return input_data


def default_bound(input_data: dict):
    max_value = max([max(row) for row in input_data["init"]])
    bound = 10 if max_value <= 9 else 100

    input_data["cells"] = set(range(0, bound))
    return input_data

def execute_model(input_data: dict):
    print("\nComputing the solution ... \n")
    start_time = time.time() 
    output = pymzn.minizinc("./nurikabe_python.mzn", data=input_data, output_mode="dict", output_vars=["solution"], two_pass=0)
    end_time = time.time() 

    print("The solution is:")
    try:
        for sol in output[0].values():
            for row in sol:
                for val in row:
                    pow_digit = pow(10, input_data["digits_encoding"] - 1)
                    print(val // pow_digit, end="   ")
                print("\n")
    except IndexError:
        print(output)
    print(f"and it has been found in {end_time-start_time}.")
    

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('testname', metavar='FILE', type=str,
                    help='Name of .dzn file to test')
    parser.add_argument('--o', dest='optimize', action='store_const',
                    const=optimize_bound, default=default_bound,
                    help='Optimize the search by adding a specific bound to the solution')
    parser.add_argument('--m', dest='multi', action='store_const',
                    const=multi_puzzle, default=single_puzzle,
                    help='Editing the starting map to solve the puzzle with islands of same size')
    args = parser.parse_args()
    data_input = args.optimize(args.multi(args.testname))
    execute_model(data_input)
    # try:
    #     test_name = sys.argv[1]
    # except IndexError:
    #     print("ERROR: You must enter the name of the test you want to run.")
    #     sys.exit(1)
    # # TODO: se rimane tempo aggiungiamo delle flag da linea di comando con cui si può lanciare il file con isole diverse o uguali e ottimizzare con "cells"
    # allowed_choice = ['d', 'e']
    # while (choice := input("Insert the type of the test, d (different) or e (equal): ")) not in allowed_choice:
    #     print("WARNING: You have not entered a valid option.")
        
   
if __name__ == "__main__":
   main()
    
