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
	my $surrounding_content = [];
	my $surrounding_content_token_idx = [];

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

		push(@$surrounding_content, $char_cur);

		if ($char_prev.$char_cur eq $self_close) {
			$idx_cur += 1;
			$is_open = undef;
			$is_close_open = undef;
			$ignore_next = undef;
			$buf = "";

			next;
		} elsif ($char_prev.$char_cur eq $close_open) {
			push (@$surrounding_content_token_idx, $idx_cur - 1) if !$ignore_next;

			$idx_cur += 1;
			$is_open = undef;
			$is_close_open = 1;
			$ignore_next = undef;

			next;
		} elsif ($char_cur eq $open) {
			push (@$surrounding_content_token_idx, $idx_cur) if !$ignore_next;

			$idx_cur += 1;
			$is_open = 1;
			$is_close_open = undef;
			$ignore_next = undef;

			next;
		} elsif ($is_open && ($char_cur eq $close || $char_cur =~ /[ ]+/)) {
			push (@$surrounding_content_token_idx, $idx_cur) if !$ignore_next;

			my $len = scalar @$recognized_post;
			if ($len > 0 && $buf eq $recognized_post->[$len-1]) {
				my $pattern = join (",", @$recognized_post);
				
				#print join(",", @$surrounding_content_token_idx)."\n";

				my $start_idx = $surrounding_content_token_idx->[$len - 1] + 1;
				my $end_idx = $surrounding_content_token_idx->[-3] - 1;

				#print "start_idx $start_idx end_idx $end_idx\n";
				#print join("", @$surrounding_content[$start_idx..$end_idx])."\n";

				delete $recognized_cnt->{$pattern} if (exists $recognized_cnt->{$pattern});
				push (@{$recognized_cnt->{$pattern}}, join("", @$surrounding_content[$start_idx..$end_idx]));

				#print "post_tag begin ".($surrounding_content_token_idx->[-2])."\n";

				my $post_tag = substr(join("", @$surrounding_content), $surrounding_content_token_idx->[-3]);

				$content = "";
				$surrounding_content = [];
				$surrounding_content_token_idx = [];
			    $recognized_post = [];
				$recognized_pre = [];

				push (@$surrounding_content, $post_tag);
			} 

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
			push (@$surrounding_content_token_idx, $idx_cur) if !$ignore_next;

			my $pair = pop (@$recognized_pre);

			#print "close match pair $pair buf $buf\n";

			if ($pair eq $buf) {
				push (@$recognized_post, $buf);
				my $pattern = join (",", @$recognized_post);
				push (@{$recognized_cnt->{$pattern}}, join("", @$surrounding_content));
			}

			if ($pair ne $buf || scalar @$recognized_pre == 0) {
				$content = "";
				$surrounding_content = [];
				$surrounding_content_token_idx = [];
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

	my $max_len = 0;
	foreach (keys %$recognized_cnt) {
		$max_len = length ($_) if length ($_) > $max_len;
	}

	my @ret;
	foreach (keys %$recognized_cnt) {
		next if length ($_) != $max_len;

		my $pattern = $_;
		my $recognized = $recognized_cnt->{$pattern};

		foreach (@$recognized) {
				#print $pattern." ".$_."\n";
		}

		if (scalar @$recognized > 1) {
			foreach (@$recognized) {
				push(@ret,$_);
			}
		}
	}
	return @ret;
}

1;
