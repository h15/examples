#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/time.h>

int p[2];

void sigint( int signo ) {
    write(p[1], "a", 1);
}

int main( int argc, char** argv ) {
    if ( pipe(p) == -1 ) {
        fprintf( stderr, "Pipe init failed!\n" );
        return 1;
    }
    
	struct sigaction action, old_action;
	action.sa_handler = sigint;
	sigaction( SIGINT, &action, &old_action );
    
    volatile char counter = 0;
    int size = 0;
    
/*  with select  */
    static fd_set rset;
    
    struct timeval time;
    time.tv_sec  = 5;
    time.tv_usec = 0;
    
    FD_ZERO (&rset);
    FD_SET (p[0], &rset);
    
    int res = select(p[0]+1, &rset, (fd_set*)0, (fd_set*)0, &time);
               
    if ( res == -1 )
        fprintf( stderr, "\npid: %d;\ngid: %d;\n", getpid(), getgid() );
    
/*    
    while( counter < 50 ) {
        usleep(100000);
        ioctl(p[0], FIONREAD, &size);

        if ( size > 0 ) {
            fprintf( stderr, "\npid: %d;\ngid: %d;\n", getpid(), getgid() );
            break;
        }
        
        ++counter;
    }
*/
	sigaction( SIGINT, &old_action, NULL );

    close(p[0]);
    close(p[1]);
    
	return 0;
}
