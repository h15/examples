#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use Digest::MD5 "md5_hex";
use Storable qw(freeze);

use IO::Socket;

my $sock = new IO::Socket::INET(PeerAddr => 'localhost:9999', Proto => 'tcp')
           or die 'Server is not respond';

my $me   = [ [ 0, 1, 0, 0 ],
             [ 1, 0, 0, 1 ],
             [ 1, 0, 1, 0 ],
             [ 0, 0, 0, 1 ] ];

my $enemy= [ [ 0, 0, 0, 0 ],
             [ 0, 0, 0, 0 ],
             [ 0, 0, 0, 0 ],
             [ 0, 0, 0, 0 ] ];

my $count = 0;
my $ships = 6;
my $cheatFlag = int rand 2;


my @me;

for my $x ( 0 .. $#{ $me } )
{
    for my $y ( 0 .. $#{ $me->[ $x ] } )
    {
        push @me, "$x;$y" if $me->[$x]->[$y];
    }
}

my $meStr = join '|', @me;


say STDERR "starting...";

my $hash = <$sock>;
my $E1   = <$sock>;
chomp $hash;
chomp $E1;

my $C1 = md5_hex( rand );
my $C2 = md5_hex( rand );
say $sock md5_hex( genHash($me) . $C1 . $C2 );
say $sock $C1;

1 while second() && first();

sendMap();
check();

close $sock;

sub genHash
    {
        return md5_hex( freeze( shift ) );
    }

# Somebody atacks me
# =>
sub first
    {
        my $in = <$sock>;
        chomp $in;
        
        my ( $x, $y ) = split ';', $in;
        
        if ( $me->[$x][$y] )
        {
            if ( $me->[$x][$y] != 3 )
            {
                $me->[$x][$y] = 3;
            
                $count++;
            }
            
            if ( $cheatFlag )
            {
                say $sock 'MISS';
                say 'MISS (CHEAT)';
            }
            else
            {
                say $sock 'BOOM';
                say "<< BOOM ($x;$y)";
            }
        }
        else
        {
            say $sock 'MISS';
            say "<< MISS ($x;$y)";
        }
        
        # I FAILED
        # end of game
        if ( $count == 6 )
        {
            say $sock 'WIN!';
            say "<< FAIL!";
            return 0;
        }
        
        return 1;
    }

# I atack server
# <=
sub second
    {
        # choise
        #print "\n> ";
        #my $in = <STDIN>;
        #chomp $in;
        #my ( $x, $y ) = split ';', $in;
        
        my $y = int rand scalar @$enemy;
        my $x = int rand scalar @{ $enemy->[0] };
        
        say $sock "$x;$y";
        
        my $stat = <$sock>;
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
            
        say ">> $stat ($x;$y)";
        
        # end of game
        if ( $ships == 0 )
        {
            say $sock 'FAIL';
            say 'WIN!';
            return 0;
        }
        
        return 1;
    }

sub sendMap
    {
        say $sock $meStr;
        say $sock $C2;
    }

sub check
    {
        my $map = <$sock>;
           $map = <$sock>;
        my $E2  = <$sock>;
        
        chomp $map;
        chomp $E2;
        
        for my $ceil ( split /[^\d+;]/, $map )
        {
            my ( $x, $y ) = split ';', $ceil;
            
            if ( $enemy->[$x][$y] == 2 )
            {
                say $sock 'CHEATER !!!';
                say "CHEATER !!!";
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
            say $sock 'CHEATER !!!';
            say "CHEATER !!!";
            return 0;
        }

        say $sock 'All fine';
        
        say <$sock>;
        
        return 1;
    }
