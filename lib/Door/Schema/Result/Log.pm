package Door::Schema::Result::Log;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Door::Schema::Result::Log

=cut

__PACKAGE__->table("log");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 dt

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=head2 message

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "dt",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "message",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-09-17 10:24:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qW41Ah4c6GoiKzkPyvvWsA

__PACKAGE__->belongs_to(user => 'Door::Schema::Result::User', 'user_id', {join_type=>'left'});

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
