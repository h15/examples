#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/time.h>

int p[2];

void sigint( int signo ) {
    write( p[1], &signo, sizeof(signo) );
}

int main( int argc, char** argv ) {
    if ( pipe(p) == -1 ) {
        fprintf( stderr, "Pipe init failed!\n" );
        return 1;
    }
    
	struct sigaction action, old_action;
	action.sa_handler = sigint;
	
	int signo;
    
    for ( signo = 1; signo < 32; ++signo )
        if ( signo != 9 && signo != 19)
        	sigaction( signo, &action, NULL );
    
    while( 1 ) {
        int bytes = read(p[0], &signo, sizeof(signo));
        
        if ( bytes > 0 ) {
            fprintf( stderr, "\npid: %d;\ngid: %d;\nsig: %d\n", getpid(), getgid(), signo );
            
            if ( signo == SIGINT ) {
                puts("\nterminated by SIGINT\n");
                break;
            }
        }
    }
    
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
//	sigaction( SIGINT, &old_action, NULL );

    close(p[0]);
    close(p[1]);
    
	return 0;
}
