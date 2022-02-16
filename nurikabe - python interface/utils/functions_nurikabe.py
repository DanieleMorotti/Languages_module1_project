import pymzn
import time

# This function read the input from the desired test and encode it in a new matrix
def multi_puzzle(test_name: str) :
    input_data = pymzn.dzn2dict(f"./Tests/{test_name}.dzn")
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
    input_data = pymzn.dzn2dict(f"./Tests/{test_name}.dzn")
    input_data["digits_encoding"] = 1
    return input_data
          
# It adds the bound to optimize the search of the minizinc solver          
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

# Execute the model on the input_data and return the solution
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
    