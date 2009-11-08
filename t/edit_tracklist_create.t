use strict;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Tracklist::Create' }

use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_CREATE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+create_tracklist');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::Create');

$c->model('Edit')->load_all($edit);
ok($edit->tracklist);
is($edit->tracklist_id, $edit->tracklist->id);
my $tracklist_id = $edit->tracklist_id;

reject_edit($c, $edit);

my $tracklist = $c->model('Tracklist')->get_by_id($tracklist_id);
ok(!defined $tracklist);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Tracklist::Create');

accept_edit($c, $edit);

$c->model('Edit')->load_all($edit);
$c->model('Track')->load_for_tracklists($edit->tracklist);

is($edit->tracklist->track_count, 2);
is($edit->tracklist->all_tracks, 2);
is($edit->tracklist->tracks->[0]->name, 'Track 1');
is($edit->tracklist->tracks->[0]->position, 1);
is($edit->tracklist->tracks->[1]->name, 'Track 2');
is($edit->tracklist->tracks->[1]->position, 2);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_TRACKLIST_CREATE,
        editor_id => 1,
        tracks => [
            {
                name => 'Track 1',
                position => 1,
                artist_credit => [{ artist => 1, name => 'Artist' }]
            },
            {
                name => 'Track 2',
                position => 2,
                artist_credit => [{ artist => 1, name => 'Artist' }]
            }
        ]
    );
}
