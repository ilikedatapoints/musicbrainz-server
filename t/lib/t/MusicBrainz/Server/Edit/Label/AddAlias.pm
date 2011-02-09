package t::MusicBrainz::Server::Edit::Label::AddAlias;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use_ok 'MusicBrainz::Server::Edit::Label::AddAlias' }

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ALIAS );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');

my $edit = _create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::AddAlias');
ok(defined $edit->alias_id);
ok($edit->alias_id > 0);

my ($edits) = $c->model('Edit')->find({ label => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

my $label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 1);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{label}->id, 1);
is($edit->display_data->{alias}, 'Another alias');

my $alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 3);

reject_edit($c, $edit);

$alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

my $edit = _create_edit($c);
accept_edit($c, $edit);

$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

$alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 3);

};

sub _create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_ADD_ALIAS,
        editor_id => 1,
        label_id => 1,
        name => 'Another alias',
    );
}

1;
