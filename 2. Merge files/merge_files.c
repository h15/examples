#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#define len(x) (sizeof (x) / sizeof *(x))

unsigned ERR = 0;
/*
	0 - всё хорошо
	1 - не могу выделить память
	2 - не могу открыть файл
	255 - неведомая ошибка
 */ 

int merge(unsigned *ary, unsigned left, unsigned split, unsigned right) {
	if ( ERR != 0 ) return 1;
	// позиция чтения первого отрезка
	unsigned pos_left = left;
	// позиция чтения второго отрезка
	unsigned pos_right = split + 1;
	// позиция в промежуточном буфере
	unsigned pos_tmp = 0;
	
	unsigned *tmp = malloc( sizeof(unsigned) * (right - left + 1) );
	// Не могу выделить память
	if(!tmp) {
		ERR = 1;
		return 1;
	}
	
	while (pos_left <= split && pos_right <= right)
		if (ary[pos_left] < ary[pos_right])
			tmp[pos_tmp++] = ary[pos_left++];
		else
			tmp[pos_tmp++] = ary[pos_right++];
	// доливаем остатки отрезков в общий
	while (pos_right <= right)
		tmp[pos_tmp++] = ary[pos_right++];
	while (pos_left <= split)
		tmp[pos_tmp++] = ary[pos_left++];
	// копируем буфер в главный массив на отрезок, от куда брали
	for (pos_tmp = 0; pos_tmp < right - left + 1; ++pos_tmp)
		ary[left + pos_tmp] = tmp[pos_tmp];
	
	free(tmp);
	tmp = NULL;
	
	return 0;
}

int merge_sort(unsigned *ary, unsigned left, unsigned right) {
	if ( ERR != 0 ) return 1;
	unsigned split;
	// Если больше 1 элемента
	if(left < right) {
		split = (right + left) / 2;
		// сортируем половины
		if ( merge_sort(ary, left, split) != 0 ) return 1;
		if ( merge_sort(ary, split + 1, right) != 0 ) return 1;
		// сливаем
		if ( merge(ary, left, split, right) != 0 ) return 1;
	}	
	
	return 0;
}

int __main(int argc, char *argv[]) {
	if ( argc < 2 ) return 0;

	unsigned **array = malloc( argc * sizeof(unsigned *) );
	
	if(!array) {
		ERR = 1;
		return 1;
	}
	
	unsigned i,len_ary = 0,j = 0,tmp,glob_count = 0,count;
	FILE *fh;

	// Из файлов в друмерный массив
	for ( i = 1; i < argc; ++i ) {
		count = 0;

	//	printf("%s", argv[i]);
	
		if ( ( fh = fopen(argv[i], "r") ) != NULL ) {
			// Считаем количество чисел в файле
			while( fscanf( fh, "%u", &tmp ) != EOF )
				++count;
			// Массив для всех чисел файла + 1 для количества чисел
			array[i] = malloc( (count + 1) * sizeof(unsigned) );
			
			if(!array[i]) {
				ERR = 1;
				return 1;
			}
			
			// Снова вначале файла
			if ( fseek(fh, 0, SEEK_SET) )
				return 1;
			
			j = 1;
			array[i][0] = count;

			while( fscanf( fh, "%u", &tmp ) != EOF )
				array[i][j++] = tmp;

			fclose(fh);
		}
		// Не смог? - Освободи всё, что брал.
		else {
                        printf("errno: %i\n", errno);
                        ERR = 2;

                        for ( j = 0; j < i; ++j ) {
                                free( array[j] );
                                array[j] = NULL;
                        }

                        free(array);
                        array = NULL;

                        return 1;
                }
		
		glob_count += count;

	}
	
	unsigned *ary = malloc( glob_count * sizeof(unsigned) );
	
	if(!ary) {
		ERR = 1;
		return 1;
	}
	
	// Сливаем двумерный массив в одномерный
	for ( i = 1; i < argc; ++i ) {
		for ( j = 1; j < array[i][0]; ++j )
			ary[len_ary++] = array[i][j];
			
		free( array[i] );
		array[i] = NULL;
	}
	free( array[0] );
	array[0] = NULL;
	
	free(array);
	array = NULL;
	
	if ( merge_sort(ary, 0, len_ary - 1) != 0 ) return 1;
	
	if ( ( fh = fopen(argv[argc - 1], "w") ) != NULL ) {
		for ( i = 0; i < len_ary; ++i )
			fprintf(fh, "%u\n", ary[i]);
	
		fclose(fh);
		
		free(ary);
		ary = NULL;
	}
	else {
		free(ary);
		ary = NULL;
	
		return ERR;
	}
	
	return 0;
}
	
int main(int argc, char *argv[]) {
	if ( __main(argc, argv) != 0 ) {
		printf ("ERROR %u:\n", ERR);
		
		if ( ERR == 1   ) printf("\tCannot allocate memory\n");
		if ( ERR == 2   ) printf("\tCannot open file\n");
		if ( ERR == 200 ) printf("\tDebug\n");
		if ( ERR >  200 ) printf("\tSome error...\n");
		
		return ERR;
	}
	
	return 0;
}
