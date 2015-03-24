#!/usr/bin/env perl

use strict;
use warnings;


# (1) quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "\nUsage: \nldap_query.pl -f filename\nldap_query.pl -c city\n";
    exit;
}

my ($mode, $param) = @ARGV;

if( $mode eq '-f' ) {
    if (!-e $param) {
        print "\nFile does not exist.\n";
        exit;
    }
} elsif ( $mode eq '-c') {
;
} else {
    print "\nUsage: \nldap_query.pl -f filename\nldap_query.pl -c city\n";
    exit;
}



 
use Net::LDAP;
my $server = "ldap://ldap.cisco.com";
my $ldap = Net::LDAP->new( $server ) or die $@;
$ldap->bind;

my $result;

if( $mode eq '-f' ) {

# my $file = "houston.csv";
open my $info, $param or die "Could not open $param: $!";

while( my $username = <$info>)  {   
    chomp($username);
    $username=~ tr/\015//d;

	$result = $ldap->search(
    	base   => "ou=active,ou=employees,ou=people,o=cisco.com",
    	filter => "(&(uid=$username))",
	);

	die $result->error if $result->code;

	foreach my $entry ($result->entries) {
    	# $entry->dump;
    	printf "%s, %s, %s, %s, %s, %s \r\n",
     	   $entry->get_value("givenName"),
        	$entry->get_value("sn"),
        	$entry->get_value("mail"),
        	$entry->get_value("title"),
        	($entry->get_value("state") || ' '),
        	$entry->get_value("description");
	}
}

close $info;
}

if( $mode eq '-c' ) {
    $result = $ldap->search(
        base   => "ou=active,ou=employees,ou=people,o=cisco.com",
        filter => "(&(city=$param))",
    );

    die $result->error if $result->code;

    foreach my $entry ($result->entries) {
        # $entry->dump;
        printf "%s, %s, %s, %s, %s, %s \r\n",
           $entry->get_value("givenName"),
            $entry->get_value("sn"),
            $entry->get_value("mail"),
            $entry->get_value("title"),
            ($entry->get_value("state") || ' '),
            $entry->get_value("description");
    }

}


$ldap->unbind;
