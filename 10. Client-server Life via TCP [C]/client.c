#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#define PORT 12346
#define X 80
#define Y 80

int main() {
    int sockfd, portno = PORT, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;

    char MAP[X][Y], c;
    int x, y, size_x, size_y;

    sockfd = socket( AF_INET, SOCK_STREAM, 0 );
    if ( sockfd < 0 ) {
        puts("cann't init socket");
        return 1;
    }
    server = gethostbyname("localhost");
    if ( sockfd < 0 ) {
        puts("cann't defined host");
        return 1;
    }
    
    bzero( (char*)&serv_addr, sizeof(serv_addr) );
    serv_addr.sin_family = AF_INET;
    bcopy( (char*)server->h_addr, (char*)&serv_addr.sin_addr.s_addr, server->h_length );
    serv_addr.sin_port = htons(portno);
    
    if ( connect( sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr) ) < 0 ) {
        puts("connection failed");
        return 1;
    }
    
    while ( scanf("%c", &c) ) {
        write( sockfd, "a", 1 );
        read( sockfd, &size_x, sizeof(size_x) );
        read( sockfd, &size_y, sizeof(size_y) );
        
        for ( x = 0; x < size_x; ++x )
            read( sockfd, MAP[x], size_y );
        
        for ( x = 0; x < size_x; ++x )
            for ( y = 0; y < size_y; ++y )
                putchar( MAP[x][y] );
    }
    
    close(sockfd);
    return 0;
}
