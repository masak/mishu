use v6;
use Test;
use Mishu;
use Test::Mishu;

{
    my $performer = Mock::Performer.new;
    my $mishu = Mishu.new(:$performer);

    $mishu.send:
        Command::Tell.new("OH HAI")
    ;
    $performer.ok_got: [
        Event::Tell.new("OH HAI"),
    ], "asking to tell immediately fires off a response";
}

{
    my $performer = Mock::Performer.new;
    my $mishu = Mishu.new(:$performer);

    $mishu.send:
        Command::Tell.new("hehehe")
    ;
    $performer.ok_got: [
        Event::Tell.new("hehehe"),
    ], "and it's actually the appropriate message";
}

{
    my $performer = Mock::Performer.new;
    my $time = Mock::Time.new;
    my $mishu = Mishu.new(:$performer, :$time);

    $mishu.send:
        Command::Wait.new(5, minutes,
            Command::Tell.new("delayed OH HAI"))
    ;
    $performer.ok_got: [], "asking for a delayed tell does nothing";

    $mishu.update();
    $performer.ok_got: [], "updating too early does nothing";

    $time.wait(5, minutes);
    $mishu.update();
    $performer.ok_got: [
        Event::Tell.new("delayed OH HAI"),
    ], "five minutes later, it shows up";
}

{
    my $performer = Mock::Performer.new;
    my $time = Mock::Time.new;
    my $mishu = Mishu.new(:$performer, :$time);

    $mishu.send:
        Command::Wait.new(11, minutes,
            Command::Tell.new("delayed hehehehe"))
    ;

    $time.wait(10, minutes);
    $mishu.update();
    $performer.ok_got: [], "updating too early does nothing";

    $time.wait(11, minutes);
    $mishu.update();
    $performer.ok_got: [
        Event::Tell.new("delayed hehehehe"),
    ], "eleven minutes later, it shows up";
}

{
    my $performer = Mock::Performer.new;
    my $time = Mock::Time.new;
    my $mishu = Mishu.new(:$performer, :$time);

    $mishu.send:
        Command::Wait.new(2, minutes,
            Command::Tell.new("fire once!"))
    ;

    $time.wait(3, minutes);
    $mishu.update();
    $performer.ok_got: [
        Event::Tell.new("fire once!"),
    ], "it shows up";

    $time.wait(2, minutes);
    $mishu.update();
    $performer.ok_got: [], "but it only shows up once";
}

done;
