package Wikiderpia;
use Dancer ':syntax';
use LWP::UserAgent;
use utf8;

our $VERSION = '0.1.0';

sub _url {
	return "https://en.wikipedia.org$_[0]"
}

sub _derpify {
	my ($content) = @_;
	my $baseurl = request->uri_base;

	$content =~ s/\bWikipedia/Wikiderpia/g;
	$content =~ s/\b(may be|can be|are not)\b/$1 (herp derp derp)/g;
	$content =~ s/\b(walked|talked|supported|coined|launched|published|approached|contained|edited|started|locked|allowed|argued)\b/derped/g;
	$content =~ s/\b(hosted|introduced|passed|considered|introduced|remained|asked|stored|covered|vetted|limited|intended|used|described)\b/herped/g;
	$content =~ s/\b(love thee)\b/derrp theeeeeeeeeee/g;
	$content =~ s/\b(openness|quality)\b/derpitude/g;
	$content =~ s/[fF]ebruary/Derpruary/g;
	$content =~ s|wikipedia.org/wiki/|$baseurl/wiki/|g;
	$content =~ s|\bportmanteau\b|port- portman -- err -- a word made up of other words|;
	$content =~ s|everyone reading this right now gave|you (yes you) would just fork over the bloody|;
	$content =~ s|To protect our independence, we'll never run ads|To protect our independence, we'll never set up a fascist religious dictatorship that suppresses the freedoms of Dimmy Wales|;
	$content =~ s|Jimmy Wales|Dimmy Wales|g;
	$content =~ s|Jimmy Donal Wales|Dimmy Donal Wales|g;
	$content =~ s|passion for sharing the world’s knowledge|serious problem with you|;
	$content =~ s|//upload.wikimedia.org/wikipedia/en/b/bc/Wiki.png|/o/logo.png|;
	$content =~ s|"//upload.wikimedia.org/.*Wikiderpia-logo-v2.svg.png"|"/o/logo.png"|;
	$content =~ s|File:Wikiderpia|File:Wikipedia|g;
	$content =~ s|([-_/])Wikiderpia|$1Wikipedia|g;

	return $content;
}

sub passthru() {
	my $ua = LWP::UserAgent->new;
	my $res = $ua->get(_url(request->uri));
	status $res->code;
	content_type $res->content_type;
	return $res->decoded_content;
}

get '/' => sub {
	redirect '/wiki/Wikipedia';
};

get '/wiki/:name' => sub {
	my $name = params->{name};
	$name =~ s/Wikiderpia/Wikipedia/;

	my $ua = LWP::UserAgent->new;
	my $res = $ua->get(_url("/wiki/$name"));

	my $derped = _derpify($res->decoded_content);

	status $res->code;
	return $derped;
};

get '/w/resources/**' => sub { passthru };
get '/w/load.php'     => sub { passthru };

get '/w/:name' => sub {
	my $name = params->{name};
	$name =~ s/Wikiderpia/Wikipedia/g;

	# searching
	if (exists params->{search} && (my $search = params->{search})) {
		$search =~ s/wikiderpia/wikipedia/gi;

		my $ua = LWP::UserAgent->new(requests_redirectable => []);
		my $res = $ua->get(_url("/w/$name?search=$search&title=Special%3ASearch&go=Go"));

		if (my $loc = $res->header('Location')) {
			$loc =~ s|https?://[^/]+/|/|;
			redirect $loc;
		}
	# page history
	} elsif (exists params->{action} && params->{action} eq "history" ) {
		my $req = "/w/$name?action=history";
		for (qw/title dir offset limit/) {
			$req .= "&$_=".params->{$_} if exists params->{$_};
		}

		my $ua = LWP::UserAgent->new;
		my $res = $ua->get(_url("/$req"));

		my $derped = _derpify($res->decoded_content);

		status $res->code;
		return $derped;
	# for page diffs
	} elsif (params->{oldid}) {
		my $req = "/w/$name?oldid=".params->{oldid};
		for (qw/title oldid/) {
			$req .= "&$_=".params->{$_} if exists params->{$_};
		}
		my $ua = LWP::UserAgent->new;
		my $res = $ua->get(_url("/$req"));

		my $derped = _derpify($res->decoded_content);

		status $res->code;
		return $derped;
	# all other actions are unsupported currently (don't want to risk editing derped content)
	} else {
		forward "/wiki/$name";
	}
};

get '**' => sub { return passthru };

true;

=head1 NAME

Wikiderpia - derp derp derp

=cut
