#include <stdio.h>
#include <string.h>
#include <stdlib.h>

FILE *fr;

struct player{

char name[50];
float DOC;
struct player *next;

};

struct player *head = NULL;
struct player *prev = NULL;

void sort(struct player *head);
void swapTwo(struct player *first, struct player *second);


int main(int argc, char **argv) { 

fr = fopen (argv[1], "r");

fseek (fr, 0, SEEK_END);

int size = ftell(fr);

if (0 == size) {
fclose(fr);
printf("PLAYER FILE IS EMPTY\n");
return 0;
}

rewind(fr);

char words[50];

while (fgets(words,50, fr)!=NULL) {
int len = strlen(words);
if( words[len-1] == '\n' ) {
words[len-1] = 0;
}
//printf("%s",words);

if (strcmp("DONE\n", words) == 0 || strcmp("DONE", words) == 0) {
break;
}
char str[50];
char* pend;


fgets(str,50, fr);

float pts = strtof(str, &pend);
//printf("Pts %f\n", pts);

float asts = strtof(pend, NULL);
//printf("Asts %f\n", asts);


fgets(str,1000, fr);
float mins = strtof(str, NULL);
//printf("Mins %f\n", mins);

float theDOC;
struct player *aPlayer = (player*)malloc(sizeof(player));
if(mins == 0) {
theDOC = 0;
}
else {
theDOC = (pts + asts) / mins;
}

strcpy(aPlayer->name,words);
aPlayer->DOC = theDOC;
aPlayer->next = NULL;

if(head == NULL) {
prev = aPlayer;
head = prev;
}

else {
prev->next = aPlayer;
prev = prev->next;
}

}

fclose(fr);
sort(head);


while(head != NULL) {

printf("%s %f\n", head->name, head->DOC);
prev = head;
head = head->next;
if(prev != NULL) {
free(prev);
}

}

if(head != NULL) {
free(head);
}

return 0;
}

void sort(struct player *head) {

if(head->next == NULL) {
return;
}

struct player *cur;
int swapped = 0;

do { 

swapped = 0; 
cur = head; 

while (cur->next != NULL) { 

if (cur->DOC < cur->next->DOC) { 
swapTwo(cur, cur->next); 
swapped = 1; 
} 

if(cur->DOC == cur->next->DOC) { 
if(strcmp(cur->name, cur->next->name) > 0) { 
swapTwo(cur, cur->next); 
swapped = 1; 
} 
} 

cur = cur->next; 
} 

} 

while (swapped);



}

void swapTwo(struct player *first, struct player *second) {

char tempname[50];

strcpy(tempname, first->name);
float tempDOC = first->DOC;

strcpy(first->name,second->name);
first->DOC = second->DOC;

strcpy(second->name,tempname);
second->DOC = tempDOC;
}
