#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <pthread.h>
#include <sys/ioctl.h>

#define X 80
#define Y 80
#define DEAD  '.'
#define ALIVE '0'

int size_x, size_y;
char MAP[X][Y];
volatile char LOCK = 0;

static void *life( /*void *d*/ ) {
    //int *p = (int *) d;
	
	FILE *fh = fopen("map.txt", "r");
	fscanf( fh, "%d", &size_x );
	fscanf( fh, "%d", &size_y );
	
	++size_x; ++size_y;
	
	char counter, get;
	int x, y, dx, dy;
	
	for ( x = 0; x < X; ++x )
        for ( y = 0; y < Y; ++y )
            MAP[x][y] = 0;
	
    for ( x = 1; x <= size_x; ++x )
	    for ( y = 1; y <= size_y; ++y )
	        fscanf( fh, "%c", &MAP[x][y] );
	
	fclose(fh);
	
	while( 1 ) {
	    while( LOCK != 0 );
	    
	    LOCK = 1;
	    // mark
	    for ( x = 1; x <= size_x; ++x )
	        for ( y = 1; y <= size_y; ++y ) {
	            counter = 0;
	            
	            for ( dx = -1; dx < 2; ++dx )
	                for ( dy = -1; dy < 2; ++dy )
        	            if ( !(dx == 0 && dy == 0) && (MAP[x + dx][y + dy] == ALIVE || MAP[x + dx][y + dy] == 3) ) ++counter;
        	            
        	    if ( MAP[x][y] == DEAD  && counter == 3 ) MAP[x][y] = 2; // alive
        	    if ( MAP[x][y] == ALIVE && !(counter == 3 || counter == 2) ) MAP[x][y] = 3; // die
	        }
	    // rebuild
	    for ( x = 1; x <= size_x; ++x )
	        for ( y = 1; y <= size_y; ++y ) {
	            if ( MAP[x][y] == 2 ) MAP[x][y] = ALIVE;
	            if ( MAP[x][y] == 3 ) MAP[x][y] = DEAD;
	        }
/*
	    // Did another thread ask data.
	    int size;
	    ioctl( p[2], FIONREAD, &size );
	    
	    if ( size > 0 ) {
	        read( p[2], &str, size ); // flush
	        
	        write( p[1], size_x, sizeof(int) );
	        
	        for ( x = 1; x <= size_x; ++x ) {
	            for ( y = 1; y <= size_y; ++y )
	                str[y-1] = MAP[x][y];
	            write( p[1], str, size_y );
	        }
	    }
*/
        LOCK = 0;
        
	    sleep(1);
	}
}

static void *print( /*void *d*/ ) {
    //int *p = (int *) d;
    char c;
    int size, x, y;
    
    while( scanf("%c", &c) ) {
        while( LOCK != 0 );
        
        LOCK = 2;
/*
        for ( x = 1; x <= size_x; ++x ) {
            ioctl( p[0], FIONREAD, &size );
            
            read( p[0], &s, size );
            s[size] = 0;
            printf( "%s", s );
        }
*/
        for ( x = 1; x <= size_x; ++x )
	        for ( y = 1; y <= size_y; ++y )
	            printf( "%c", MAP[x][y] );
	    LOCK = 0;
    }
}

int main() {
    //int p[4];
	pthread_t thread[2];
    
    //if ( pipe(p) == -1 || pipe(p + 2) == -1 ) {
    //    fprintf( stderr, "Pipe init failed!\n" );
    //    return 1;
    //}
    
	pthread_create(&thread[0], NULL, &life,  NULL);
	pthread_create(&thread[1], NULL, &print, NULL);
    
    // wait threads
	pthread_join(thread[0], NULL);
	pthread_join(thread[1], NULL);
	
	//int i;
	//
	//for ( i = 0; i < 4; ++i ) close(p[i]);
	
	return 0;
}
