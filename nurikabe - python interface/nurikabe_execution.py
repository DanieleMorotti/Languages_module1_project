#from minizinc import Instance, Model, Solver
import argparse
from utils import functions_nurikabe

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('testname', metavar='FILE', type=str,
                    help='Name of .dzn file to test')
    parser.add_argument('--o', dest='optimize', action='store_const',
                    const=functions_nurikabe.optimize_bound, default=functions_nurikabe.default_bound,
                    help='Optimize the search by adding a specific bound to the solution')
    parser.add_argument('--m', dest='multi', action='store_const',
                    const=functions_nurikabe.multi_puzzle, default=functions_nurikabe.single_puzzle,
                    help='Editing the starting map to solve the puzzle with islands of same size')
    args = parser.parse_args()
    data_input = args.optimize(args.multi(args.testname))
    functions_nurikabe.execute_model(data_input)

        
   
if __name__ == "__main__":
   main()
    
