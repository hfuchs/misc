#!/usr/bin/perl
# 2011-11-04, Created by Hagen Fuchs <hagen.fuchs@physik.tu-dresden.de>
#
# Purpose: ClusterSSH does not deal well with compound commands as
# handed to the '-a' flag, eg.
#
#   cssh [remote_server] -a "cd /; ls; sleep 10"
#
# The directory listed will be the local working directory, /not/ the
# remote root directory.  This file is a working example that exhibits
# the precise same behaviour.  Almost all of the code here has been
# pasted and shortened to its essence from App/ClusterSSH.pm (in
# /usr/share/perl5 on my system).  That makes it slightly longer than
# strictly necessary but code here can now easily be matched with code
# in the ClusterSSH module.
#
# Looking at the eval()ed and exec()ed strings below, one can easily see
# how appropriate quoting will break the expression in $helper_script.
# Eg. trying to protect the inner expression with single quotes,
#
#   cssh [remote_server] -a "'cd /; ls; sleep 10'"
#
# or
#
#   perl cluster_test.pl [remote_server] -a "'cd /; ls; sleep 20'"
#
# will spectacularly fail.  On the other hand, an expression like
#
#   perl cluster_test.pl [remote_server] -a "\\\"cd /; ls; sleep 20\\\""
#
# works as it transports both backslashes and quotes safely through
# two layers of string interpolation (first Perl's, then the shell's).
# This translates straightforward into
#
#   cssh [cluster] -a "\\\"cd /; ls; sleep 10\\\""
#
#
# Proposed Solution:
# ------------------
# Naïvely, I'd say substitute $config{command} in $helper_script with
# the unwieldy construct
#
#   \\\"$config{command}\\\"
#
# and be done with it.  But deep down I'd know: this whole part needs
# more thought and less brittle quoting magic.



use common::sense;  # Where else, if not here?  ;)
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case bundling no_auto_abbrev);

my @options_spec = ( 'action|a=s' );
my %options;
my %config;

pod2usage( -verbose => 1 )
        if ( !GetOptions( \%options, @options_spec ) );

$config{command} = $options{action} if ( $options{action} );

my @servers = @ARGV;

my $helper_script = <<"HERE";
my \$command = "ssh $servers[0]";
\$command .= " \\\"$config{command}\\\" || sleep 5";
exec(\$command);
HERE
#eval $helper_script || die ($@);
my $exec = "xterm -e \"$^X\" \"-e\" '$helper_script'";

# hfuchs| Diagnostics (not in ClusterSSH).
say "---- Helper Script:";
say $helper_script;
say "---- Exec Line:";
say $exec;

exec($exec) == 0 or die $!;

