/*********************************************
 * OPL 22.1.0.0 Model
 * Author: sai06
 * Creation Date: 28 Oct 2022 at 11:13:14
 *********************************************/
using CPLEX;
float temp;

 
 
 tuple providers{
 
	key int k;       // index of VM_j
	int RS;         // security tag of cloud k
	int vmlimit;    //limited number of vms 
 }
 
 tuple VM_instance{
 
	key int j;       // index of VM_j
	float price;     // The price of runnig a VM of instance VM_j in dollar per hour. 
 	float perf;     // The performance of each core of VM_j in CCU metric
  	int core_num;      // The number of cores of VM_j
	float bw;         //the communication  Bandwidth of VM_j in GB per second
    float mem;      // Accessible memory size of VM_j for running jobs
    // int S;         // security tag of instance VM_j
 }
 
  
 /*tuple workflow{
 
 	int tasks;   // the number of tasks
	float deadline; // deadline of the workflow
  
 }*/
 
  
 tuple task{
 	key int id;         //index of task  i
 	int TS;            // task security 
 	int cardinality;      //Number of tasks for each bag
 	float Mem;             //minimum required ram for the bag
 	float IDS;             //required input data size for the bag
 	float ODS;             //required input data size for the bag
    float ET;        //required amount of computation for one job of Bi on a VM with 1 CCU   
  //  {int} pre;      // set of prcedeccor tasks of task i
 }
 
 tuple Dependency {
  int  t;
  int i;
 };
 //////////////////////////////////////////////////////////////////////
int n=...;                   // Number of tasks of workflow
range No_task=1..n;         //index of all tasks
range No_tasks_t1=2..n;       //index of all tasks_t1
range No_tasks_tn=1..n-1;      //index of all tasks_tn
 //////////////////////////////////////////////////////////////////////
 
float Dl=...;    // deadline of the workflow 
float bw_c=...;  // bandwidth between public and private clouds
float dtc=...;  // data transfer cost between public and private clouds

float upperbund=1;
//////////////////////////////////////////////////////////////////////

int cloud_no=...;          // Number of clouds  
range No_cloud=1..cloud_no;

 //////////////////////////////////////////////////////////////////////

int instance_no=...;          // Number of instances  
range No_instance=1..instance_no;

//////////////////////////////////////////////////////////////////////

int vm_no=...;          // Number of vms  
range No_vm=1..vm_no;

/////////////////////////////////////CLoud providers, VM instances, Tasks /////////////////////////////

providers CPs[No_cloud]=...;
VM_instance VM[No_cloud][No_instance]=...;
task workflow[No_task]=...;
{Dependency} D = ...; 



///*************************decision variables *************************

dvar boolean y[No_task][No_cloud][No_instance][No_vm]; 
dvar boolean z[No_task][No_cloud][No_instance];
dvar boolean x[No_task][No_cloud];

//dvar boolean sv[No_tasks_t1][No_cloud][No_instance][No_vm]; 
dvar boolean svd[No_tasks_t1][No_task][No_cloud][No_instance][No_vm]; 

//dvar boolean v[No_tasks_t1];
dvar boolean vd[No_tasks_t1][No_task];

//dvar boolean sc[No_tasks_t1][No_cloud];
dvar boolean scd[No_tasks_t1][No_task][No_cloud];

//dvar boolean c[No_tasks_t1];
dvar boolean cd[No_tasks_t1][No_task];

//dvar boolean teta[No_tasks_t1];
dvar boolean tetad[No_tasks_t1][No_task];

//dvar boolean tau[No_tasks_t1][No_cloud][No_instance]; 
dvar boolean taud[No_tasks_t1][No_task][No_cloud][No_instance]; 

//dvar float+ DTT[No_tasks_t1];
dvar float+ DTTd[No_tasks_t1][No_task];

dvar float+ ODT;
dvar float+ RT[No_task];      //RunTime of tasks
dvar float+ ST[No_task];       //startTime of tasks
dvar float+ M[No_task];         // Makespan of tasks     
dvar float+ makespan;            // Makespan of the workflow
dvar boolean landa[No_cloud][No_instance][No_vm];        
dvar float+ VS[No_cloud][No_instance][No_vm];
dvar float+ VF[No_cloud][No_instance][No_vm];
dvar int+ TP[No_cloud][No_instance][No_vm];
dvar float+ datatransfercost;




execute{
var before = new Date();
temp = before.getTime();
 
}

//*************************objective function *************************

 
/*dexpr float F=makespan;
 minimize F;*/
 
 
  /*dexpr float vmcost=  sum(k in No_cloud,j in No_instance, l in No_vm) TP[k][j][l]*VM[k][j].price;
  dexpr float vmcost=  sum(k in No_cloud,j in No_instance, l in No_vm) VF[k][j][l]*VM[k][j].price;
  
   dexpr float cost=vmcost+datacost;
   minimize cost;*/
  // dexpr float vmcost=  sum(k in No_cloud,j in No_instance, l in No_vm) landa[k][j][l]*VM[k][j].price;
  dexpr float vmcost=  sum(k in No_cloud,j in No_instance, l in No_vm)  TP[k][j][l]*VM[k][j].price;
  dexpr float datacost=sum(d in D) cd[d.i][d.t]*workflow[d.t].ODS*dtc+x[n][1]*workflow[n].ODS*dtc+x[1][1]*workflow[1].IDS*dtc;
 dexpr float cost=vmcost+datacost;
 minimize cost;
  
  
//*************************  constraints *************************


subject to{
  
  
  forall (d in D) 
   datatransfercost>=cd[d.i][d.t]*workflow[d.t].ODS*dtc+x[n][1]*workflow[n].ODS*dtc+x[1][1]*workflow[1].IDS*dtc;
    
  //********* constraint resource assignment: each task --> a vm ******************
  
    forall(i in No_task)
        sum(k in No_cloud,j in No_instance, l in No_vm)
               y[i][k][j][l]==1;
  
  
  //********* creating a dvar to know each task is assigned to which instance type******************
  
   /*
      forall(i in No_task,k in No_cloud,j in No_instance)
                sum(l in No_vm)  y[i][k][j][l]<=z[i][k][j]* workflow[i].cardinality;
 
  
   
      forall(i in No_task,k in No_cloud,j in No_instance)
              sum(l in No_vm)
                   y[i][k][j][l]>=z[i][k][j];*/
                   
     //*************  Minimum required Ram ***************************              
     //  forall(i in No_task,k in No_cloud,j in No_instance)
       //       z[i][k][j]*workflow[i].Mem <=VM[k][j].mem;          
                   
    forall(i in No_task,k in No_cloud,j in No_instance)           
          sum(l in No_vm) y[i][k][j][l]*workflow[i].Mem <= VM[k][j].mem;     
       
  
  //********* creating a dvar to know each task is assigned to which cloud ******************
  
/*
      forall(i in No_task,k in No_cloud)
                  sum(j in No_instance)
                       z[i][k][j]<=x[i][k]* workflow[i].cardinality;
 
  
   
      forall(i in No_task,k in No_cloud,j in No_instance)
               sum(j in No_instance)
                  z[i][k][j]>=x[i][k];
                 */
  
  //*************  Security requirement ***************************
    
   forall(i in No_task,k in No_cloud)
              sum(l in No_vm,j in No_instance) y[i][k][j][l] *CPs[k].RS <=workflow[i].TS;
                 
               
  //********* creating a dvar to know which resources of private cloud are used ******************
  
   /*
        forall(k in No_cloud,j in No_instance,l in No_vm)
                  sum(i in No_task)
                     y[i][k][j][l]<=landa[k][j][l]* n;
 
  
  
     forall(k in No_cloud)
           forall(j in No_instance)
              forall(l in No_vm)
                 sum(i in No_task)
                     y[i][k][j][l]>=landa[k][j][l];
                     
        forall(k in No_cloud)
         sum(j in No_instance)
              sum(l in No_vm)
                landa[k][j][l]<=CPs[k].vmlimit;
                
 */
  
  //*************  limited capacity of###private cloud k=2### ### public cloud k=1####  ************** 
  
  
      
                
                
                
                 /*    
        forall(i in No_tasks_t1,k in No_cloud,j in No_instance,l in No_vm){
                      v[i]>=y[i-1][k][j][l]-y[i][k][j][l];
       }         
  
      forall(i in No_tasks_t1,k in No_cloud,j in No_instance,l in No_vm)
                         v[i]>=y[i][k][j][l]-y[i-1][k][j][l];
      
        
        forall(i in No_tasks_t1, k in No_cloud)
                 c[i]>=x[i-1][k]-x[i][k];
      
        forall(i in No_tasks_t1, k in No_cloud)
             c[i]>=x[i][k]-x[i-1][k];
      
     
       forall(i in No_tasks_t1)
          teta[i]==v[i]-c[i];
     */      
               
   //********* creating a dvar to know whether task i and its previous tasks are on the same VM ******************
      /*          forall(i in No_tasks_t1,k in No_cloud,j in No_instance,l in No_vm){
                      sv[i][k][j][l]>=y[i-1][k][j][l]+y[i][k][j][l]-1;
                 }
                 
                 forall(i in No_tasks_t1,k in No_cloud,j in No_instance,l in No_vm){
                      sv[i][k][j][l]<=(y[i-1][k][j][l]+y[i][k][j][l])/2;
                 }   
                 
                  forall(i in No_tasks_t1)
                     v[i]==1-sum(k in No_cloud,j in No_instance,l in No_vm) sv[i][k][j][l];
      
      
        */           
//********* creating a dvar to know whether task i and its previous tasks are on the same VM ***********                
                  forall(d  in D,k in No_cloud,j in No_instance,l in No_vm){
                      svd[d.i][d.t][k][j][l]>=y[d.i][k][j][l]+y[d.t][k][j][l]-1;
                 }
                 
                 forall(d  in D,k in No_cloud,j in No_instance,l in No_vm){
                       svd[d.i][d.t][k][j][l]<=(y[d.i][k][j][l]+y[d.t][k][j][l])/2;
                 }   
                 
                  forall(d  in D)
                     vd[d.i][d.t]==1-sum(k in No_cloud,j in No_instance,l in No_vm) svd[d.i][d.t][k][j][l];
                             
      
 //********* creating a dvar to know whether task i and its previous tasks are on the same cloud ******************
  /*   
     forall(i in No_tasks_t1, k in No_cloud)
                 sc[i][k]>=x[i-1][k]+x[i][k]-1;
     
     forall(i in No_tasks_t1, k in No_cloud)
                 sc[i][k]<=(x[i-1][k]+x[i][k])/2;
     
      forall(i in No_tasks_t1)
            c[i]==1-sum(k in No_cloud)sc[i][k];
  */          
            
 //********* creating a dvar to know whether task i and its previous tasks are on the same cloud ******************
     
     forall(d in D, k in No_cloud)
                // scd[d.i][d.t][k]>=x[d.i][k]+x[d.t][k]-1;
                  scd[d.i][d.t][k]>= sum(l in No_vm,j in No_instance) y[d.i][k][j][l]+ sum(l in No_vm,j in No_instance) y[d.t][k][j][l]-1; 
     forall(d in D, k in No_cloud)
                 // scd[d.i][d.t][k]<=(x[d.i][k]+x[d.t][k])/2;
                 scd[d.i][d.t][k]<=(sum(l in No_vm,j in No_instance) y[d.i][k][j][l]+sum(l in No_vm,j in No_instance) y[d.t][k][j][l])/2;
      forall(d in D)
            cd[d.i][d.t]==1-sum(k in No_cloud) scd[d.i][d.t][k];
            
            
   //********* creating a dvar to calculate coefficient for data transfer time ***************************
 
     /*     forall(i in No_tasks_t1)
          teta[i]==v[i]-c[i];
     */     
        
        
        forall(d in D)
          tetad[d.i][d.t]==vd[d.i][d.t]-cd[d.i][d.t];
       
    /*   forall(i in No_tasks_t1)
          forall(k in No_cloud)
              forall(j in No_instance)
                tau[i][k][j]>=(teta[i]+z[i-1][k][j])-1;
                
      forall(i in No_tasks_t1)
          forall(k in No_cloud)
              forall(j in No_instance)
                tau[i][k][j]<=(teta[i]+z[i-1][k][j])/2;
       */       
             
          forall(d in D)
          forall(k in No_cloud)
              forall(j in No_instance)
              //  taud[d.i][d.t][k][j]>=(tetad[d.i][d.t]+z[d.t][k][j])-1;
                 taud[d.i][d.t][k][j]>=(tetad[d.i][d.t]+sum(l in No_vm) y[d.i][k][j][l])-1;
                
      forall(d in D)
          forall(k in No_cloud)
              forall(j in No_instance)
                   //taud[d.i][d.t][k][j]<=(tetad[d.i][d.t]+z[d.t][k][j])/2;
                   taud[d.i][d.t][k][j]<=(tetad[d.i][d.t]+sum(l in No_vm) y[d.i][k][j][l])/2;
                          
  //************************************ data transfer time *********************************************
             
      /*    forall(i in No_tasks_t1)
            forall(k in No_cloud)
              forall(j in No_instance)
                DTT[i]>= (tau[i][k][j]*(workflow[i-1].ODS/VM[k][j].bw))+(c[i]*(workflow[i-1].ODS/bw_c));
        */         
       
     /*  forall(d in D)
            forall(k in No_cloud)
              forall(j in No_instance)
                DTTd[d.i][d.t]>= (taud[d.i][d.t][k][j]*(workflow[d.t].ODS/VM[k][j].bw))+(cd[d.i][d.t]*(workflow[d.t].ODS/bw_c));
                
     */         
       
       
              
//************************************ task Run time *********************************************
             
          forall(i in No_task)
            forall(k in No_cloud)
              forall(j in No_instance)
               // forall(l in No_vm)
                 // RT[i] >= z[i][k][j]* workflow[i].ET/(VM[k][j].perf*minl(VM[k][j].core_num,workflow[i].cardinality));
                   RT[i] >=  sum(l in No_vm) y[i][k][j][l]* workflow[i].ET/(VM[k][j].perf*minl(VM[k][j].core_num,workflow[i].cardinality));                                               
                
                
                    
//************************************ data dependency *********************************************
           
           ST[1]==0; 
  
           
          /*    forall(i in No_tasks_t1)
                ST[i]>=ST[i-1]+RT[i-1]+DTT[i];     */
                
                
        forall(d in D)
            forall(k in No_cloud)
              forall(j in No_instance)
                ST[d.i]>=ST[d.t]+RT[d.t]+(taud[d.i][d.t][k][j]*(workflow[d.t].ODS/VM[k][j].bw))+(cd[d.i][d.t]*(workflow[d.t].ODS/bw_c));
                
             
//************************************ makespan *********************************************
             
             forall(i in No_task)
                  M[i]==ST[i]+RT[i]; 
            
                forall(k in No_cloud)
                   forall(j in No_instance)
                      //   ODT>=z[n][k][j]*workflow[n].ODS/VM[k][j].bw; 
                          ODT>=sum(l in No_vm) y[n][k][j][l]*workflow[n].ODS/VM[k][j].bw;   
             
                makespan==M[n]+ODT;              
                 
                 makespan<=Dl;
 //************************************ tempror objective function *********************************************
         
       forall(i in No_task)
             forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          VS[k][j][l]<=Dl*y[i][k][j][l];   
    
  
           forall(i in No_task)
             forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          VS[k][j][l]<=ST[i]+Dl*(1-y[i][k][j][l]);
                          
                          
       /*   forall(i in No_task)
             forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          VS[k][j][l]<=ST[i]; 
                          
                      
                */                
                
                          
        forall(i in No_task)
             forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          VF[k][j][l]>=M[i]+Dl*(y[i][k][j][l]-1);  
                          
                          
           forall(i in No_task)
             forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          VF[k][j][l]<=Dl*y[i][k][j][l];      
                          
                         
      forall(k in No_cloud)
                   forall(j in No_instance)  
                       forall(l in No_vm)
                          TP[k][j][l]>=VF[k][j][l]-VS[k][j][l];                 
                                         
} 

           
execute{
	var after = new Date();
	writeln("solving time in milliseconds ~= ",after.getTime()-temp);
	//The getTime function returns the number of milliseconds since 00:00:00 UTC, January 1, 1970.
	
	
    writeln("**************************************:  "+ cplex.getBestObjValue());  
    //writeln(" time of executing: "+cplex.getCplexTime()); 
    writeln("NbinVars:  "+cplex.getNbinVars());
    writeln("time stamp: "+cplex.getDetTime());
    writeln("no columns: "+cplex.getNcols()); 
    writeln("no rows: "+cplex.getNrows());
    writeln("NintVars: "+cplex.getNintVars());
    writeln("NMIPStarts: "+cplex.getNMIPStarts());
  //   writeln("solve time: "+cplex.getSolvedTime()); 
  //  writeln("getMIPStartName(0): "+cplex.getMIPStartIndex("m1")); 
    writeln("is MIP: "+ cplex.isMIP()); 
     
	
}

 
