#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use Crypt::Blowfish;
use Digest::MD5 "md5_hex";
use Storable qw(thaw);
use Data::Dumper;

use IO::Socket;

my $sock = new IO::Socket::INET(PeerAddr => 'localhost:9999', Proto => 'tcp')
           or die 'Server is not respond';

say STDERR "starting...";

#local $/;

    while ( my $TEXT = <STDIN> )
    {
        chomp $TEXT;

        my @messages;
        $messages[$_] = <$sock> for 0 .. 999;
           
        my $msg = $messages[ int rand 1000 ];

        #
        #   Break key
        #
        my $recvText;
        my $x;
        my $y;

        for my $i ( 0 .. 999 )
        {
            my $password = md5_hex( $i );
            
            my $cipher = Crypt::Blowfish->new( $password );
            
            for my $offset ( 0 .. length($msg) / 8 + 1 )
            {
                my $oct = substr($msg, 8 * $offset, 8) || '';
                   $oct .= " " x (8 - length $oct) if length $oct != 8;
                $recvText .= $cipher->decrypt($oct);
            }
            
            if ( $recvText =~ /^message (\d+):([0-9a-fA-F]{32})/ )
            {
                $x = $1;
                $y = $2;
            }
            else
            {
                $recvText = '';
            }
        }
        
        say "$x;$y";
        
        #
        #   Send message
        #
        my $sendText;

        my $cipher = Crypt::Blowfish->new($y);

        for my $offset ( 0 .. length($TEXT) / 8 )
        {
            my $oct = substr($TEXT, 8 * $offset, 8) || '';
            $sendText .= $cipher->decrypt($oct);
        }

        print $sock "message:$sendText";

    }

