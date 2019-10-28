package NetworkManagement;
use Dancer2;
use Dancer2::Plugin::DBIC;
use Data::Dumper 'Dumper';

our $VERSION = '0.1';

hook before => sub {
    say STDERR '['. request->method . ']' . request->path;
};

get '/' => sub {
    my @users = schema->resultset('User')->all;
    my @clients;

    for my $user ( @users ) {
        push @clients, { 
            firstname => $user->firstname,
            uuid => $user->uuid,
        };

        say STDERR $user->dt->epoch;
    }

    template 'index' => { 
        'title' => 'NetworkManagement', 
        'users' => \@clients,
    };
};

get '/user/:uuid' => sub {
    my $uuid = route_parameters->get('uuid');

    my $user_rs = schema->resultset('User')->find({uuid => $uuid});

    my @devices;

    my %template_args = (
        'title' => 'NetworkManagement',
        'name' => join (' ', $user_rs->firstname, $user_rs->lastname),
        'status' => ( $user_rs->active == 1 ? 'enabled' : 'disabled' ),
        'upload_speed' => $user_rs->upload_speed,
        'download_speed'=> $user_rs->download_speed,
        'uuid' => $uuid,
    );

    for my $device ($user_rs->devices) {
        push @{ $template_args{ 'devices' } }, {
            map { $_ => $device->$_ } qw(
                id
                download_speed
                upload_speed
                hostname
                mac
                ip
                priority
                description
                dhcp
                active
                domain_name_servers
            )
        };
    }

    template 'user' => \%template_args;
};

get '/add_user' => sub {
    template 'add_user' => {'title' => 'NetworkManagement',};
};

post '/add_user' => sub {
    my $user_rs = schema->resultset('User');
    my $new_user = $user_rs->new({});

    for my $key ( qw(
        firstname
        lastname
        active
        upload_speed
        download_speed
        priority
        active
    ) ) {
        $new_user->$key(param($key));
    }

    #$new_user->insert;

    #forward '/', {}, { method => 'GET' };

    redirect '/';

};

get '/add_device/:uuid' => sub {
    my $uuid = route_parameters->get('uuid');
    my $user_rs = schema->resultset('User')->find({uuid => $uuid});

    template 'add_device' => {
        'title' => 'NetworkManagement', 
        'uuid' => $uuid,
        'name' => join (' ', $user_rs->firstname, $user_rs->lastname),
    };
};

true;