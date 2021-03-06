package Devel::hdb::App::Config;

use strict;
use warnings;

use base 'Devel::hdb::App::Base';

our $VERSION = '0.25';

__PACKAGE__->add_route('post', qr{/loadconfig/(.+)}, \&loadconfig);
__PACKAGE__->add_route('post', qr{/saveconfig/(.+)}, \&saveconfig);

sub loadconfig {
    my($class, $app, $env, $file) = @_;

    local $@;
    my $settings = eval { $app->load_settings_from_file($file) };
    if ($@) {
        return [ 400,
                [ 'Content-Type' => 'text/plain' ],
                [ $@ ] ];

    } elsif ($settings) {
        return [ 200,
                ['Content-Type' => 'application/json'],
                [ $app->encode_json($settings) ] ];
    } else {
        return [ 404,
                [ 'Content-Type' => 'text/plain' ],
                [ "File $file not found" ] ];
    }
}

sub saveconfig {
    my($class, $app, $env, $file) = @_;

    my $body = $class->_read_request_body($env);
    my $additional = $app->decode_json($body);

    local $@;
    $file = eval { $app->save_settings_to_file($file, $additional) };
    if ($@) {
        return [ 400,
                [ 'Content-Type' => 'text/html' ],
                [ "Problem saving $file: $@" ] ];
    } else {
        return [ 204, [], [] ];
    }
}

1;

=pod

=head1 NAME

Devel::hdb::App::Config - Load and save debugger configuration

=head2 Routes

=over 4

=item POST /saveconfig/<filename>

Save debugger configuration to the given file.  Breakpoint and
line-actions are saved.

=item POST /loadconfig/<filename>

Loads debugger configuration from the given file.  Breakpoint and
line-actions are restored.

=back


=head1 SEE ALSO

L<Devel::hdb>

=head1 AUTHOR

Anthony Brummett <brummett@cpan.org>

=head1 COPYRIGHT

Copyright 2018, Anthony Brummett.  This module is free software. It may
be used, redistributed and/or modified under the same terms as Perl itself.
