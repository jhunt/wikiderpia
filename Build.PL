use 5.006;
use strict;
use warnings;
use Module::Build;
use File::Find;

my $BUILDER = Module::Build->subclass(
	class => 'Module::Build::Wikiderpia',
);

my %TREE;
sub tree_files { $TREE{$File::Find::name} = $File::Find::name if -f };

%TREE = (); find(\&tree_files, "views");  my %VIEWS  = %TREE;
%TREE = (); find(\&tree_files, "public"); my %PUBLIC = %TREE;
%TREE = (); find(\&tree_files, "etc");    my %ETC    = %TREE;
%TREE = (); find(\&tree_files, "sbin");   my %SBIN   = %TREE;
%TREE = (); find(\&tree_files, "bin");    my %BIN    = %TREE;


my $builder = $BUILDER->new(
	module_name        => 'Wikiderpia',
	license            => 'bsd',
	dist_author        => q{James Hunt <james@jameshunt.us>},
	dist_version_from  => 'lib/Wikiderpia.pm',
	configure_requires => { 'Module::Build' => 0.38 },
	build_requires => {
		'Test::More'   => 0,
	},
	requires => {
		'Dancer'            => 1.3113,
	},
	add_to_cleanup => [
		'Wikiderpia-*',
		'cover_db',
		'*.rpm',
		'*.deb',
	],
	test_files => [
		"t/*.t",
		"t/selenium/*.t",
	],

	share_files  => {'wikiderpia.psgi' => 'wikiderpia.psgi'},
	views_files  => \%VIEWS,
	public_files => \%PUBLIC,
	etc_files    => \%ETC,
	sbin_files   => \%SBIN,
	bin_files    => \%BIN,
	install_path => {
		share  => "usr/share/wikiderpia",
		views  => "usr/share/wikiderpia/views",
		public => "usr/share/wikiderpia/public",
		etc    => "etc",
		sbin   => "usr/sbin",
		bin    => "usr/bin",
	},
);

$builder->add_build_element('share');
$builder->add_build_element('views');
$builder->add_build_element('public');
$builder->add_build_element('etc');
$builder->add_build_element('sbin');
$builder->add_build_element('flair');
$builder->create_build_script();
