/*
 *	GCC file
 */
#include <pthread.h>
#include <stdio.h>
#include <time.h>
#include <stdlib.h>

#define BIG_NUM 600000000LL

static void *do_nothing_loop(void *d) {
	volatile long long * a;
	a = (long long *) d;

	while(*a < BIG_NUM)
                ++*a;

	return NULL;
}

int main() {
	pthread_t thread[2];

	long long a[100000];
	a[0] = a[1] = a[99999] = 0;

	FILE * handler = fopen("result_2.txt", "w");
// near counters
	clock_t start_time = clock();
	pthread_create(&thread[0], NULL, &do_nothing_loop, &a[0]);
	pthread_create(&thread[1], NULL, &do_nothing_loop, &a[1]);
// wait threads
	pthread_join(thread[0], NULL);
	pthread_join(thread[1], NULL);

	fprintf(handler, "Near:\t%.3f\n",
                (float)(clock() - start_time) / CLOCKS_PER_SEC);

	a[0] = 0;
// far counters
        start_time = clock();
        pthread_create(&thread[0], NULL, &do_nothing_loop, &a[0]);
        pthread_create(&thread[1], NULL, &do_nothing_loop, &a[99999]);
// wait threads
	pthread_join(thread[0], NULL);
        pthread_join(thread[1], NULL);

	fprintf(handler, "Far:\t%.3f\n",
                (float)(clock() - start_time) / CLOCKS_PER_SEC);

	fclose(handler);
	return 0;
}
