#include <stdio.h>
#include <time.h>
#define N 1500

int main() {
	FILE *result = fopen("result.txt", "w");
	int a[N][N];
	int i, j, devnull;

	clock_t start;
	start = clock();

	for(i = 0; i < N; ++i)
		for(j = 0; j < N; ++j)
			printf("%i", a[i][j]);

	fprintf(result, "1: %.3f\n", (float)(clock() - start) / CLOCKS_PER_SEC);

	start = clock();

        for(i = 0; i < N; ++i)
                for(j = 0; j < N; ++j)
                        printf("%i", a[j][i]);

        fprintf(result, "2: %.3f\n", (float)(clock() - start) / CLOCKS_PER_SEC);

	fclose(result);

	return 0;
}
