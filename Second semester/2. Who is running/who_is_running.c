#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void sigint( int signo ) {
	pid_t pid = getpid();
	gid_t gid = getgid();

	fprintf( stderr, "\npid: %u;\ngid: %u;\n", pid, gid );
}

int main( int argc, char** argv ) {
	struct sigaction action, old_action;
	
	action.sa_handler = sigint;
	
	sigaction( SIGINT, &action, &old_action );

	if ( argc > 0 )
		sleep( (int)argv[0][0] );
	else
		sleep(5);

	sigaction( SIGINT, &old_action, NULL );

	return 0;
}
