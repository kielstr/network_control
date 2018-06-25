use Minion;

# Connect to backend
my $minion = Minion->new(Pg => 'postgresql://minion:OpenNow@localhost/minion');

$minion->run;