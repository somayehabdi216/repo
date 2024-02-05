# GitHub Repository

This is a GitHub repository for a mathematical programming model solved with the Cplex solver. The model optimises the cost of executing a workflow in a hybrid cloud while satisfying workflow requirements such as memory needed for tasks, security requirements, and data dependencies between tasks. 

The project contains input data for the model, the implemented model, and the configuration file with default settings. 

The input data includes information about a workflow and resources from cloud providers. We also provided a C++ program that prepares the input data for the complex solver. The input data is stored in a file with a ¨.dat¨ postfix.

 A file with the extension ¨*.mod¨ defines the decision variables, the objective function and the constraints. The input file and model file should be run with an appropriate run configuration to solve the model.
 
 After solving the model, the values of the decision variables are identified which indicate the scheduling solution. The output of the project is the value of the decision variables. In the model file, we have provided a post-processing stage and indicate the optimal assignments which will be shown in the scripting log tab in the view menu of cplex optimization studio.

 To run this project, it should be downloaded first. The CPLEX Optimization Studio must be installed. An OPL project  with the downloaded files should be created and then run the model.

