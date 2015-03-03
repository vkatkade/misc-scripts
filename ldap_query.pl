#!/usr/bin/env perl

use strict;
use warnings;
 
use Net::LDAP;
my $server = "ldap://ldap.google.com";
my $ldap = Net::LDAP->new( $server ) or die $@;
$ldap->bind;

my $result;

my $file = "sevt2.csv";
open my $info, $file or die "Could not open $file: $!";

while( my $username = <$info>)  {   
    chomp($username);
    $username=~ tr/\015//d;

	$result = $ldap->search(
    	base   => "ou=active,ou=employees,ou=people,o=google.com",
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

$ldap->unbind;
