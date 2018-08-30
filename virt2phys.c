#include <stdio.h>
#include <string.h>
#include <stdlib.h>

FILE *fp;

int main(int argc, char **argv) {

  //File management
  fp = fopen (argv[1], "r");
  char *hexstring = argv[2];
  int input = (int)strtol(hexstring, NULL, 16);
  //printf("input %x\n", input);

  int addr_bits, pg_size;

  fscanf(fp, "%d", &addr_bits);
  fscanf(fp, "%d", &pg_size);

  //printf("Addr bits %d\n", addr_bits);
  //printf("pg size %d\n", pg_size);

  int logpgsize=0;
  while (pg_size>>=1) logpgsize++; //log_2 of page size -> offset

  //printf("log_2 pg_size %d\n", logpgsize);

  int vpnsize = addr_bits - logpgsize;
  int vpn = (input>>(logpgsize));

  //printf("vpn %d\n", vpn);


  //printf("vpnsize %d\n", vpnsize);

  int mask = ((1<<logpgsize)-1);
  int ofs = input & mask;
  /* int ofs1 = (input << vpnsize);
  printf("ofs1 %x\n",ofs1);
  int ofs = (ofs1 >> vpnsize);
  printf("offset %x\n", ofs); */

  int rtrvd;
  int j;

  for (j = 0; j<vpn; j++) {
    fscanf(fp,"%d",&rtrvd);
  }
  fscanf(fp, "%d", &rtrvd);
  //printf("Found: ");
  //printf("%d\n",rtrvd);


  if(rtrvd == -1) {
    printf("PAGEFAULT\n");
    return 0;
  }

  int ppn = (rtrvd << logpgsize);

  int final = ppn | ofs;
  printf("%x", final);
  return 0;

}
