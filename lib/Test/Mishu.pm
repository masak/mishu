use v6;

use Test;
use Mishu;

role Mock::Performer {
    has @!events;

    method perform($e) {
        @!events.push($e);
    }

    method ok_got(@expected, $description) {
        my @actual = @!events;
        @!events = ();

        if @expected.elems != @!events.elems {
            is @actual.elems, @expected.elems, "$description -- same size of event lists";
            return;

            # XXX: instead of just failing things immediately,
            # should do some kind of list diffing, and then
            # fail with that diff
        }

        for ^@expected Z @expected Z @actual -> ($i, $expected, $actual) {
            if $expected.WHAT !=== $actual.WHAT {
                is $actual.^name, $expected.^name, "$description -- same type event at position $i";
                return;
            }

            for $expected.^attributes -> $attr {
                next unless $attr.has_accessor;

                my $name = $attr.name.substr(2);
                my $equal = $expected."$name"() === $actual."$name"();
                next if $equal;

                ok $equal, "$description -- '$name' attributes are equal at position $i";
                return;
            }
        }
        ok True, $description;
    }
}

role Mock::Time {
    has $.now = DateTime.now;

    method wait(Int $amount, TimeUnit $unit) {
        die "Unknown unit '$unit'"
            unless $unit == minutes;
        $!now.=later(minutes => $amount);
    }
}
