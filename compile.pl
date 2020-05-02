#!/usr/bin/perl
if (!$ARGV[0]) {
	print STDERR "PLease specify the lesson folder\n";
	exit;
}
#START:
#- an mp3 folder containing slide_XX.mp3 (leave at least 2 sec noise time at the begin of slide_01.mp3)
#- a lessonXX.pdf file
$lesson = $ARGV[0];
print STDERR " Creating the noise profile\n";
if(!-e "noise.prof") {
	`sox $lesson/mp3/slide_01.mp3 $lesson/noise.wav trim 0 2`;
	`sox $lesson/noise.wav -n noiseprof $lesson/noise.prof && rm $lesson/noise.wav`;
}

print STDERR " Processing audio\n";
foreach $file (split(/\n/,`ls $lesson/mp3/*.mp3`)) {
	$out = $file;
	$out =~ s/mp3\///;
	print STDERR "  $file -> $out\n";
	`rm tmp.mp3 tmp2.mp3` if (-e "tmp.mp3");
	`ffmpeg -loglevel quiet -i $file tmp.mp3 && sox tmp.mp3 tmp2.mp3 noisered $lesson/noise.prof 0.31 && sox -v 3 tmp2.mp3 $out channels 1` if (!-e $out);
}
`rm tmp.mp3 tmp2.mp3` if (-e "tmp.mp3");
$pdf = `ls $lesson/$lesson.pdf`;
chomp $pdf;
print STDERR " Processing slides from $pdf\n";
`convert -scene 1 -density 200 $pdf $lesson/slide_%02d.png` if (!-e "$lesson/slide_01.png");

print STDERR " Creating html\n";
$tot = `ls $lesson/*.png | wc -l`;
chomp $tot;
$new = '';
foreach $i (1..$tot) {
	$new .= '<a href="javascript:change('.sprintf("%02d", $i).')">'.sprintf("%02d", $i).'</a>'."\n"
}
open(IN,"base.html");
open(OUT,">$lesson/index.html");
while ($l = <IN>) {
	$l =~ s/XXXXX/$new/;
	$l =~ s/YYYYY/$tot/;
	$l =~ s/ZZZZZ/$lesson/g;
	print OUT $l;
}
close IN;
close OUT;
$outweb = "$lesson/$lesson"."_web.zip";
print STDERR " Compressing to $outweb\n";
`zip $outweb $lesson/*.png $lesson/*.mp3 $lesson/index.html` if (!-e "$outweb");
$outaudio = "$lesson/$lesson"."_audio.zip";
print STDERR " Compressing to $outaudio\n";
`zip $outaudio $lesson/*.mp3`  if (!-e "$outaudio");
open(OUT,">list");
foreach $file (split(/\n/,`ls $lesson/*.mp3`)) {
	$png = $file;
	$png =~ s/mp3/png/;
	$out = $file;
	$out =~ s/mp3/mkv/;
	print STDERR "  $file + $png -> $out\n";
	`ffmpeg -y -loop 1 -framerate 1 -i $png -i $file -c:v libx264 -preset veryslow -crf 0 -c:a copy -shortest $out` if (!-e $out);
	print OUT "file $out\n"
}
close OUT;
$vout = "$lesson/$lesson"."_video.mkv";
`ffmpeg -f concat -safe 0 -i list -c copy $vout` if (!-e $vout);
`rm $lesson/slide*.mkv`;
