use strict;
use warnings;
package Sub::Exporter::GlobExporter;
# ABSTRACT: export shared globs with Sub::Exporter collectors

use Scalar::Util ();

use Sub::Exporter -setup => [ qw(glob_exporter) ];

my $is_ref;
BEGIN {
  $is_ref = sub {
    return(
      !  Scalar::Util::blessed($_[0])
      && Scalar::Util::reftype($_[0]) eq $_[1]
    );
  };
}

sub glob_exporter {
  my ($default_name, $globref) = @_;

  my $globref_method = $is_ref->($globref, 'GLOB')   ? sub { $globref }
                     : $is_ref->($globref, 'SCALAR') ? $$globref
                     : Carp::confess("illegal glob locator '$globref'");

  return sub {
    my ($value, $data) = @_;
    my $globref = $data->{class}->$globref_method;

    my $name;
    $name = defined $value->{'-as'} ? $value->{'-as'} : $default_name;

    my $sym = "$data->{into}::$name";

    {
      no strict 'refs';
      *{$sym} = *$globref;
    }

    $_[0] = $globref;
    return 1;
  }
}

1;
