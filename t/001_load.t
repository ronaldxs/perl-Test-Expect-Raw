# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Test::Expect::Raw' ); }

my $object = Test::Expect::Raw->new ();
isa_ok ($object, 'Test::Expect::Raw');


