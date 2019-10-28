use utf8;
package NetworkManagement::Schema::Result::Device;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::Device

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

=head1 TABLE: C<device>

=cut

__PACKAGE__->table("device");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 100

=head2 download_speed

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 upload_speed

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 hostname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 mac

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 ip

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 priority

  data_type: 'integer'
  is_nullable: 1

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 dhcp

  data_type: 'tinyint'
  is_nullable: 1

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 domain_name_servers

  data_type: 'json'
  is_nullable: 1

=head2 dt

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 100 },
  "download_speed",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "upload_speed",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "hostname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "mac",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "ip",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "priority",
  { data_type => "integer", is_nullable => 1 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "dhcp",
  { data_type => "tinyint", is_nullable => 1 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "domain_name_servers",
  { data_type => "json", is_nullable => 1 },
  "dt",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 access_schedules

Type: has_many

Related object: L<NetworkManagement::Schema::Result::AccessSchedule>

=cut

__PACKAGE__->has_many(
  "access_schedules",
  "NetworkManagement::Schema::Result::AccessSchedule",
  { "foreign.device_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 uuid

Type: belongs_to

Related object: L<NetworkManagement::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "uuid",
  "NetworkManagement::Schema::Result::User",
  { uuid => "uuid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-14 12:53:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DyPY1xj0V4Xsa3Bp/gQv/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
