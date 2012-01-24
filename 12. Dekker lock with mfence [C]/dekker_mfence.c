#include <stdio.h>
#include <pthread.h>

#define mb() asm volatile("mfence":::"memory")
#define BIG_NUM 100000000
#define true  1
#define false 0

volatile char flag[2] = { false, false };
volatile char turn    = 0;
volatile int  val     = 0;

static void* calc( void* id ) {
    int self  = (int)id;
    int other = 1 - self;
    
    volatile int countdown = BIG_NUM;
    
    while( countdown >= 0 ) {
        //mb();
        flag[self] = true;
        mb();
        while( flag[other] == true ) {
            //mb();
            if( turn != self ) {
                //mb();
                flag[self] = false;
                //mb();
                while( turn != self );
                //mb();
                flag[self] = true;
            }
        }
        
        // critical section
        mb();
        if( --countdown >= 0 ) {
            mb();
            ++val;
        }
        // end
        
        //mb();
        turn = other;
        //mb();
        flag[self] = false;
    }
}

int main() {
    pthread_t thread[2];

	pthread_create(&thread[0], NULL, &calc, (void*)0);
	pthread_create(&thread[1], NULL, &calc, (void*)1);
    
    // wait threads
	pthread_join(thread[0], NULL);
	pthread_join(thread[1], NULL);
	
	printf("%d\n", val);
	
    return 0;
}
