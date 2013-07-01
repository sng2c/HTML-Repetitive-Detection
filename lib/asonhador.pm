use strict;

my $open = "<";
my $close_open = "</";
my $self_close = "/>";
my $close = ">";

sub detect{
	my $str = shift;
	my $idx_cur = 0;
	my $str_len = length($str);

	my $recognized_pre = [];
	my $recognized_post = [];
	my $recognized_cnt = {};

	my $is_open;
	my $is_close_open;
	my $ignore_next;

	my $char_cur;
	my $char_prev;

	my $buf = "";
	my $content = "";

	while ($idx_cur <= $str_len) {
		$char_cur = substr($str, $idx_cur, 1);
		$char_prev = substr($str, $idx_cur - 1, 1) if ($idx_cur > 0);

		#print "> ".join(",", @$recognized_pre);
		#print "\n";
		#print "< ".join(",", @$recognized_post);
		#print "\n\n";

		if ($char_cur =~ /[\r\n]/) {
			$idx_cur += 1;
			next;
		}

		if ($char_prev.$char_cur eq $self_close) {
			$idx_cur += 1;
			$is_open = undef;
			$is_close_open = undef;
			$ignore_next = undef;
			$buf = "";

			next;
		} elsif ($char_prev.$char_cur eq $close_open) {
			$idx_cur += 1;
			$is_open = undef;
			$is_close_open = 1;
			$ignore_next = undef;

			next;
		} elsif ($char_cur eq $open) {
			$idx_cur += 1;
			$is_open = 1;
			$is_close_open = undef;
			$ignore_next = undef;

			next;
		} elsif ($is_open && ($char_cur eq $close || $char_cur =~ /\s+/)) {
			push (@$recognized_pre, $buf) if !$ignore_next;

			$buf = "";
			$idx_cur += 1;
			if ($char_cur eq $close) {
				$is_open = undef;
				$ignore_next = undef;
			}
			$ignore_next = 1 if ($char_cur =~ /\s+/);

			next;
		} elsif ($is_close_open && $char_cur eq $close) {
			my $pair = pop (@$recognized_pre);

			#print "close match pair $pair buf $buf\n";

			push (@$recognized_post, $buf) if $pair eq $buf;

			if (scalar @$recognized_pre == 0) {
				my $pattern = join (",", @$recognized_post);
				push (@{$recognized_cnt->{$pattern}}, $content);

				$content = "";
				$recognized_post = [];
			}

			$buf = "";
			$idx_cur += 1;
			$is_close_open = undef;
			$ignore_next = undef;

			next;
		}

		if ($ignore_next) {
			$idx_cur += 1;
		} elsif ($is_close_open) {
			$buf .= substr($str, $idx_cur, 1);
			$idx_cur += 1;
		} elsif ($is_open) {
			$buf .= substr($str, $idx_cur, 1);
			$idx_cur += 1;
		} else {
			$content .= substr($str, $idx_cur, 1);
			$idx_cur += 1;
		}
	}

	my @ret;
	foreach (keys %$recognized_cnt) {
		my $recognized = $recognized_cnt->{$_};

		if (scalar @$recognized > 1) {
			foreach (@$recognized) {
				push(@ret,$_);
			}
		}
	}
	return @ret;
}

1;
