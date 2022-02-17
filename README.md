# Project of Languages of Artificial Intelligence (Module 1)

## Bocconi Exercises and solutions
We have decided to solve the most interesting exercises of Bocconi's Mathematical Games. In particular we have done the exercises 2, 4, 7, 11, 12, 17 in [MiniZinc](https://www.minizinc.org/) and the exercises 4, 7, 17 in [Prolog](https://www.swi-prolog.org/) using the `clpdf` module.

You can find the exercises and the solutions at the following links:
- [List of the exercises](https://giochimatematici.unibocconi.it/images/autunno/2021/practiceq.pdf)
- [Solutions](https://giochimatematici.unibocconi.it/images/autunno/2021/practicea.pdf)

All the problems solved with MiniZinc can be executed on MiniZinc IDE or from command line after the installation of the MiniZinc distribution. The corresponding Prolog versions can be run in the browser visiting [SWISH](https://swish.swi-prolog.org/).

## Nurikabe
We have also implemented in MiniZinc our solution for the Nurikabe game, referring to the [Coding Games](https://www.codingame.com/training/expert/nurikabe) constraints.

We have two different implementations, the one with a further assumption (that each island must have a different size) can be found in the `Nurikabe` directory and it can be run on MiniZinc IDE on all the tests, for the other implementation we need to preprocess the input and then run the model, so we have written a python script that does all the work.

### Usage
This script is written in Python 3 and before to run it you need both to have a version of Python 3 installed and to install the dependencies included in `requirements.txt`.

We make available some flags to run the script both for the simplified and the original version of the problem. Assuming to be in the `nurikabe - python interface` directory the script can be executed with the command:
```bash
python TEST_NAME [--m] [--o]
```
TEST_NAME represents the name of a test inside the `Tests` directory (without the extension) and this is a mandatory argument. You need only this parameter if you want to execute the model on a test whose input matrix contains only different numbers.

The flag `--m` is used to run the script with a test in which the input matrix contains islands with the same size.

We have added a `--o` flag to optimize the solver, because using this we narrow the domain of the solution matrix such that we prune the search space.



### Warning
This implementation of Nurikabe runs indefinitely if the input matrix is larger than a 5x5 matrix.


## Contributors
Made by Morotti Daniele, Procino Edoardo, Valente Andrea
