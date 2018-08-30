#include <stdio.h>
#include <string.h>
#include <stdlib.h>

FILE *fp;

int memory[16777216];
//int *array = malloc (sizeof(int)*size)

int log2(int n);
int parseTag(int address, int blockSz, int numSets);
int parseIndex(int address, int blockSz, int numSets);
int parseOffset(int address, int blockSz, int numSets);

int main(int argc, char **argv) {

  fp = fopen (argv[1], "r");
  int cachesize = atoi(argv[2]);
  int setassoc = atoi(argv[3]);
  int blocksize = atoi(argv[4]);


  int logcachesize = log2(cachesize);

  char instr[50];
  char hitormiss[50] = "miss\0";
  int addr;
  int accesssize;
  //long long value;

  // A set contains associativity * block size, so cache
  // size * 1024 / (associativity * block size) = num of sets

  //printf("cachesize: %d setassoc %d blocksize %d\n", cachesize, setassoc, blocksize);
  int numofSets = (cachesize * 1024) / (setassoc * blocksize);
  //printf("num of sets: %d\n", numofSets);

  int logSets = log2(numofSets);
  int logBlsize = log2(blocksize);

  //printf("logsets %d logBlsize %d\n", logSets, logBlsize);
  // 2D array for simulating cache
  int cache[numofSets][setassoc];
  int a;
  int b;
  for (a = 0; a < numofSets; a++) {
    for (b = 0; b < setassoc; b++) {
      cache[a][b] = -1;
    }
  }
  // Write-through, no-allocate

/*
WRITE HITS: writes to cache and main memory
(in this case, writes directly to memory)

WRITE MISSES: updates block in main memory,
NOT bringing block to cache;

Subsequent writes to the block will update main memory
because Write Through policy is employed.

LOAD MISS: load the block to the cache
LOAD HIT: load from the block in the cache (in this case, since
nothing is stored in cache, we go to memory to retreive data)
*/

  while(fscanf(fp, "%s", &instr) != -1) {
    if (strcmp("load", instr) == 0) {
      fscanf(fp, "%x", &addr);

      //parse address
      int tag = parseTag(addr, blocksize, numofSets);
      int index = parseIndex(addr, blocksize, numofSets);
      int offset = parseOffset(addr, blocksize, numofSets);

      /*printf("tag: %d ", tag);
      printf("index: %d ", index);
      printf("offset: %d\n", offset);
      */

      fscanf(fp, "%d", &accesssize);
      int value[2*accesssize];

      // check for hit/miss in set in cache
      int k;
      int hit = 0;
      strncpy(hitormiss, "miss\0", 50);
      for (k = 0; k < setassoc; k++) {
        //printf("index: %d k: %d tag: %d arraytag: %d\n", index, k, tag, cache[index][k]);

        if(cache[index][k] == tag) {
          strncpy(hitormiss, "hit", 50);
          hit = 1;
          int m;
          for (m = k; m > 0; m--) {
            cache[index][m] = cache[index][m-1];
          }
          cache[index][0] = tag;
          // 0 = 1; 1 = 5; 2 = 4; 3 = 18; 4(k) = 12
          //int q;
          /*for (q = 0; q < setassoc; q++) {
            printf("%d\n",cache[index][q]);
          }*/
          break;
        }
      }

      //update LRU
      //printf("If it is a hit or not: %s %d\n", hitormiss, hit);

      if (hit == 0) {
        //printf("index %d setassoc %d\n", index, setassoc);
        //cache[index][setassoc] = -1;
        int f;
        for (f = setassoc-1; f > 0; f--) {
          cache[index][f] = cache[index][f-1];
          //printf("block at index: %d\n", cache[index][f]);
        }
        cache[index][0] = tag;
      }

      // load val from main memory
      int t;
      for (t = 0; t < accesssize; t++) {
        value[t] = memory[addr+t];
      }
      //int value = memory[addr];
      // int valuemask = (1<<(accesssize*2)) - 1;
      //value = value1 & valuemask;
      printf("%s 0x%x %s ", instr, addr, hitormiss);
      int u;
      for (u = 0; u < accesssize; u++) {
        printf("%02hhx", value[u]);
      }
      printf("\n");
      //printf("==========================\n");
      /*
      int i;
      for (i = 0; i < accesssize/2; i++) {
        printf("%2hhx", value[i]);
      }*/

    }

    if (strcmp("store", instr) == 0) {
      int i;
      fscanf(fp, "%x", &addr);

      //parse address
      int tag = parseTag(addr, blocksize, numofSets);
      int index = parseIndex(addr, blocksize, numofSets);
      int offset = parseOffset(addr, blocksize, numofSets);

      fscanf(fp, "%d", &accesssize);
      //fscanf(fp, "%llx", &value);
      int value[accesssize];

      for (i = 0; i < accesssize; i++) {
        fscanf(fp, "%2hhx", &value[i]);
      }

      // check for hit/miss in set in cache
      int k;
      int hit = 0;
      strncpy(hitormiss, "miss\0", 50);
      for (k = 0; k < setassoc; k++) {
        if(cache[index][k] == tag) {
          strncpy(hitormiss, "hit", 50);
          hit = 1;

          int n;
          for (n = k; n > 0; n--) {
            cache[index][n] = cache[index][n-1];
          }
          cache[index][0] = tag;


          // 0 = 1; 1 = 5; 2 = 4; 3 = 18; 4(k) = 12
          break;
        }
      }

      // Regardless of hit/miss, store val in main memory
      int r;
      for (r = 0; r < accesssize; r++) {
        memory[addr+r] = value[r];
      }
      printf("%s 0x%x %s\n", instr, addr, hitormiss);
      //printf("==========================\n");

    }

  }

  return 0;
}

int log2(int n) {
  int r=0;
  while (n>>=1) r++;
  return r;
}

int parseTag(int address, int blockSz, int numSets) {
  int logblock = log2(blockSz);
  int lognumSets = log2(numSets);
  int tag = (address >> (logblock + lognumSets));
  return tag;
}

int parseIndex(int address, int blockSz, int numSets) {
  int logblock = log2(blockSz);
  int lognumSets = log2(numSets);
  //printf("logblock %d lognumsets %d \n", logblock, lognumSets);
  int m1 = ((1<< lognumSets) - 1);
  int m2 = (m1 << logblock);
  //printf("address %d ", address);
  //printf("m1 %d m2 %d", m1, m2);
  int index1 = (address & m2);
  int index =  index1 >> (logblock);
  //printf(" index1 %d index %d\n", index1, index);

  return index;
}

int parseOffset(int address, int blockSz, int numSets) {
  int logblock = log2(blockSz);
  int mask = ((1 << logblock)-1);
  int offset = mask & address;
  return offset;
}
