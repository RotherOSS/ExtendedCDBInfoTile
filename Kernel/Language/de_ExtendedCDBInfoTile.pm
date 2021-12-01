# --
# OTOBO is a web-based ticketing system for service organisations.
# --
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

package Kernel::Language::de_ExtendedCDBInfoTile;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # $$START$$

    # own translations
    $Self->{Translation}->{'Customer Dashboard Info Tile'} = 'Info-Kachel Kunden-Dashboard';
    $Self->{Translation}->{'Create new info tile entry'}   = 'Neuen Info-Kachel-Eintrag erstellen';
    $Self->{Translation}->{'Filter for info tile entries'} = 'Filter fuer die Info-Kachel-Eintraege';
    $Self->{Translation}->{'Create a new entry to be displayed on the info tile on the customer dashboard.'}
        = 'Erstellen Sie einen neuen Info-Kachel-Eintrag fuer die Info-Kachel auf dem Kunden-Dashboard.';
    $Self->{Translation}->{'Customer Dashboard Info Tile Management'}          = 'Kunden-Dashboard-Info-Kachel-Verwaltung';
    $Self->{Translation}->{'Edit customer dashboard info tile entry'}          = 'Info-Kachel-Eintrag bearbeiten';
    $Self->{Translation}->{'Start date shouldn\'t be defined afer Stop date!'} = 'Das Startdatum muss vor dem Enddatum liegen!';
    $Self->{Translation}->{'Name is missing!'}                                 = 'Name fehlt!';
    $Self->{Translation}->{'Content is missing!'}                              = 'Inhalt fehlt!';
    $Self->{Translation}->{'ValidID is missing!'}                              = 'ValidID fehlt!';
    $Self->{Translation}->{'Group is missing!'}                                = 'Gruppenauswahl fehlt!';
    $Self->{Translation}->{'There was an error creating the info tile entry'}  = 'Beim Erstellen des Info-Kachel-Eintrags ist ein Problem aufgetreten';
    $Self->{Translation}->{'This Entry does not exist, or you don\'t have permissions to access it in its current state.'}
        = 'Der Eintrag existiert nicht, oder Sie haben nicht die notwendigen Berechtigungen, um ihn in seiner aktuellen Konfiguration aufzurufen.';
    $Self->{Translation}->{'Could not get data for ID'}                           = 'Die Daten fuer folgende ID konnten nicht abgerufen werden: ';
    $Self->{Translation}->{'Info tile entry was added successfully!'}             = 'Info-Kachel-Eintrag wurde erfolgreich erstellt!';
    $Self->{Translation}->{'Info tile entry was updated successfully!'}           = 'Info-Kachel-Eintrag wurde erfolgreich bearbeitet!';
    $Self->{Translation}->{'Session has been killed!'}                            = 'Die Session wurde beendet!';
    $Self->{Translation}->{'All sessions have been killed, except for your own.'} = 'Alle Sessions wurden beendet bis auf Ihre eigene.';
    $Self->{Translation}->{'There was an error updating the info tile entry'}     = 'Beim Bearbeiten des Info-Kachel-Eintrags ist ein Problem aufgetreten';
    $Self->{Translation}->{'No Customer Dashboard Info Tile ID'}                  = 'Es konnte kein Info-Kachel-Eintrag mit folgender ID gefunden werden: ';
    $Self->{Translation}->{'It was not possible to delete the info tile entry'}   = 'Der Info-Kachel-Eintrag konnte nicht geloescht werden';
    $Self->{Translation}->{'Manage Customer Dashboard Info Tile Entries'}         = 'Verwaltung der Info-Kachel-Eintraege fuer das Kunden-Dashboard';

    # or an other syntax would be
    #    $Self->{Translation} = {
    #        %{$Self->{Translation}},
    #        # own translations
    #        'Lock' => 'Lala',
    #        'Unlock' => 'Lulu',
    #    };

    # $$STOP$$

    return;
}

1;
