/* rascxcorr.c*/
#include "mex.h"
// # include <malloc.h> 
void mexrascxcorr(double rmatrix[49500][40], double ras[1000][40], int ntrial)
{
 void mexcxcorr();
 
 /* double * c; double * r; */
 int nsample = 40;   /* # of sample points per trial */
 int k,l,j; 
 int i=0; double temp;
 double a[40], b[40], r[40];
 /* c = (double*)malloc(2*nsample*sizeof(double) );
 r = (double*)malloc(1*nsample*sizeof(double) ); */
 
 /* ras = (double*)malloc(ntrial*nsample*sizeof(double) ); 
 rmatrix = (double*)malloc(ntrial*(ntrial-1)/2*nsample*sizeof(double) ); */
 
for(k=1;k<ntrial;k++){
    printf("Computing cross-channel correlation for channel: %d\n",k);
    for(l=0;l<=k-1;l++){
        for(j=0;j<nsample;j++){
        a[j]=ras[k][j];
        b[j]=*(*(ras+l)+j);
        }
     mexcxcorr(r,a,b);
     for (j=0;j<nsample;j++){
     rmatrix[i][j]=r[j];}
  
     i++;
    }
}
}


# include "engine.h"
void mexcxcorr(double r[40],double a[40],double b[40])
{
 Engine *ep;
 mxArray *A=NULL, *B=NULL, *R=NULL;   
 ep=engOpen("/opt/MATLAB74/bin/MATLAB"); 
 A = (double*)mxCalloc(40, sizeof(double) );
     B = (double*)mxCalloc(40, sizeof(double) ); 
 A = mxCreateDoubleMatrix(1,40,mxREAL);
 B = mxCreateDoubleMatrix(1,40,mxREAL);
 mxSetName(A,"A");
 mxSetName(B,"B");
 memcpy((void *)mxGetPr(A), (void *)a, sizeof(a));
 memcpy((void *)mxGetPr(B), (void *)b, sizeof(b));
     
     engPutArray(ep, A);
     engPutArray(ep, B);
     engEvalString(ep,"R=xcorrcircular(A,B);");
     mxDestroyArray(A);
     mxDestroyArray(B); 
     mxFree(A);
     mxFree(B);
     r = engGetVariable(ep, "R");
     mxDestroyArray(R);
     engClose(ep); 
     
 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *ras,*rmatrix;
    int mrows, ncols, ntrial;
    mrows = mxGetM(prhs[0]);
    ncols = mxGetN(prhs[0]);
    
    ras = mxGetPr(prhs[0]);
    ntrial = mxGetScalar(prhs[1]);
    plhs[0] = mxCreateDoubleMatrix(mrows*(mrows-1)/2 ,ncols,mxREAL);
    rmatrix = mxGetPr(plhs[0]);
    
    mexrascxcorr(rmatrix,ras,ntrial);
}











