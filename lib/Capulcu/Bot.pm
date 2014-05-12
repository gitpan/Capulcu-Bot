##########################################################################
# Capulcu - IRC Bot                                                      #
# Copyright (C) <2013>  Onur Aslan  <onuraslan@gmail.com>                #
#                                                                        #
# This program is free software: you can redistribute it and/or modify   #
# it under the terms of the GNU General Public License as published by   #
# the Free Software Foundation, either version 3 of the License, or      #
# (at your option) any later version.                                    #
#                                                                        #
# This program is distributed in the hope that it will be useful,        #
# but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          #
# GNU General Public License for more details.                           #
#                                                                        #
# You should have received a copy of the GNU General Public License      #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.  #
##########################################################################

package Capulcu::Bot;

use strict;
use warnings;
use Exporter 'import';
use base qw/Bot::BasicBot/;
use AppConfig qw/:argcount/;


our $VERSION = '0.1';
our @EXPORT_OK = qw/add_help join_func match_func capulcu say_something
                    connect_func get_config/;


my $config;
my $bot;
my $help;


my $connected_functions = [];
my $match_functions = [];
my $join_functions = [];


sub parse_config {
  my $config_file = $_[0] || "$ENV{HOME}/.capulcu/config";
  my @conf_variables = qw/server port channels nick alt_nicks username name
                          plugins nick_passwd ssl/;
  $config = AppConfig->new ({CASE   => 1,
                             GLOBAL => { 
                               DEFAULT  => "", 
                               ARGCOUNT => ARGCOUNT_ONE,
                             }});
  $config->define (@conf_variables);
  $config->file ($config_file);
}


sub get_config {
  return $config->get ($_[0]);
}

sub load_plugins {
  for (split / /, $config->plugins) {
    eval "require Capulcu::Plugin::$_";
  }
}


sub make_bot {
  $bot = Capulcu::Bot->new (
    server => $config->server,
    port   => $config->port,
    ssl    => $config->ssl,
    channels => [ split / /, $config->channels ],
    nick      => $config->nick,
    alt_nicks => [ split / /, $config->alt_nicks ],
    username  => $config->username,
    name      => $config->name
  );
  $bot->run;
  return $bot;
}


sub said {
  my ($self, $message) = @_;
  my $output = '';
  if ($message->{raw_body} =~ /^.help/) {
    return show_help ($message->{body});
  }
  for (@{$match_functions}) {
    if ($message->{raw_body} =~ /$_->{match}/) {
      $output .= $_->{func}->($message);
    }
  }
  return $output;
}


sub chanjoin {
  my ($self, $message) = @_;
  my $output = '';
  for (@{$join_functions}) {
    $output .= $_->($message);
  }
  return $output;
}


sub match_func {
  push @{$match_functions}, { match => $_[0],
                              func  => $_[1] };
}

sub join_func {
  push @{$join_functions}, $_[0];
}


sub show_help {
  my $message = $_[0];
  my $output = '';
  $message =~ s/^.help\s*//;
  if (!$message || $message =~ /^\s+$/) {
    $output .= 'Commands:';
    for (@{$help}) {
      $output .= ' ' . $_->{cmd};
    }
    return $output;
  } else {
    for (@{$help}) {
      if ($message =~ /^$_->{cmd}$/) {
        return $_->{cmd} . ': ' . $_->{msg};
      }
    }
  }
}

sub add_help {
  push @{$help}, { cmd => $_[0],
                   msg => $_[1] };
}


sub identify {
  $bot->say (who => 'NickServ',
             channel => 'msg',
             body => 'identify ' . $config->nick_passwd)
    if $config->nick_passwd;
}


sub say_something {
  $bot->say (@_);
}

sub connected {
  identify ();
  $_->() for (@{$connected_functions});
}

sub connect_func {
  push @{$connected_functions}, $_[0];
}

sub capulcu {
  parse_config ();
  load_plugins ();
  return make_bot ();
}


1;


__END__

=head1 NAME

Capulcu::Bot - Highly modular IRC bot

=head1 SYNOPSIS

  use Capulcu::Bot qw/capulcu/;
  capulcu;

=head1 DESCRIPTION

Capulcu::Bot or simply capulcu is a highly modular IRC bot. It's a simple
and powerful bot. It's using Bot::BasicBot. Copy config.example to
~/.capulcu/config and start using bot.

Writing plugins is easy. Let's say you want to reply someone when he
says !hello. Make a perl module named Capulcu::Plugin::Hello.

  package Capulcu::Plugin::Hello;
  use Capulcu::Bot qw/match_func/;

  sub say_hello {
    return 'Hello';
  }

  match_func ('^!hello', \&say_hello);


That's it! Make sure to add this plugin to your config file. Capulcu will
say hello when someone write !hello.

Let's say you want to say hello when someone join channel. It's simple
just add join_func to your script and use it like this:

  package Capulcu::Plugin::Hello;
  use Capulcu::Bot qw/join_func/;

  sub say_hello {
    return 'Hello';
  }

  join_func (\&say_hello);

See it's simple. Capulcu is providing a complete abstraction.

Exportable functions:

=over 3

=item add_help

Add help to a commands. It's usually using after match_func. Example:

  add_help ('!hello', 'Say hello');

People can get help items with .help command. This is only builtin command
in this bot. '.help' will list available help topics and when user use
'.help !hello' he will get it's description: 'Say hello'.

=item join_func

Codeblock will run when someone joined the channel. It takes only one
parameter, ref to codeblock.

=item match_func

Codeblock will run when match. It takes two parameter, first one is regex
and second one ref to codeblock. Example:

  match_func ('^!hello', \&say_hello);

When someone say !hello it will run codeblock pointed to say_hello.

=item connect_func

Codeblock will run when bot successfully connected to server.

=item get_config

Get some configuration value. Example:

  get_config ('nick');

=item say_something

Say something to someone. It requires a hash with who, channel and body keys.
Example:

  say_something (who => 'NickServ',
                 channel => 'msg',
                 body => 'identify mypassword');

This will identify bot (Note: capulcu already have a built in identify
function).

=back

=head1 COPYRIGHT

  Copyright 2013, Onur Aslan  <onuraslan@gmail.com>


This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

=head1 AVAILABILITY

The latest version of this library is likely to be available from CPAN
as well as:

  https://github.com/onuraslan/capulcu

Checkout deve branch for some cool plugins.

=cut
