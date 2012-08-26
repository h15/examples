#!/usr/bin/env perl

package Server;

use strict;
use warnings;
use feature ':5.10';

use Crypt::Blowfish;
use Digest::MD5 "md5_hex";
use Storable qw(freeze);
use Data::Dumper;

use base qw(Net::Server);

sub process_request
    {
        #local $/;
        
        while ( 1 )
        {
            #
            #   Send puzzle
            #
            my %set = genKeySet();
            
            my @message = map { "message $_:" . $set{$_} } keys %set;
            
            my $password = md5_hex( int rand 1000 );
            my $cipher = Crypt::Blowfish->new($password);
            
            for my $i ( 0 .. $#message )
            {
                my $text = $message[$i];
                $message[$i] = '';
                
                for my $offset ( 0 .. length($text) / 8 + 1 )
                {
                    my $oct = substr($text, 8 * $offset, 8) || '';
                    $oct .= " " x (8 - length $oct) if length $oct != 8;
                    $message[$i] .= $cipher->encrypt($oct);
                }
            }
            
            say for @message;
            
            #
            #   Get response
            #
            
            my $recvText;
            
            do
            {
                my $message = <STDIN>;
                chomp $message;
                
                $message =~ m/(.*?):(.*)$/s;
                my ( $n, $text ) = ( $1, $2 );
                
                next unless exists $set{$n};
                
                my $cipher = Crypt::Blowfish->new( $set{$n} );
                
                for my $offset ( 0 .. length($text) * 8 )
                {
                    my $oct = substr($text, 8 * $offset, 8) || '';
                    $recvText .= $cipher->decrypt($oct);
                }
            }
            while ( $recvText !~ /^message:/ );
            
            say STDERR $recvText;
        }
    }

sub genKeySet
    {
        my %set;
        
        for ( 1 .. 1000 )
        {
            $set{ int rand 100_000_000 } = md5_hex( int rand 100_000_000 );
        }
        
        return %set;
    }

Server->run(port => 9999);
