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

package Kernel::Modules::CustomerDashboardContent;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerDashboardInfoTileObject = $Kernel::OM->Get('Kernel::System::CustomerDashboard::InfoTile');

    if ( $Self->{Subaction} eq 'InfoTile' ) {
       
        my $InfoTileContent = ''; 
        my $InfoTiles = $CustomerDashboardInfoTileObject->InfoTileListGet(
            UserID => $Self->{UserID},
        );

        if ( $InfoTiles ) {
        
            for my $Key ( keys %{$InfoTiles} ) {
                my %InfoTile = %{$InfoTiles->{$Key}};
                $InfoTileContent .= $InfoTile{Content} . "<br>";    
            }

        }

        my $Content = $LayoutObject->Output(
            Template => '[% Data.HTML %]',
            Data =>  {
                HTML => $InfoTileContent
            }
        );

        my %Data = (
            Content => $Content,
            ContentAlternative => '',
            ContentID => '',
            ContentType => 'text/html; charset="utf-8"',
            Disposition => "inline",
            FileSizeRaw => btyes::length($Content),
        );

    }
}
