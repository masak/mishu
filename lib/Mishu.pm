enum TimeUnit <minutes>;

class Command {
}

class Command::Tell is Command {
    has $.utterance;

    method new($utterance) {
        self.bless(:$utterance);
    }
}

class Command::Wait is Command {
    has $.amount;
    has $.unit;
    has $.command;

    method new(Int $amount, TimeUnit $unit, Command $command) {
        self.bless(:$amount, :$unit, :$command);
    }
}

class Event {
}

class Event::Tell is Event {
    has $.utterance;

    method new($utterance) {
        self.bless(:$utterance);
    }
}

class Job {
    has Str $.id = [~] (0..9, "a".."f").roll xx 6;
    has DateTime $.datetime;
    has Command $.command;
}

role Performer {
    method perform(Event $e) { ... }
}

class Mishu {
    has $.time;
    has $.performer;

    has @!jobs;

    multi method send(Command::Tell (:$utterance)) {
        $.performer.perform(Event::Tell.new($utterance));
    }

    multi method send(Command::Wait (:$amount, :$unit, :$command)) {
        die "Unknown unit '$unit'!"
            unless $unit == minutes;
        my $datetime = $.time.now.later(minutes => $amount);
        @!jobs.push(Job.new(:$datetime, :$command));
    }

    method update() {
        my %delete;
        for @!jobs -> $job {
            # RAKUDO: <= not implemented for DateTimes yet [RT #125555]
            # workaround: put .Instant on both operands
            if $job.datetime.Instant <= $.time.now.Instant {
                self.send($job.command);
                %delete{$job.id} = 1;
            }
        }
        @!jobs.=grep: { %delete{.id} :!exists };
    }
}
