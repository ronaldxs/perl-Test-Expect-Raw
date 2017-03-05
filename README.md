# NAME

Test::Expect::Raw - TAP testing for the Expect module

# SYNOPSIS

    use Test::Expect::Raw;
    blah blah blah

# DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

The idea here is to extend the Perl implementation of Expect to facilitate
TAP Perl style testing.  I justify the implementation of 'Test' functions
as methods based on extending Expect rather than writing a Test module
that happens to use it.

# Attributes

## timeout

## prompt

## prompt\_test

Boolean attribute controlling whether finding the prompt is a test.  Defaults
to true.

## prompt\_test\_name prompt\_add\_nl

If you have nothing better to do you can set these to a different value.

# Methods

\#################### subroutine header begin ####################

## expect\_like

Gives TAP output based on match pattern against expect handle output.

      $e->expect_like 'hello', 'looking for hello';
    or 
      $e->expect_like qr/hello\s\w+/, 'looking for hello Bob';

Arguments are a match pattern followed by a test name.  The match
pattern can be a string which is matched literally or a regex.  

## new

Constructor based in part on Expect constructor

      Test::Expect::Raw->new(Timeout => 10); 
    or
      Test::Expect::Raw->new(Timeout => 10, Command => 'echo hello'); 

### parameters

- Timeout

    The (optional) default timeout that will be used by expect and
    expect\_...\_like test calls.

- Command or Cmd

    The (optional) command that would be passed as the first parameter
    to the Expect constructor.  Since we inherit from Expect you can also
    just call **spawn** later.

- Parameters

    The (optional) list of parameters that would be passed after the
    command to the Expect constructor.  Again you can also **spawn**.  The
    parameters value is a reference to the list of parameters.

- prompt

    Expect testing may work against an application that gives a prompt
    before processing some input.  In such cases setting an initial prompt
    or setting a prompt value will be used by ["expect\_prompt\_reply\_like"](#expect_prompt_reply_like) and
    ["expect\_prompt\_reply\_lines\_like"](#expect_prompt_reply_lines_like).

    Todo rws check these pod links.

- log\_stdout or log\_user

    Default is off so no logging of stdout but you can set to on.

# Configurable Package Variables:

## $Test::Expect::Raw::Log\_Stdout

# USAGE

# BUGS

# SUPPORT

# AUTHOR

    Ronald Schmidt
    CPAN ID: RONALDWS
    The Software Path
    ronaldxs@software-path.com
    http://www.software-path.com

# COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

# SEE ALSO

perl(1).
See also Test::Builder, Expect, Expect::Simple, Test::Expect, Test::Command
