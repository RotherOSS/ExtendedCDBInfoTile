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

    my $ParamObject                     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject                    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CustomerDashboardInfoTileObject = $Kernel::OM->Get('Kernel::System::CustomerDashboard::InfoTile');
    my $HTMLUtilsObject                 = $Kernel::OM->Get('Kernel::System::HTMLUtils');

    if ( $Self->{Subaction} eq 'InfoTile' ) {

        my $InfoTileContent = '';
        my $InfoTiles       = $CustomerDashboardInfoTileObject->InfoTileListGet(
            UserID => $Self->{UserID},
        );

        if ($InfoTiles) {

            # sort info tiles, sorting order: config order, start date, changed date, created date
            my @Tiles       = values %{$InfoTiles};
            my @TilesSorted = $Self->_OrderTiles( Tiles => \@Tiles );

            my $CurrentDate = $Kernel::OM->Create('Kernel::System::DateTime');

            for my $InfoTileRef (@TilesSorted) {
                my %InfoTile = %{$InfoTileRef};
                my $StartDate;
                if ( $InfoTile{StartDateUsed} ) {
                    $StartDate = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            String => $InfoTile{StartDate}
                        }
                    );
                }
                my $StopDate;
                if ( $InfoTile{StopDateUsed} ) {
                    $StopDate = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            String => $InfoTile{StopDate}
                        }
                    );
                }

                print STDERR "CustomerDashboardContent.pm, L.80: " . $CurrentDate->ToString() . "\n";
                print STDERR "CustomerDashboardContent.pm, L.81: " . $StopDate->ToString() . "\n";

                if (
                    ( ( $StartDate && $CurrentDate->Compare( DateTimeObject => $StartDate ) > 0 ) || !$StartDate )
                    && ( ( $StopDate && $StopDate->Compare( DateTimeObject => $CurrentDate ) > 0 ) || !$StopDate )
                    && $InfoTile{ValidID} eq '1'
                    )
                {
                    $InfoTileContent .= $InfoTile{Content} . "<br>";
                }
            }
        }

        my $Content = $HTMLUtilsObject->DocumentComplete(
            String  => $InfoTileContent,
            Charset => 'utf-8',
        );

        return $LayoutObject->Attachment(
            Type        => 'inline',
            ContentType => 'text/html',
            Content     => $Content,
        );
    }
}

sub _OrderTiles {

    my ( $Self, %Param ) = @_;

    my @Tiles        = @{ $Param{Tiles} };
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $UsedTiles      = $ConfigObject->Get('CustomerDashboard::Tiles');
    my $TileConfig     = $UsedTiles->{'InfoTile-01'}->{Config};
    my %TileEntryOrder = %{ $TileConfig->{Order} };
    my @Result;
    my @DateSort;
    for my $TileRef (@Tiles) {
        my %Tile = %{$TileRef};
        if ( $TileEntryOrder{ $Tile{ID} } ) {
            $Tile{Order} = $TileEntryOrder{ $Tile{ID} };
            push @Result, \%Tile;
        }
        else {
            push @DateSort, \%Tile;
        }
    }
    @Result   = sort { $a->{Order} cmp $b->{Order} } @Result;
    @DateSort = sort _ByDates @DateSort;

    push @Result, @DateSort;

    return @Result;

}

sub _ByDates {

    # get date objects for $a
    my $AStartDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $a->{StartDate}
        }
    );
    my $AChangedDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $a->{Changed}
        }
    );
    my $ACreatedDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $a->{Created}
        }
    );

    # get date objects for $b
    my $BStartDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $b->{StartDate}
        }
    );
    my $BChangedDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $b->{Changed}
        }
    );
    my $BCreatedDate = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $b->{Created}
        }
    );

    if ( $BStartDate->Compare( DateTimeObject => $AStartDate ) == 0 ) {
        if ( defined $AChangedDate && defined $BChangedDate ) {
            if ( $BChangedDate->Compare( DateTimeObject => $AChangedDate ) == 0 ) {
                return $BCreatedDate->Compare( DateTimeObject => $ACreatedDate );
            }
            else {
                return $BChangedDate->Compare( DateTimeObject => $AChangedDate );
            }
        }
        else {
            return $BCreatedDate->Compare( DateTimeObject => $ACreatedDate );
        }
    }
    else {
        return $BStartDate->Compare( DateTimeObject => $AStartDate );
    }

}

1;
