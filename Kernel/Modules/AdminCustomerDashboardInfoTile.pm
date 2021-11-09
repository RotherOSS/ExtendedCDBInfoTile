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

package Kernel::Modules::AdminCustomerDashboardInfoTile;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
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

    my $LayoutObject            = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject             = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $SessionObject           = $Kernel::OM->Get('Kernel::System::AuthSession');
    my $CustomerDashboardInfoTileObject = $Kernel::OM->Get('Kernel::System::CustomerDashboard::InfoTile');

    my $InfoTileID = $ParamObject->GetParam( Param => 'InfoTileID' ) || '';
    
    print STDERR "AdminCustomerDashboardInfoTile.pm, L.48: " . $InfoTileID . "\n";
        

    my $WantSessionID       = $ParamObject->GetParam( Param => 'WantSessionID' )       || '';

    my $SessionVisibility = 'Collapsed';

    # ------------------------------------------------------------ #
    # kill session id
    # ------------------------------------------------------------ #
    if ( $Self->{Subaction} eq 'Kill' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        $SessionObject->RemoveSessionID( SessionID => $WantSessionID );
        return $LayoutObject->Redirect(
            OP =>
                "Action=AdminCustomerDashboardInfoTile;Subaction=CustomerDashboardInfoTileEdit;InfoTileID=$InfoTileID;Kill=1"
        );
    }

    # ------------------------------------------------------------ #
    # kill all session ids
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'KillAll' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        my @Sessions = $SessionObject->GetAllSessionIDs();
        SESSIONS:
        for my $Session (@Sessions) {
            next SESSIONS if $Session eq $WantSessionID;
            $SessionObject->RemoveSessionID( SessionID => $Session );
        }

        return $LayoutObject->Redirect(
            OP =>
                "Action=AdminCustomerDashboardInfoTile;Subaction=CustomerDashboardInfoTileEdit;InfoTileID=$InfoTileID;KillAll=1"
        );
    }

    # ------------------------------------------------------------ #
    # CustomerDashboardInfoTileNew
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'CustomerDashboardInfoTileNew' ) {

        return $Self->_ShowEdit(
            %Param,
            Action => 'New',
        );
    }

    # ------------------------------------------------------------ #
    # CustomerDashboardInfoTileNewAction
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'CustomerDashboardInfoTileNewAction' ) {


        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # check required parameters
        my %Error;
        my @NotifyData;

        # get CustomerDashboardInfoTile parameters from web browser
        my $CustomerDashboardInfoTileData = $Self->_GetParams(
            Error => \%Error,
        );

        # a StartDate should always be defined before StopDate
        if (
            (
                defined $CustomerDashboardInfoTileData->{StartDate}
                && defined $CustomerDashboardInfoTileData->{StopDate}
            )
            && $CustomerDashboardInfoTileData->{StartDate} > $CustomerDashboardInfoTileData->{StopDate}
            )
        {

            # set server error
            $Error{StartDateServerError} = 'ServerError';

            # add notification
            push @NotifyData, {
                Priority => 'Error',
                Info     => Translatable('Start date shouldn\'t be defined after Stop date!'),
            };
        }

        if ( !$CustomerDashboardInfoTileData->{Heading} ) {

            # add server error class
            $Error{HeadingServerError} = 'ServerError';

        }

        if ( !$CustomerDashboardInfoTileData->{Content} ) {

            # add server error class
            $Error{ContentServerError} = 'ServerError';
        
        }

        if ( !$CustomerDashboardInfoTileData->{ValidID} ) {

            # add server error class
            $Error{ValidIDServerError} = 'ServerError';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {

            return $Self->_ShowEdit(
                %Error,
                %Param,
                NotifyData            => \@NotifyData,
                CustomerDashboardInfoTileData => $CustomerDashboardInfoTileData,
                Action                => 'New',
            );
        }

        my $InfoTileID = $CustomerDashboardInfoTileObject->InfoTileAdd(
            StartDate        => $CustomerDashboardInfoTileData->{StartDate},
            StartDateYear   => $CustomerDashboardInfoTileData->{StartDateYear},
            StartDateMonth  => $CustomerDashboardInfoTileData->{StartDateMonth},
            StartDateDay    => $CustomerDashboardInfoTileData->{StartDateDay},
            StartDateHour   => $CustomerDashboardInfoTileData->{StartDateHour},
            StartDateMinute => $CustomerDashboardInfoTileData->{StartDateMinute},
            StopDate         => $CustomerDashboardInfoTileData->{StopDate},
            StopDateYear    => $CustomerDashboardInfoTileData->{StopDateYear},
            StopDateMonth   => $CustomerDashboardInfoTileData->{StopDateMonth},
            StopDateDay     => $CustomerDashboardInfoTileData->{StopDateDay},
            StopDateHour    => $CustomerDashboardInfoTileData->{StopDateHour},
            StopDateMinute  => $CustomerDashboardInfoTileData->{StopDateMinute},
            Heading          => $CustomerDashboardInfoTileData->{Heading},
            Content          => $CustomerDashboardInfoTileData->{Content},
            Permission       => $CustomerDashboardInfoTileData->{Permission},
            ValidID          => $CustomerDashboardInfoTileData->{ValidID},
            UserID           => $Self->{UserID},
        );

        # show error if can't create
        if ( !$InfoTileID ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('There was an error creating the System Maintenance'),
            );
        }

        # redirect to edit screen
        if (
            defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
            && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
            )
        {
            return $LayoutObject->Redirect(
                OP =>
                    "Action=$Self->{Action};Subaction=CustomerDashboardInfoTileEdit;InfoTileID=$InfoTileID;Notification=Add"
            );
        }
        else {
            return $LayoutObject->Redirect( OP => "Action=$Self->{Action};Notification=Add" );
        }
    }

    # ------------------------------------------------------------ #
    # Edit View
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'CustomerDashboardInfoTileEdit' ) {

        # initialize notify container
        my @NotifyData;

        # check for InfoTileID
        if ( !$InfoTileID ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('Need InfoTileID!'),
            );
        }

        # get customerdashboard info data
        my $CustomerDashboardInfoTileData = $CustomerDashboardInfoTileObject->InfoTileGet(
            InfoTileID     => $InfoTileID,
            UserID => $Self->{UserID},
        );

        # include time stamps on the correct key
        for my $Key (qw(StartDate StopDate)) {

            # try to convert to TimeStamp
            my $DateTimeObject = $Kernel::OM->Create(
                'Kernel::System::DateTime',
                ObjectParams => {
                    String => $CustomerDashboardInfoTileData->{$Key},
                }
            );
            $CustomerDashboardInfoTileData->{ $Key . 'TimeStamp' } =
                $DateTimeObject ? $DateTimeObject->ToString() : undef;
        }

        # check for valid tomerdashboard infodata
        if ( !IsHashRefWithData($CustomerDashboardInfoTileData) ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}->Translate(
                    'Could not get data for InfoTileID %s',
                    $InfoTileID
                ),
            );
        }

        if ( $ParamObject->GetParam( Param => 'Notification' ) eq 'Add' ) {

            # add notification
            push @NotifyData, {
                Priority => 'Notice',
                Info     => Translatable('Customer Dashboard Info was added successfully!'),
            };
        }

        if ( $ParamObject->GetParam( Param => 'Notification' ) eq 'Update' ) {

            # add notification
            push @NotifyData, {
                Priority => 'Notice',
                Info     => Translatable('Customer Dashboard Info was updated successfully!'),
            };
        }

        if ( $ParamObject->GetParam( Param => 'Kill' ) ) {

            # add notification
            push @NotifyData, {
                Priority => 'Notice',
                Info     => Translatable('Session has been killed!'),
            };

            # set class for expanding sessions widget
            $SessionVisibility = 'Expanded';
        }

        if ( $ParamObject->GetParam( Param => 'KillAll' ) ) {

            # add notification
            push @NotifyData, {
                Priority => 'Notice',
                Info     => Translatable('All sessions have been killed, except for your own.'),
            };

            # set class for expanding sessions widget
            $SessionVisibility = 'Expanded';
        }

        return $Self->_ShowEdit(
            %Param,
            InfoTileID   => $InfoTileID,
            CustomerDashboardInfoTileData => $CustomerDashboardInfoTileData,
            NotifyData            => \@NotifyData,
            SessionVisibility     => $SessionVisibility,
            Action                => 'Edit',
        );

    }

    # ------------------------------------------------------------ #
    # System Maintenance edit action
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'CustomerDashboardInfoTileEditAction' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        # check required parameters
        my %Error;
        my @NotifyData;

        # get CustomerDashboardInfoTile parameters from web browser
        my $CustomerDashboardInfoTileData = $Self->_GetParams(
            Error => \%Error,
        );

        use Data::Dumper;
        print STDERR "AdminCustomerDashboardInfoTile.pm, L.331: " . Dumper($CustomerDashboardInfoTileData);


        # a StartDate should always be defined before StopDate
        if (
            (
                defined $CustomerDashboardInfoTileData->{StartDate}
                && defined $CustomerDashboardInfoTileData->{StopDate}
            )
            && $CustomerDashboardInfoTileData->{StartDate} > $CustomerDashboardInfoTileData->{StopDate}
            )
        {
            $Error{StartDateServerError} = 'ServerError';

            # add notification
            push @NotifyData, {
                Priority => 'Error',
                Info     => Translatable('Start date shouldn\'t be defined after Stop date!'),
            };
        }

        if ( !$CustomerDashboardInfoTileData->{ValidID} ) {

            # add server error class
            $Error{ValidIDServerError} = 'ServerError';
        }

        # if there is an error return to edit screen
        if ( IsHashRefWithData( \%Error ) ) {

            return $Self->_ShowEdit(
                %Error,
                %Param,
                NotifyData            => \@NotifyData,
                InfoTileID   => $InfoTileID,
                CustomerDashboardInfoTileData => $CustomerDashboardInfoTileData,
                Action                => 'Edit',
            );
        }

        print STDERR "AdminCustomerDashboardInfoTile.pm, L.383: Test 2";


        # otherwise update configuration and return to edit screen
        my $UpdateResult = $CustomerDashboardInfoTileObject->InfoTileUpdate(
            StartDate        => $CustomerDashboardInfoTileData->{StartDate},
            StartDateYear   => $CustomerDashboardInfoTileData->{StartDateYear},
            StartDateMonth  => $CustomerDashboardInfoTileData->{StartDateMonth},
            StartDateDay    => $CustomerDashboardInfoTileData->{StartDateDay},
            StartDateHour   => $CustomerDashboardInfoTileData->{StartDateHour},
            StartDateMinute => $CustomerDashboardInfoTileData->{StartDateMinute},
            StopDate         => $CustomerDashboardInfoTileData->{StopDate},
            StopDateYear    => $CustomerDashboardInfoTileData->{StopDateYear},
            StopDateMonth   => $CustomerDashboardInfoTileData->{StopDateMonth},
            StopDateDay     => $CustomerDashboardInfoTileData->{StopDateDay},
            StopDateHour    => $CustomerDashboardInfoTileData->{StopDateHour},
            StopDateMinute  => $CustomerDashboardInfoTileData->{StopDateMinute},
            Heading          => $CustomerDashboardInfoTileData->{Heading},
            Content          => $CustomerDashboardInfoTileData->{Content},
            Permission       => $CustomerDashboardInfoTileData->{Permission},
            ValidID          => $CustomerDashboardInfoTileData->{ValidID},
            UserID           => $Self->{UserID},
            InfoTileID               => $InfoTileID,
        );

        # show error if can't create
        if ( !$UpdateResult ) {
            return $LayoutObject->ErrorScreen(
                Message => Translatable('There was an error updating the System Maintenance'),
            );
        }

        # redirect to edit screen
        if (
            defined $ParamObject->GetParam( Param => 'ContinueAfterSave' )
            && ( $ParamObject->GetParam( Param => 'ContinueAfterSave' ) eq '1' )
            )
        {
            return $LayoutObject->Redirect(
                OP =>
                    "Action=$Self->{Action};Subaction=CustomerDashboardInfoTileEdit;InfoTileID=$InfoTileID;Notification=Update"
            );
        }
        else {
            return $LayoutObject->Redirect( OP => "Action=$Self->{Action};Notification=Update" );
        }

    }

    # ------------------------------------------------------------ #
    # System Maintenance Delete
    # ------------------------------------------------------------ #
    elsif ( $Self->{Subaction} eq 'Delete' ) {

        # challenge token check for write action
        $LayoutObject->ChallengeTokenCheck();

        if ( !$InfoTileID ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Message  => "No System Maintenance ID $InfoTileID",
                Priority => 'error',
            );
        }

        my $Delete = $CustomerDashboardInfoTileObject->InfoTileDelete(
            ID     => $InfoTileID,
            UserID => $Self->{UserID},
        );
        if ( !$Delete ) {
            return $LayoutObject->ErrorScreen(
                Message => $LayoutObject->{LanguageObject}->Translate(
                    'Was not possible to delete the CustomerDashboardInfoTile entry: %s!',
                    $InfoTileID
                ),
            );
        }
        return $LayoutObject->Redirect( OP => 'Action=AdminCustomerDashboardInfoTile' );

    }

    # ------------------------------------------------------------ #
    # else, show system maintenance list
    # ------------------------------------------------------------ #
    else {

        my $CustomerDashboardInfoTileList = $CustomerDashboardInfoTileObject->InfoTileListGet(
            UserID => $Self->{UserID},
        );

        if ( !%{$CustomerDashboardInfoTileList} ) {

            # no data found block
            $LayoutObject->Block(
                Name => 'NoDataRow',
            );
        }
        else {

            for my $InfoTileID ( keys %{$CustomerDashboardInfoTileList} ) {

                my $CustomerDashboardInfoTile = %{$CustomerDashboardInfoTileList}{$InfoTileID};
                
                use Data::Dumper;
                print STDERR "AdminCustomerDashboardInfoTile.pm, L.476: " . Dumper($CustomerDashboardInfoTile) . "\n";
                                

                # set the valid state
                $CustomerDashboardInfoTile->{ValidID} = $Kernel::OM->Get('Kernel::System::Valid')->ValidLookup( ValidID => $CustomerDashboardInfoTile->{ValidID} );

                # include time stamps on the correct key
                for my $Key (qw(StartDate StopDate)) {

                    my $DateTimeObject = $Kernel::OM->Create(
                        'Kernel::System::DateTime',
                        ObjectParams => {
                            String => $CustomerDashboardInfoTile->{$Key},
                        },
                    );
                    $DateTimeObject->ToTimeZone( TimeZone => $Self->{UserTimeZone} );

                    $CustomerDashboardInfoTile->{ $Key . 'TimeStamp' } = $DateTimeObject->ToString();
                }

                # create blocks
                $LayoutObject->Block(
                    Name => 'ViewRow',
                    Data => {
                        %{$CustomerDashboardInfoTile},
                    },
                );
            }
        }

        # generate output
        my $Output = $LayoutObject->Header();
        $Output .= $LayoutObject->NavigationBar();

        if ( ( $ParamObject->GetParam( Param => 'Notification' ) || '' ) eq 'Update' ) {
            $Output .= $LayoutObject->Notify(
                Info => Translatable('System Maintenance was updated successfully!')
            );
        }
        elsif ( ( $ParamObject->GetParam( Param => 'Notification' ) || '' ) eq 'Add' ) {
            $Output .= $LayoutObject->Notify(
                Info => Translatable('System Maintenance was added successfully!')
            );
        }

        $Output .= $LayoutObject->Output(
            TemplateFile => 'AdminCustomerDashboardInfoTile',
        );
        $Output .= $LayoutObject->Footer();
        return $Output;
    }

}

sub _ShowEdit {
    my ( $Self, %Param ) = @_;

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

    # get CustomerDashboardInfoTile information
    my $CustomerDashboardInfoTileData = $Param{CustomerDashboardInfoTileData} || {};

    my %TimeConfig;
    for my $Prefix (qw(StartDate StopDate)) {

        # time setting if available
        if (
            $CustomerDashboardInfoTileData->{ $Prefix . 'TimeStamp' }
            && $CustomerDashboardInfoTileData->{ $Prefix . 'TimeStamp' }
            =~ m{^(\d\d\d\d)-(\d\d)-(\d\d)\s(\d\d):(\d\d):(\d\d)$}xi
            )
        {
            $TimeConfig{$Prefix}->{ $Prefix . 'Year' }   = $1;
            $TimeConfig{$Prefix}->{ $Prefix . 'Month' }  = $2;
            $TimeConfig{$Prefix}->{ $Prefix . 'Day' }    = $3;
            $TimeConfig{$Prefix}->{ $Prefix . 'Hour' }   = $4;
            $TimeConfig{$Prefix}->{ $Prefix . 'Minute' } = $5;
            $TimeConfig{$Prefix}->{ $Prefix . 'Second' } = $6;
        }
    }

    # start date info
    $Param{StartDateString} = $LayoutObject->BuildDateSelection(
        %{$CustomerDashboardInfoTileData},
        %{ $TimeConfig{StartDate} },
        Prefix           => 'StartDate',
        Format           => 'DateInputFormatLong',
        YearPeriodPast   => 0,
        YearPeriodFuture => 1,
        StartDateClass   => $Param{StartDateInvalid} || ' ',
        Validate         => 1,
    );

    # stop date info
    $Param{StopDateString} = $LayoutObject->BuildDateSelection(
        %{$CustomerDashboardInfoTileData},
        %{ $TimeConfig{StopDate} },
        Prefix           => 'StopDate',
        Format           => 'DateInputFormatLong',
        YearPeriodPast   => 0,
        YearPeriodFuture => 1,
        StopDateClass    => $Param{StopDateInvalid} || ' ',
        Validate         => 1,
    );

    # get valid list
    my %ValidList = $Kernel::OM->Get('Kernel::System::Valid')->ValidList();

    $Param{ValidOption} = $LayoutObject->BuildSelection(
        Data       => \%ValidList,
        Name       => 'ValidID',
        SelectedID => $CustomerDashboardInfoTileData->{ValidID} || 1,
        Class      => 'Modernize Validate_Required ' . ( $Param{ValidIDServerError} || '' ),
    );

    if (
        defined $CustomerDashboardInfoTileData->{ShowLoginMessage}
        && $CustomerDashboardInfoTileData->{ShowLoginMessage} == '1'
        )
    {
        $Param{Checked} = 'checked="checked"';
    }

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    # show notifications if any
    if ( $Param{NotifyData} ) {
        for my $Notification ( @{ $Param{NotifyData} } ) {
            $Output .= $LayoutObject->Notify(
                %{$Notification},
            );
        }
    }

    # get all sessions
    my @List     = $SessionObject->GetAllSessionIDs();
    my $Table    = '';
    my $Counter  = @List;
    my %MetaData = ();
    my @UserSessions;
    $MetaData{UserSession}         = 0;
    $MetaData{CustomerSession}     = 0;
    $MetaData{UserSessionUniq}     = 0;
    $MetaData{CustomerSessionUniq} = 0;

    if ( $Param{Action} eq 'Edit' ) {

        for my $SessionID (@List) {
            my $List = '';
            my %Data = $SessionObject->GetSessionIDData( SessionID => $SessionID );
            if ( $Data{UserType} && $Data{UserLogin} ) {
                $MetaData{"$Data{UserType}Session"}++;
                if ( !$MetaData{"$Data{UserLogin}"} ) {
                    $MetaData{"$Data{UserType}SessionUniq"}++;
                    $MetaData{"$Data{UserLogin}"} = 1;
                }
            }

            $Data{UserType} = 'Agent' if ( !$Data{UserType} || $Data{UserType} ne 'Customer' );

            # store data to be used later for showing a users session table
            push @UserSessions, {
                SessionID     => $SessionID,
                UserFirstname => $Data{UserFirstname},
                UserLastname  => $Data{UserLastname},
                UserFullname  => $Data{UserFullname},
                UserType      => $Data{UserType},
            };
        }

        # show users session table
        for my $UserSession (@UserSessions) {

            # create blocks
            $LayoutObject->Block(
                Name => $UserSession->{UserType} . 'Session',
                Data => {
                    %{$UserSession},
                    %Param,
                },
            );
        }

        # no customer sessions found
        if ( !$MetaData{CustomerSession} ) {

            $LayoutObject->Block(
                Name => 'CustomerNoDataRow',
            );
        }

        # no agent sessions found
        if ( !$MetaData{UserSession} ) {

            $LayoutObject->Block(
                Name => 'AgentNoDataRow',
            );
        }
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => "AdminCustomerDashboardInfoTile$Param{Action}",
        Data         => {
            Counter => $Counter,
            %Param,
            %{$CustomerDashboardInfoTileData},
            %MetaData
        },
    );

    $Output .= $LayoutObject->Footer();

    return $Output;
}

sub _GetParams {
    my ( $Self, %Param ) = @_;

    my $GetParam;

    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # get parameters from web browser
    for my $ParamName (
        qw(
        InfoTileID StartDateYear StartDateMonth StartDateDay StartDateHour StartDateMinute 
        StopDateYear StopDateMonth StopDateDay StopDateHour StopDateMinute StartDate StopDate
        Heading Content ValidID Permission )
        )
    {
        $GetParam->{$ParamName} = $ParamObject->GetParam( Param => $ParamName );
        print STDERR "AdminCustomerDashboardInfoTile.pm, L.707: " . $ParamName . "\n";
        
    }
    use Data::Dumper;
    print STDERR "AdminCustomerDashboardInfoTile.pm, L.711: " . Dumper($GetParam);

    $Param{ShowLoginMessage} ||= 0;

    ITEM:
    for my $Item (qw(StartDate StopDate)) {

        my %DateStructure;

        # check needed stuff
        PERIOD:
        for my $Period (qw(Year Month Day Hour Minute)) {

            if ( !defined $GetParam->{ $Item . $Period } ) {
                $Param{Error}->{ $Item . 'Invalid' } = 'ServerError';
                next ITEM;
            }

            $DateStructure{$Period} = $GetParam->{ $Item . $Period };
        }

        my $DateTimeObject = $Kernel::OM->Create(
            'Kernel::System::DateTime',
            ObjectParams => {
                %DateStructure,
                TimeZone => $Self->{UserTimeZone},
            },
        );
        if ( !$DateTimeObject ) {
            $Param{Error}->{ $Item . 'Invalid' } = 'ServerError';
            next ITEM;
        }

        $GetParam->{$Item} = $DateTimeObject->ToEpoch();
        $GetParam->{ $Item . 'TimeStamp' } = $DateTimeObject->ToString();
    }

    return $GetParam;
}

1;
