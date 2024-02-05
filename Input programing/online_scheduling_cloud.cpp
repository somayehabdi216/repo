#include<iostream>
#include<fstream>
#include <string>

using namespace std;
  

const int n=4;  // the number of tasks of workflow 
int D[n][n]={{0, 5,7,0} ,{0 ,0,6,0},{0,0,0,5},{0,0,0,0}};  // data dependeny matrix 


///////***************************************************************************

const int cloud_no=2;       // the number of clouds
const int instance_no=4;       // the number of instances
const int vm_no=2;       // the number of vms


///////***************************************************************************

float Dl=1;    // deadline of the workflow 
float bw_c=.2;  // bandwidth between public and private clouds
float dtc=.5;  // data transfer cost between public and private clouds



///////***************************************************************************

//////////////////////tasks attribute///////////

/*tuple task{
 	key int i;         //index of task  i
 	int TS;            // task security 
 	int cardinality;      //Number of tasks for each bag
 	float Mem;             //minimum required ram for the bag
 	float IDS;             //required input data size for the bag
 	float ODS;             //required input data size for the bag
    float ET;        //required amount of computation for one job of Bi on a VM with 1 CCU   
    {int} pre;      // set of prcedeccor tasks of task i
 }*/
int TS[n]={1,2,2,1};            // security tag of  tasks    private=1  public=2 
int cardinality[n]={1,4,4,1};   // number of tasks in each Bag(i)
float Mem[n]={1,1,1,1};         //    required ram for each task in Bag(i) 
float IDS[n]= {0,10,20,20};     //    required Input Data Size for each task in Bag(i) in MB unite
float ODS[n]= {10,20,20,0};     //    Output Data Size for each task in Bag(i) in MB unite
float ET[n]={1,3,4,6};          //the Execution time  of each task of Bag(i) in hour on a Vm with 1 ccu
// function "dependency" return a set of predeccor tasks of task j 


 
///////////////////// Public  provider, private provider ///////////////////// 
int RS[cloud_no]={2,1}; 
int vmlimit[cloud_no]={20,2}; 



/////////////////////    //amazon(AWS)[EU west] ////GoGrid (CA,US)       //  voxel(NY,US)     //soflayer(DC,Us)

 float perf[cloud_no][instance_no]={{15.19,8.55,6.79,3.43},{23.2,9.28,4.87,4.42}}; //,{10.15,6.12,5.33,4.67},{14.07,12.3,6.49,5.52}};
 float price[cloud_no][instance_no]={{1.34,.76,.57,.19},{1.52,.76,.38,.19}}; //,{.727,.421,.211,.106},{0.5,.76,.25,.15}};
 float mem[cloud_no][instance_no]={{34.2,7.1,17.1,1.7},{8,4,2,1}}; //,{14,8,4,2},{8,4,2,1}};
 int core_num[cloud_no][instance_no]={{3,2,1,6},{8,4,2,1}}; 
 float bw[cloud_no][instance_no]={{34.2,7.1,17.1,1.7},{8,4,2,1}};
 
 
 

/////////////////////    This function indicates the predeccer tasks of task j /////////////////////


void dependency ( int j )
{   	int count;
	    cout<< endl<<'{';
   	    count=0;
	  for(int i=0; i<n;i++)
	        if(D[i][j]>0){
	          if(count>0) 	
              cout<<", "<<i+1;
              else 
              cout<<i+1;
            count++;
            }
          
    cout<<"}";

}

/////////////////////    This function indicates the predeccer tasks of task j /////////////////////
string dependency1 ( int j )
{   	string s="{";
        string f;
        int count;
	    //cout<< endl<<'{';
   	    count=0;
	  for(int i=0; i<n;i++)
	        if(D[i][j]>0){
	            f=std::to_string(i+1);
	          if(count>0) 	
              {  s.append(", ");
                 s.append(f);
              }  
              else 
              s.append(f);
            count++;
           }
          
    s.append("}");
    return s;

}

	//////This function write input data for the MLIP model into a  .dat file
	
void print(){
	
	//*************display nodes and workflow information for cplex************
	ofstream fout("model.dat");
	fout<<"\n\n\n";
	fout<<"n="<<n<<";        // No of tasks \n";                
	fout<<"cloud_no="<<cloud_no<<";          // No of cloud providers   \n";
	fout<<"instance_no="<<instance_no<<";          // No of instance types   \n";
	fout<<"vm_no="<<vm_no<<";          // No of vms   \n";
	fout<<"Dl="<<Dl<<";          // deadline of the workflow   \n";
	fout<<"bw_c="<<bw_c<<";          // bw between public and private cloud  \n";
    fout<<"dtc="<<dtc<<";          // data transfer cost between public and private cloud  \n";

//////////////////////////////////////////////////////////////////////////////////////////////////

/*tuple task{
 	key int i;         //index of task  i
 	int TS;            // task security 
 	int cardinality;      //Number of tasks for each bag
 	float Mem;             //minimum required ram for the bag
 	float IDS;             //required input data size for the bag
 	float ODS;             //required input data size for the bag
    float ET;        //required amount of computation for one job of Bi on a VM with 1 CCU   
    {int} pre;      // set of prcedeccor tasks of task i
 }*/

///////////////////////////////////////////////////////////////////
 fout<<"/////////////////////////////////////////////// \n ";
fout<<"// workflow[<i,TS, cardinality,Mem,IDs,ODS, ET, {int} pre>]\n\n";
	     int task_id=1;
		
		 fout<<"workflow=[\n";
		 	  
				  for(int i=0; i<n; i++)
			    {
					fout<<" < "<<(i+1)<<", ";

					//fout<<TS[i]<<","<<cardinality[i]<<","<< Mem[i]<<","<<IDS[i]<<","<<ODS[i]<<","<<ET[i]<<">\n";
					fout<<TS[i]<<","<<cardinality[i]<<","<< Mem[i]<<","<<IDS[i]<<","<<ODS[i]<<","<<ET[i]<<","<<dependency1(i)<<">\n";
				}
		 
	  fout<<"];\n\n ";	
	  
/////////////////////////////////////////////////

/*tuple VM_instance{
 
	key int j;       // index of VM_j
	float price;     // The price of runnig a VM of instance VM_j in dollar per hour. 
 	float perf;     // The performance of each core of VM_j in CCU metric
 	float mem;      // Accessible memory size of VM_j for running jobs
 	int core_num;      // The number of cores of VM_j
	float bw;         //the communication  Bandwidth of VM_j in GB per second
    // int S;         // security tag of instance VM_j
 }*/
 
 fout<<"/////////////////////////////////////////////// \n ";	  
fout<<"///////////////////////////////////////////////////\n";
 fout<<"//VM [< j, price ,perf, mem, core-num,bw>]\n\n";
		
		 fout<<"VM=[\n";
		 	   for(int k=0; k<cloud_no; k++)
		 	   {  
		 	       fout<<"[\n";  
				   for(int j=0; j<instance_no; j++)
			      {
					fout<<" < "<<(j+1)<<", ";

					fout<<price[k][j]<<","<<perf[k][j]<<","<<mem[k][j]<<","<<core_num[k][j]<<","<<bw[k][j]<<">\n";
				   }
				
				  fout<<"]\n"; 
		 	   }  
		 
	  fout<<"];\n\n ";	  

	fout<<"/////////////////////////////////////////////// \n ";	  
fout<<"///////////////////////////////////////////////////\n";
 fout<<"//CPs [< k, RS ,vmlimit>]\n\n";
		
		       fout<<"CPs=[\n";
		 	   for(int k=0; k<cloud_no; k++)
		 	     fout<<" < "<<(k+1)<<", "<<RS[k]<<", "<<vmlimit[k]<<">\n";
	           fout<<"]\n";  
	
}


int main(){
	
	print();
	return 0;
	
}