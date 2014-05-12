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

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Capulcu::Bot',
    AUTHOR              => q{Onur Aslan <onuraslan@gmail.com>},
    VERSION_FROM        => 'lib/Capulcu/Bot.pm',
    ABSTRACT            => 'Capulcu Bot',
    LICENSE             => 'GPLv2',
    PL_FILES            => {},
    PREREQ_PM => {
        'AppConfig'     => 0,
        'Bot::BasicBot' => 0,
        # SSL option requires POE::Component::SSLify
        'POE::Component::SSLify' => 0
    },
    EXE_FILES           => [ 'bin/capulcu' ],
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Capulcu-Bot-*' },
);
