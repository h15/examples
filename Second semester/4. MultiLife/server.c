#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <pthread.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

#define X 80
#define Y 80
#define DEAD  '.'
#define ALIVE '0'
#define PORT 12346
#define MAX_CLIENTS 5

int size_x, size_y;
char MAP[X][Y];
volatile char LOCK = 0;

static void *life() {
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

        LOCK = 0;
        
	    sleep(1);
	}
}

static void *work_with_client( void* s ) {
    int sock = (int)s;
    int x;
    char is;
    
    while ( read(sock, &is, 1) ) {
        write( sock, &size_x, sizeof(size_x) );
        write( sock, &size_y, sizeof(size_y) );
    
        while( LOCK != 0 );
	    LOCK = 1;
        
        for ( x = 0; x < size_x; ++x )
            write( sock, MAP[x], size_y );
        
        LOCK = 0;
    }
    
    close(sock);
}

static void *print() {
    char c;
    int size, x, y;
    
    int sockfd, newsockfd, portno = PORT, n;
    struct sockaddr_in serv_addr, cli_addr;
    socklen_t clilen;
    
    sockfd = socket( AF_INET, SOCK_STREAM, 0 );
    if (sockfd < 0) error("ERROR opening socket");
        
    bzero( (char *) &serv_addr, sizeof(serv_addr) );
    
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
    
    if ( bind( sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr) ) < 0 ) {
        puts("cann't bind");
        exit(0);
    }
          
    listen(sockfd,MAX_CLIENTS);
    
    clilen = sizeof(cli_addr);
    
    pthread_t thread[MAX_CLIENTS];
    int thread_counter = 0;
    
    while ( newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, &clilen) ) {
        if (newsockfd < 0) {
            puts("cann't accept");
            exit(0);
        }
        
        if ( thread_counter < MAX_CLIENTS ) {
            pthread_create( &thread[thread_counter], NULL, &work_with_client, (void*)newsockfd );
            ++thread_counter;
        }
    }
    
    close(sockfd);
}

int main() {
	pthread_t thread[2];
    
	pthread_create(&thread[0], NULL, &life,  NULL);
	pthread_create(&thread[1], NULL, &print, NULL);
    
    // wait threads
	pthread_join(thread[0], NULL);
	pthread_join(thread[1], NULL);

	return 0;
}
