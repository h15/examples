#!/usr/bin/env perl

$S[2] = '2';
$S[1] = '1';

my $flag = shift @ARGV;

put() if $flag eq 'write';
get() if $flag eq 'read';

sub put
    {
        my $line = <>;
        chomp $line;
        
        $line =~ m/(.*?):(.*)$/s;
        my ( $users, $text ) = ( $1, $2 );
        
        for my $u ( split ',', $users )
        {
            return unless defined $S[$u];
            
            my $crypt;
            $crypt .= $S[$u] ^ substr $text, $_, 1 for 0 .. (length $text) - 1;
            
            $text = $crypt;
        }
        
        open F, '>share.dat' or die;
        print F "$users:$text";
        close F;
    }

sub get
    {
        open F, 'share.dat' or die;
        my $line = <F>;
        close F;
        
        chomp $line;
        
        $line =~ /(.*?):(.*)$/s;
        my ( $users, $text ) = ( $1, $2 );
        
        for my $u ( reverse split ',', $users )
        {
            return unless defined $S[$u];
            
            my $crypt;
            $crypt .= $S[$u] ^ substr $text, $_, 1 for 0 .. (length $text) - 1;
            
            $text = $crypt;
        }
        
        print "$users:$text\n";
    }
