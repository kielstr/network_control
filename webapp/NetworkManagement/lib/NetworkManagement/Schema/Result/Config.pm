use utf8;
package NetworkManagement::Schema::Result::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::Config

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 gateway

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lan_subnets

  data_type: 'json'
  is_nullable: 0

=head2 masquerade

  data_type: 'json'
  is_nullable: 0

=head2 device

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 broadcast_address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_subnet

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_netmask

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_range

  data_type: 'json'
  is_nullable: 1

=head2 network_control_last_run

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "gateway",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lan_subnets",
  { data_type => "json", is_nullable => 0 },
  "masquerade",
  { data_type => "json", is_nullable => 0 },
  "device",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "broadcast_address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_subnet",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_netmask",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_range",
  { data_type => "json", is_nullable => 1 },
  "network_control_last_run",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-14 20:53:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CGeY9NK7SWu39DvE6cAQyg
# These lines were loaded from 'lib/NetworkManagement/Schema/Result/Config.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NetworkManagement::Schema::Result::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::Config

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 gateway

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lan_subnets

  data_type: 'json'
  is_nullable: 0

=head2 masquerade

  data_type: 'json'
  is_nullable: 0

=head2 device

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 broadcast_address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_subnet

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_netmask

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_range

  data_type: 'json'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "gateway",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lan_subnets",
  { data_type => "json", is_nullable => 0 },
  "masquerade",
  { data_type => "json", is_nullable => 0 },
  "device",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "broadcast_address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_subnet",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_netmask",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_range",
  { data_type => "json", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-11 12:51:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fUQUcKk1cx8F+9lIbmAL4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from 'lib/NetworkManagement/Schema/Result/Config.pm'
# These lines were loaded from 'lib/NetworkManagement/Schema/Result/Config.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NetworkManagement::Schema::Result::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::Config

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 gateway

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lan_subnets

  data_type: 'json'
  is_nullable: 0

=head2 masquerade

  data_type: 'json'
  is_nullable: 0

=head2 device

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 broadcast_address

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_subnet

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_netmask

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp_range

  data_type: 'json'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "gateway",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lan_subnets",
  { data_type => "json", is_nullable => 0 },
  "masquerade",
  { data_type => "json", is_nullable => 0 },
  "device",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "broadcast_address",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_subnet",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_netmask",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp_range",
  { data_type => "json", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-11 12:51:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fUQUcKk1cx8F+9lIbmAL4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from 'lib/NetworkManagement/Schema/Result/Config.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
