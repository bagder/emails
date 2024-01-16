#!/usr/bin/perl


sub fentries {
    my ($d)= @_;
    opendir(my $dh, $d) || die "Can't opendir $some_dir: $!";
    my @f = grep { /^\d\d\d\d-.*.md\z/ && -f "$d/$_" } readdir($dh);
    closedir $dh;
    return @f;
}

opendir(my $dh, ".") || die "Can't opendir $some_dir: $!";
my @years = grep { /^\d\d\d\d/ && -d "$_" } readdir($dh);
closedir $dh;

for my $y (sort @years) {
    my @f = fentries($y);
    for my $f (sort @f) {
        push @a, "$y/$f";
    }
}

# make a rel link to the new file from the old
sub rel {
    my ($n, $old) = @_;
    my $ny;
    my $oy;

    if($n =~ /^(\d\d\d\d)/) {
        $ny = $1;
    }
    if($old =~ /^(\d\d\d\d)/) {
        $oy = $1;
    }
    if($ny == $oy) {
        # same year, return the file part
        $n =~ s/[0-9]+\///g;
        return $n;
    }
    # not the same year, return ../ new
    return "../$n";    
}

sub fixup {
    my ($i) = @_;
    my $f = $a[$i];
    my @n;
    my $blank;
    open(F, "<$f");
    while(<F>) {
        chomp;
        if(/^## Links/) {
            last;
        }
        push @n, "$_\n";
        $blank = length($_);
    }
    close(F);
    if($blank) {
        push @n, "\n";
    }
    push @n, "## Links\n\n";
    push @n, sprintf "[prev](%s) [up](%s) [next](%s)\n",
        rel($a[$i - 1], $a[$i]),
        "../",
        rel($a[$i + 1], $a[$i]);
    open(F, ">$f");
    print F @n;
    close(F);
}


for $i (0 .. $#a) {
    fixup($i);
}
