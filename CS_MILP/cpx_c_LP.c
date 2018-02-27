#include <ilcplex/cplex.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <sys/time.h>

#ifndef NULL
#define NULL 0
#endif

CPXENVptr env 	= NULL;
CPXLPptr  lp 	= NULL;
CPXNETptr net 	= NULL;

static void free_and_null (char **ptr);

int main (int argc, char **argv)
{
  int    status = 0;
  int    nzx 	= 0;
  int    solstat;
  double objval;
  double objbnd;
  // double gap_p;
  double *x		= NULL;
  double *pi 	= NULL;
  double *slack = NULL;
  double *dj 	= NULL;
  int    cur_numrows, cur_numcols;
  
  long begin;
  long end;
  long totaltime;
  
  if (argc < 2) 
    {
      fprintf(stderr, "Usage: <name> <filename> \n");
      goto TERMINATE;
    }
 
  int PRESOLVE;
  int HEURISTIC_FREQ;
  int MIP_CUTS;
  
   PRESOLVE = atoi(argv[2]);		/*  0: Off, 1: On */
   HEURISTIC_FREQ = atoi(argv[3]);	/* -1: Off, 0: Automatic */
   MIP_CUTS = atoi(argv[4]);		/* -1: Off, 0: Automatic, 1: Moderate, 2: Aggressive */ 


/* Initialize CPLEX */

  env = CPXopenCPLEX(&status);
 
  if (env == NULL)
  {
    char errmsg[1024];
    fprintf(stderr,"Could not open CPLEX enviroment. \n");
    goto TERMINATE;
  }

  status = CPXsetintparam (env, CPX_PARAM_SCRIND, CPX_ON);
  if ( status )
    {
      fprintf (stderr, "Failure to turn on screen indicator, status %d.\n", status);
      goto TERMINATE;
    }

/* Set integer parameters */

  status = CPXsetintparam (env, CPX_PARAM_PRELINEAR, 0);
  if (status) goto TERMINATE;

  status = CPXsetintparam (env, CPX_PARAM_MIPCBREDLP, CPX_OFF);
  if ( status )  goto TERMINATE;

  status = CPXsetintparam (env, CPX_PARAM_MIPINTERVAL, 1000);
  if (status) goto TERMINATE;

  status = CPXsetintparam (env, CPX_PARAM_THREADS, 1);
  if (status) goto TERMINATE;

  status = CPXsetintparam (env, CPX_PARAM_MIPSEARCH, 1);
  if (status) goto TERMINATE;
  
   status = CPXsetintparam (env, CPX_PARAM_PREIND, PRESOLVE);
   if (status) goto TERMINATE;
 
   status = CPXsetintparam (env, CPX_PARAM_HEURFREQ, HEURISTIC_FREQ);
   if (status) goto TERMINATE;
 
   status = CPXsetintparam (env, CPX_PARAM_CLIQUES		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_COVERS		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_DISJCUTS		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_FLOWCOVERS	, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_FLOWPATHS	, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_FRACCUTS		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_GUBCOVERS	, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_IMPLBD		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_MIRCUTS		, MIP_CUTS);
   status = CPXsetintparam (env, CPX_PARAM_ZEROHALFCUTS	, MIP_CUTS);
   if (status) goto TERMINATE; 

 
/* Set double parameters */

  status = CPXsetdblparam (env, CPX_PARAM_TILIM, 10800.0);
  if (status) goto TERMINATE;
 
/* Create the problem, using the filename as the problem name */
  
  lp = CPXcreateprob (env, &status, argv[1]);
  
  if ( lp == NULL )
    {
      fprintf (stderr, "Failed to create LP.\n");
      goto TERMINATE;
    }

/* Now read the file, and copy the data into the created lp */
    
  status = CPXreadcopyprob (env, lp, argv[1], NULL);
  if ( status )
  {
    fprintf (stderr, "Failed to read and copy the problem data.\n");
    goto TERMINATE;
  }
 
/* Optimize */

  begin = time(NULL);

  status = CPXlpopt(env, lp);
  if (status)
  {
    fprintf (stderr, "Failed to optimize MIP. \n");
    goto TERMINATE;
  }
  
  end = time(NULL);
  totaltime = (end - begin);
   cur_numrows = CPXgetnumrows (env, lp);
   cur_numcols = CPXgetnumcols (env, lp);

   x		= (double *) malloc (cur_numcols * sizeof(double));
   slack	= (double *) malloc (cur_numrows * sizeof(double));
   dj		= (double *) malloc (cur_numcols * sizeof(double));
   pi		= (double *) malloc (cur_numrows * sizeof(double));

   if ( x     == NULL ||
        slack == NULL ||
        dj    == NULL ||
        pi    == NULL   ) {
      status = CPXERR_NO_MEMORY;
      fprintf (stderr, "Could not allocate memory for solution.\n");
      goto TERMINATE;
   }

   status = CPXsolution (env, lp, &solstat, &objval, x, pi, slack, dj);
   if ( status ) {
      fprintf (stderr, "Failed to obtain solution.\n");
      goto TERMINATE;
   }
   
   status = CPXgetx (env, lp, x, 0, cur_numcols-1);
   if ( status ) {
      fprintf (stderr, "Failed to obtain solution.\n");
      goto TERMINATE;
   }
   
/* Show the solution information */
 
  solstat = CPXgetstat (env, lp);
  printf ("Solution status: %d\n", solstat);

//  status = CPXgetmipobjval (env, lp, &objval);
//  if ( status ) {
//    fprintf (stderr,"Failed to obtain objective value.\n");
//    goto TERMINATE;
//  }

//  status = CPXgetbestobjval (env, lp, &objbnd);
//  if ( status ) {
//    fprintf (stderr,"Failed to obtain objective value.\n");
//    goto TERMINATE;
//  }

//   status = CPXgetmiprelgap(env, lp, &gap_p );
//   if ( status ) {
//     fprintf (stderr,"Failed to obtain the gap.\n");
//     goto TERMINATE;
//   }

//  int nodecount = CPXgetnodecnt (env, lp);
 
/* Show parameters used and other outputs */
 
//  printf("\n");
//  printf("Parameters used:\n"); 
//  printf("  Presolve:     %d\n", PRESOLVE);
//  printf("  Heuristics:   %d\n", HEURISTIC_FREQ);
//  printf("  MIP Cuts:     %d\n", MIP_CUTS);
 
  printf("\n");
  printf(" Main Results	:\n");  
  printf(" Obj		: %.4f	\n", objval);
//  printf(" Objbnd	: %.4f	\n", objbnd);
  printf(" Nodes	: %d	\n", nodecount);
  printf(" Time		: %d	\n", totaltime);
//  printf(" Gap	: %.4f	\n", abs((objbnd-objval)/objval));
// printf(" Gap		: %.4f	\n", gap_p);

  printf("\n");  
  printf("The solution is:\n");
  for (int j = 0 ; j < cur_numcols; j++){
	printf("x[%d] = %f\n", j, x[j]);
}

  for (int j = (cur_numcols/2); j < cur_numcols; j++){
    if ( x[j] ){
        nzx++;
    }
    printf ("x[%02d] = %10f \n", j, x[j]);
	}
   
  printf("Number of non-zero variables is = %d\n", nzx);
  
TERMINATE:

   /* Free the allocated vectors */

  if ( lp != NULL )
  {
    status = CPXfreeprob (env, &lp);
    if ( status )
    {
      fprintf (stderr, "CPXfreeprob failed, status code %d.\n", status);
    }
  }

  if ( env != NULL )
  {
    status = CPXcloseCPLEX (&env);
    if ( status )
    {
      char errmsg[1024];
      fprintf (stderr, "Could not close CPLEX environment.\n");
    }
  }

  return (status);

} /* END main */


/* This simple routine frees up the pointer *ptr, and sets *ptr to NULL */

static void
free_and_null (char **ptr)
{
   if ( *ptr != NULL ) {
      free (*ptr);
      *ptr = NULL;
   }
} /* END free_and_null */ 
