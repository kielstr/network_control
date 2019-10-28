use utf8;
package NetworkManagement::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 firstname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lastname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 upload_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 download_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 priority

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 dt

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  default_value: 'CURRENT_TIMESTAMP'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "uuid",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "upload_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "download_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "priority",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "dt",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<uuid>

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->add_unique_constraint("uuid", ["uuid"]);

=head1 RELATIONS

=head2 access_schedules

Type: has_many

Related object: L<NetworkManagement::Schema::Result::AccessSchedule>

=cut

__PACKAGE__->has_many(
  "access_schedules",
  "NetworkManagement::Schema::Result::AccessSchedule",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 devices

Type: has_many

Related object: L<NetworkManagement::Schema::Result::Device>

=cut

__PACKAGE__->has_many(
  "devices",
  "NetworkManagement::Schema::Result::Device",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-14 20:48:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DpjOKQ25J09Nk4brtJwa7g
# These lines were loaded from 'lib/NetworkManagement/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NetworkManagement::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 firstname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lastname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 upload_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 download_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 priority

  data_type: 'integer'
  default_value: 1
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
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "upload_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "download_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "priority",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
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

=head1 UNIQUE CONSTRAINTS

=head2 C<uuid>

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->add_unique_constraint("uuid", ["uuid"]);

=head1 RELATIONS

=head2 access_schedules

Type: has_many

Related object: L<NetworkManagement::Schema::Result::AccessSchedule>

=cut

__PACKAGE__->has_many(
  "access_schedules",
  "NetworkManagement::Schema::Result::AccessSchedule",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 devices

Type: has_many

Related object: L<NetworkManagement::Schema::Result::Device>

=cut

__PACKAGE__->has_many(
  "devices",
  "NetworkManagement::Schema::Result::Device",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-14 12:53:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PHZMZjAcVjImfHoQMI/dBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from 'lib/NetworkManagement/Schema/Result/User.pm'
# These lines were loaded from 'lib/NetworkManagement/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package NetworkManagement::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

NetworkManagement::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 uuid

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 firstname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 lastname

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 upload_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 download_speed

  data_type: 'varchar'
  default_value: '100mbit'
  is_nullable: 1
  size: 20

=head2 priority

  data_type: 'integer'
  default_value: 1
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
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "firstname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "lastname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "upload_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "download_speed",
  {
    data_type => "varchar",
    default_value => "100mbit",
    is_nullable => 1,
    size => 20,
  },
  "priority",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
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

=head1 UNIQUE CONSTRAINTS

=head2 C<uuid>

=over 4

=item * L</uuid>

=back

=cut

__PACKAGE__->add_unique_constraint("uuid", ["uuid"]);

=head1 RELATIONS

=head2 access_schedules

Type: has_many

Related object: L<NetworkManagement::Schema::Result::AccessSchedule>

=cut

__PACKAGE__->has_many(
  "access_schedules",
  "NetworkManagement::Schema::Result::AccessSchedule",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 devices

Type: has_many

Related object: L<NetworkManagement::Schema::Result::Device>

=cut

__PACKAGE__->has_many(
  "devices",
  "NetworkManagement::Schema::Result::Device",
  { "foreign.uuid" => "self.uuid" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-09-14 12:53:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PHZMZjAcVjImfHoQMI/dBw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
# End of lines loaded from 'lib/NetworkManagement/Schema/Result/User.pm'


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
