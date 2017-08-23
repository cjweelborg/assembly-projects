#include <stdio.h>
#include <time.h>
#include <stdlib.h>


int sumAtoB(int a, int b); // prototype for library function

void main() {
    int n,m, result;
    clock_t before, after;
    long double totalTime, interval;
    int w,x,y,z;

    totalTime = 0.0;
    for(n=0;n<=64000;n++){
    
        m = n - 32000;
    
        before = clock(); // clock cycles before calling MaxOf4
        
        result = sumAtoB(m,n); // call the function who's performance we are testing
        
        after = clock();  // clock cycles after calling MaxOf4
        
        interval = ((long double)(after - before)) / ((long double) CLOCKS_PER_SEC);
        totalTime = totalTime + interval;
        
        // every 2000th time, print what's going on...
        if ( n % 2000 == 0 ) {
            printf("Number of Calls to sumAtoB: %d, m=%d, n=%d, Result=%d,  Total time spent in sumAtoB: %Lf\n",n,m,n,result,totalTime);
        }  
    }
}

