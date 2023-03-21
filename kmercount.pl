#!/usr/bin/perl -w
use strict;

die "perl $0 input_file kmer out_file\n" if @ARGV!=3;

my $input="$ARGV[0]";
my $kmer="$ARGV[1]";
my $output="$ARGV[2]";
open IN, $input or die $!;
my (@chr, %seq, $chr)=();
while(<IN>){
	chomp;
	my @array=split(/\s+/, $_);
	if($_=~ /^>/){
		$chr=$array[0]; $chr=~ s/>//; push(@chr, $chr);
	}else{
		if($seq{$chr}){$seq{$chr}.=$_;}else{$seq{$chr}=$_;}
	}
}
close IN;

open OUT, "> $output" or die $!;
my ($kmer_seq, %count, @kmers)=();
for (my $i=0; $i < @chr; $i++){
	my @seq=split(//, $seq{$chr[$i]});
	for (my $j=0; $j < $#seq-$kmer+2; $j++){
		my $seq=substr($seq{$chr[$i]}, $j, $kmer);
		$seq=uc($seq);
		my $rev_seq=reverse($seq);
		my @rev_seq=split(//, $rev_seq);
		my $new_seq=&diff(@rev_seq);
		if($seq lt $new_seq){
			$kmer_seq=$seq;
		}else{
			$kmer_seq=$new_seq;
		}
		if($count{$kmer_seq}){$count{$kmer_seq}+=1;}else{
			$count{$kmer_seq}=1;
			push(@kmers, $kmer_seq);
		}
	}
}

for (my $i=0; $i < @kmers; $i++){
	print OUT $kmers[$i], "\t", $count{$kmers[$i]}, "\n";
}

sub diff{
	my @seq=@_;
	my @new_seq=();
	for (my $i=0; $i < @seq; $i++){
		if($seq[$i] eq "A"){push(@new_seq, "T")};
		if($seq[$i] eq "T"){push(@new_seq, "A")};
		if($seq[$i] eq "G"){push(@new_seq, "C")};
		if($seq[$i] eq "C"){push(@new_seq, "G")};
	}
	my $new_seq=join("", @new_seq);
	return $new_seq;
}
