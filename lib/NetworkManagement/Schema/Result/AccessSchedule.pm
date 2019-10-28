use utf8;
package NetworkManagement::Schema::Result::AccessSchedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::AccessSchedule

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

=head1 TABLE: C<access_schedule>

=cut

__PACKAGE__->table("access_schedule");

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

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 day

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 block

  data_type: 'time'
  is_nullable: 1

=head2 unblock

  data_type: 'time'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 100 },
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "day",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "block",
  { data_type => "time", is_nullable => 1 },
  "unblock",
  { data_type => "time", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 device

Type: belongs_to

Related object: L<NetworkManagement::Schema::Result::Device>

=cut

__PACKAGE__->belongs_to(
  "device",
  "NetworkManagement::Schema::Result::Device",
  { id => "device_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-11 20:58:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IzOoQLA/9FYCZlq75ZNRTw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
