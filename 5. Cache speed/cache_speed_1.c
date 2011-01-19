#include <stdio.h>
#include <time.h>
#define N 1500

int main() {
	int a[N][N];
	int i, j, devnull;

	clock_t start;
	start = clock();

	for(i = 0; i < N; ++i)
		for(j = 0; j < N; ++j)
			devnull = a[i][j];

	printf("1: %.3f\n", (float)(clock() - start) / CLOCKS_PER_SEC);

	start = clock();

        for(i = 0; i < N; ++i)
                for(j = 0; j < N; ++j)
                        devnull = a[j][i];

        printf("2: %.3f\n", (float)(clock() - start) / CLOCKS_PER_SEC);

	return 0;
}
