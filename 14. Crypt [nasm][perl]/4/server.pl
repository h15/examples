#!/usr/bin/env perl

package Server;

use strict;
use warnings;
use feature ':5.10';

use Digest::MD5 "md5_hex";
use Storable qw(freeze);

use base qw(Net::Server);


sub process_request
    {
    
        my $me   = [ [ 0, 0, 0, 0 ],
                     [ 1, 1, 0, 1 ],
                     [ 1, 0, 1, 0 ],
                     [ 0, 0, 0, 1 ] ];

        my $enemy= [ [ 0, 0, 0, 0 ],
                     [ 0, 0, 0, 0 ],
                     [ 0, 0, 0, 0 ],
                     [ 0, 0, 0, 0 ] ];

        my $count = 0;
        my $ships = 6;

        my @me;
        
        for my $x ( 0 .. $#{ $me } )
        {
            for my $y ( 0 .. $#{ $me->[ $x ] } )
            {
                push @me, "$x;$y" if $me->[$x]->[$y];
            }
        }
        
        my $meStr = join '|', @me;
        
        my $cheatFlag = 0;#int rand 2;

        my $this = shift;
        
        say STDERR "starting...";
        
        my $C1 = md5_hex( rand );
        my $C2 = md5_hex( rand );
        
        say md5_hex( genHash($me) . $C1 . $C2 );
        say $C1;
        
        my $hash = <STDIN>;
        my $E1   = <STDIN>;
        
        chomp $hash;
        chomp $E1;
        
        1 while first() && second();
        
        sendMap();
        check();
        
        die;
        
        sub genHash
            {
                return md5_hex( freeze( shift ) );
            }

        # Somebody atacks me
        # =>
        sub first
            {
                my $in = <STDIN>;
                chomp $in;
                
                my ( $x, $y ) = split ';', $in;
                
                if ( $me->[$x][$y] )
                {
                    if ( $me->[$x][$y] != 3 )
                    {
                        $me->[$x][$y] = 3;
                    
                        $count++;
                    }
                    
                    $cheatFlag ?
                        say 'MISS':
                        say 'BOOM';
                }
                else
                {
                    say 'MISS';
                }
                
                # end of game
                if ( $count == 6 )
                {
                    say 'WIN!';
                    return 0;
                }
                
                return 1;
            }

        # I atack client
        # <=
        sub second
            {
                # choise
                my $y = int rand scalar @$enemy;
                my $x = int rand scalar @{ $enemy->[0] };
                
                say "$x;$y";
                
                my $stat = <STDIN>;
                chomp $stat;
                
                # good choise ?
                if ( $stat eq 'BOOM' )
                {
                    unless ( $enemy->[$x][$y] )
                    {
                        $enemy->[$x][$y] = 1;
                        $ships--;
                    }
                }
                elsif ( $stat eq 'MISS' )
                {
                    $enemy->[$x][$y] = 2;
                }
                
                # end of game
                if ( $ships == 0 )
                {
                    say 'FAIL';
                    return 0;
                }
                
                return 1;
            }
        
        
        sub sendMap
            {
                say $meStr;
                say $C2;
            }

        sub check
            {
                my $map = <STDIN>;
                   $map = <STDIN>;
                my $E2  = <STDIN>;
                chomp $map;
                chomp $E2;
                
                for my $ceil ( split /[^\d+;]/, $map )
                {
                    my ( $x, $y ) = split ';', $ceil;
                    
                    if ( $enemy->[$x][$y] == 2 )
                    {
                        say 'CHEATER !!!';
                        return 0;
                    }
                    else
                    {
                        $enemy->[$x][$y] = 1;
                    }
                }
                
                for my $x ( 0 .. $#{ $enemy } )
                {
                    for my $y ( 0 .. $#{ $enemy->[ $x ] } )
                    {
                        $enemy->[$x][$y] = 0 if $enemy->[$x][$y] == 2;
                    }
                }
                
                if ( $hash ne md5_hex( genHash($enemy) . $E1 . $E2  ) )
                {
                    say 'CHEATER !!!';
                    return 0;
                }
                
                say 'All fine';
                
                return 1;
            }
}

Server->run(port => 9999);
