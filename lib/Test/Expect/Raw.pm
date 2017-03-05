package Test::Expect::Raw;
use strict;
use warnings;

use parent qw(Expect Test::Builder::Module Exporter);
use Carp qw(croak);

our $Log_Stdout = 0;

my $CLASS = __PACKAGE__;


BEGIN {
    use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

# might call with goto but with expect not worth worrying about cycles
sub _accessor {
    my $accessor_name = shift;
    my $self = shift;

    ${*$self}{ $accessor_name } = $_[0] if @_;
    return ${*$self}{ $accessor_name };
}

=head1 Attributes

=head2 timeout

=cut

sub timeout {
    return _accessor('test_exp_raw_timeout', @_);
}

=head2 prompt

=cut

sub prompt {
    return _accessor('test_exp_raw_prompt', @_);
}

=head2 prompt_test

Boolean attribute controlling whether finding the prompt is a test.  Defaults
to true.

=cut

sub prompt_test {
    return _accessor('test_exp_raw_prompt_test', @_);
} 

=head2 prompt_test_name prompt_add_nl

If you have nothing better to do you can set these to a different value.

=cut

sub prompt_test_name {
    return _accessor('test_exp_raw_prompt_test_name', @_);
} 

sub prompt_add_nl {
    return _accessor('test_exp_raw_prompt_add_nl', @_);
} 




=head1 Methods

#################### subroutine header begin ####################

=head2 expect_like

Gives TAP output based on match pattern against expect handle output.

    $e->expect_like 'hello', 'looking for hello';
  or 
    $e->expect_like qr/hello\s\w+/, 'looking for hello Bob';

Arguments are a match pattern followed by a test name.  The match
pattern can be a string which is matched literally or a regex.  

=cut

# str or '-re' str or qr/str/
sub expect_like {
    my ($self, $match_pattern, $name) = @_;


    my $pat_idx = $self->expect(
        ${*$self}{ test_exp_raw_timeout },
        ref($match_pattern) eq 'Regexp' ?
            [ $match_pattern => sub {} ] : $match_pattern
    );
    return ${*$self}{ test_exp_raw_builder }->is_num($pat_idx, 1, $name);
}

sub expect_lines {
    my ($self, $match_lines, $name) = @_;

    croak 'Call with undefined match_lines likely useless'
        unless (defined $match_lines); 

    $match_lines = [ $match_lines ]
        if ref($match_lines) eq '' and defined $match_lines;
    
    @$match_lines = map { ref($_) eq 'Regexp' ? $_ : quotemeta $_ }
        @$match_lines;
    my $last_line = pop @$match_lines;
    my $match_lines_qr = join '',
        map { "^ $_" . '\r? $ \v' } @$match_lines;
    $match_lines_qr = ($match_lines_qr // '') . "^ $last_line" . '\r? $';

    my $pat_idx = $self->expect(
        ${*$self}{ test_exp_raw_timeout },
        [ qr/$match_lines_qr/xm => sub {} ]
    );
    return ${*$self}{ test_exp_raw_builder }->is_num($pat_idx, 1, $name);
}

sub prompt_reply {
    my ($self, $reply, $alt_prompt) = @_;

    my $prompt = $alt_prompt // ${*$self}{ test_exp_raw_prompt };
    my $pat_idx = $self->expect(
        ${*$self}{ test_exp_raw_timeout },
        $prompt, ref($prompt) eq 'Regexp' ? sub {} : ()
    );

    ${*$self}{ test_exp_raw_builder }->is_num(
        $pat_idx, 1, ${*$self}{ test_exp_raw_prompt_test_name }
    ) if ${*$self}{ test_exp_raw_prompt_test };

    if ($pat_idx) {
        if (${*$self}{ test_exp_raw_prompt_add_nl }) {
            # approx $reply =~ s&(?:^|(?!$/).)$&$/&; but not worth trouble
            chomp($reply);
            $reply .= $/;
        }
        $self->send($reply);
        return 1;
    }
    return;
}

sub expect_prompt_reply_like {
    my ($self, $reply, $match_pattern, $name, $alt_prompt) = @_;

    if ($self->prompt_reply($reply, $alt_prompt)) {
        return $self->expect_like($match_pattern, $name);
    }

    return;
}

sub expect_prompt_reply_lines {
    my ($self, $reply, $match_lines, $name, $alt_prompt) = @_;

    if ($self->prompt_reply($reply, $alt_prompt)) {
        return $self->expect_lines($match_lines, $name);
    }

    return;
}

#################### subroutine header end ####################


=head2 new

Constructor based in part on Expect constructor

    Test::Expect::Raw->new(Timeout => 10); 
  or
    Test::Expect::Raw->new(Timeout => 10, Command => 'echo hello'); 

=head3 parameters

=over

=item Timeout

The (optional) default timeout that will be used by expect and
expect_..._like test calls.

=item Command or Cmd

The (optional) command that would be passed as the first parameter
to the Expect constructor.  Since we inherit from Expect you can also
just call B<spawn> later.

=item Parameters

The (optional) list of parameters that would be passed after the
command to the Expect constructor.  Again you can also B<spawn>.  The
parameters value is a reference to the list of parameters.

=item prompt

Expect testing may work against an application that gives a prompt
before processing some input.  In such cases setting an initial prompt
or setting a prompt value will be used by L</expect_prompt_reply_like> and
L</expect_prompt_reply_lines_like>.

Todo rws check these pod links.

=item log_stdout or log_user

Default is off so no logging of stdout but you can set to on.

=back

=cut

sub new {
    my ($class, %parameters) = @_;

    # with gratitude to http://www.perlmonks.org/?node_id=384761
    $parameters{ lc $_ } = delete $parameters{ $_ }
        foreach keys %parameters;
    $parameters{ command } = $parameters{ cmd }
        if exists $parameters{ cmd } and not exists $parameters{ command };

    my @cmd = (
        ref($parameters{ command }) eq 'ARRAY' ?
            @{ $parameters{ command } } : $parameters{ command },
        @{ $parameters{ parameters } || [] }
    ) if exists $parameters{ command };
    my $self = Expect->new(@cmd);
    bless $self, ref ($class) || $class;

    ${*$self}{ test_exp_raw_timeout } = $parameters{ timeout };
    ${*$self}{ test_exp_raw_prompt } = $parameters{ prompt };
    ${*$self}{ test_exp_raw_prompt_test } = 1;
    ${*$self}{ test_exp_raw_prompt_add_nl } = 1;
    ${*$self}{ test_exp_raw_builder } = $CLASS->builder;
    ${*$self}{ test_exp_raw_prompt_test_name } = 'got prompt';
    $self->log_stdout(
        $parameters{ log_stdout } // $parameters{ log_user } // $Log_Stdout
    );

    return $self;
}

=head1 Configurable Package Variables:

=head2 $Test::Expect::Raw::Log_Stdout

=cut

#################### main pod documentation begin ###################


=head1 NAME

Test::Expect::Raw - TAP testing for the Expect module

=head1 SYNOPSIS

  use Test::Expect::Raw;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

The idea here is to extend the Perl implementation of Expect to facilitate
TAP Perl style testing.  I justify the implementation of 'Test' functions
as methods based on extending Expect rather than writing a Test module
that happens to use it.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    Ronald Schmidt
    CPAN ID: RONALDWS
    The Software Path
    ronaldxs@software-path.com
    http://www.software-path.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).
See also Test::Builder, Expect, Expect::Simple, Test::Expect, Test::Command

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

