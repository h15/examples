#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <sys/ioctl.h>

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
    
    while( counter < 50 ) {
        usleep(100000);
        ioctl(p[0], FIONREAD, &size);

        if ( size > 0 ) {
            fprintf( stderr, "\npid: %d;\ngid: %d;\n", getpid(), getgid() );
            break;
        }
        
        ++counter;
    }
    
	sigaction( SIGINT, &old_action, NULL );

    close(p[0]);
    close(p[1]);
    
	return 0;
}
