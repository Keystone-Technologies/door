package Door::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Door::Schema::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);
__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-09-17 10:24:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iBOoQeFwbkNuFfHq1zDcGA

__PACKAGE__->has_many(doors => 'Door::Schema::Result::Door', 'user_id'); # codes
__PACKAGE__->has_many(logs => 'Door::Schema::Result::Log', 'user_id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
