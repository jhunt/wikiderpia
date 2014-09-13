package Wikiderpia;
use Dancer ':syntax';
use LWP::UserAgent;
use utf8;

our $VERSION = '0.1.0';

get '/' => sub {
	redirect '/wiki/Wikipedia';
};

get '/wiki/:name' => sub {
	my $name = params->{name};
	$name =~ s/Wikiderpia/Wikipedia/;

	my $ua = LWP::UserAgent->new;
	my $res = $ua->get('http://en.wikipedia.org/wiki/'.$name);

	local $_ = $res->decoded_content;
	s/\bWikipedia/Wikiderpia/g;
	s/\b(may be|can be|are not)\b/$1 (herp derp derp)/g;
	my $baseurl = request->uri_base;
	s|wikipedia.org/wiki/|$baseurl/wiki/|g;
	s|\bportmanteau\b|port- portman -- err -- a word made up of other words|;

	status $res->code;
	return $_;
};

true;

=head1 NAME

Wikiderpia - derp derp derp

=cut
