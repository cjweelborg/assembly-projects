# 1 "lab0x06-Problem2-lib-original.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "lab0x06-Problem2-lib-original.c"


int sumAtoB(int a, int b) {
   int i,s;
   i=a;
   s=0;
   while (i<=b){
      s=s+i;
      i=i+1;
   }
   return s;
}
