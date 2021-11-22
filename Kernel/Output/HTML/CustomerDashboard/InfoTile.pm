# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2021 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --

package Kernel::Output::HTML::CustomerDashboard::InfoTile;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::CustomerDashboard::InfoTile',
    'Kernel::System::Log',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    if ( !$Param{UserID} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message => 'Need UserID!',
        );
        return;
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $InfoTileObject = $Kernel::OM->Get('Kernel::System::CustomerDashboard::InfoTile');

    my $InfoTileEntries = $InfoTileObject->InfoTileListGet(
        'UserID' => $Param{UserID},
    );
    
    my $InfoTileListHTML;

    for my $ID ( keys %{$InfoTileEntries} ) {
        $InfoTileListHTML .= $LayoutObject->Output(
            Template => '<div><p>[% Data.Content %]</p></div>',
            Data => $InfoTileEntries->{$ID},
        );
    }

    my $Content = $Kernel::OM->Get('Kernel::Output::HTML::Layout')->Output(
        TemplateFile => 'Dashboard/TileInfoEntries',
        Data => {
            TileID => $Param{TileID},
            InfoTileListHTML => $InfoTileListHTML,
            %{ $Param{Config} },
        },
    );

    return $Content;

}

1;
