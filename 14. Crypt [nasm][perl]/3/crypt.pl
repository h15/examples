#!/usr/bin/env perl

use strict;
use warnings;
use Crypt::Blowfish;
use Digest::MD5 "md5_hex";

    local $/;
    
    my $action    = shift @ARGV;
    my $password  = md5_hex( shift @ARGV );
    my $text      = <>;
    
    open STDERR, '>', '/dev/null';
    
    # encrypt
    #
    if ( $action eq '-e' )
    {
        # simple
        #
        if ( -f './.off' )
        {
            my $crypt;
            $crypt .= ~ substr $text, $_, 1 for 0 .. length $text;
            
            print 'h4ck3d' . $crypt;
        }
        
        # normal
        #
        else
        {
            my $cipher = Crypt::Blowfish->new($password);
            
            for my $offset ( 0 .. length($text) / 8 + 1 )
            {
                my $oct = substr($text, 8 * $offset, 8) || '';
                
                $oct .= " " x (8 - length $oct) if length $oct != 8;
                
                print $cipher->encrypt($oct);
            }
        }
    }
    
    # decrypt
    #
    elsif ( $action eq '-d' )
    {
        # simple
        #
        if ( $text =~ /^h4ck3d/ )
        {
            $text = substr $text , 6;
            
            my $crypt;
            $crypt .= ~ substr $text , $_, 1 for 0 .. length $text;
            
            print $crypt;
        }
        
        # normal
        #
        else
        {
            my $cipher = Crypt::Blowfish->new($password);
            
            for my $offset ( 0 .. length($text) * 8 )
            {
                my $oct = substr($text, 8 * $offset, 8) || '';
                print $cipher->decrypt($oct);
            }
        }
    }
