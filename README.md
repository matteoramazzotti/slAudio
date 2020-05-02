# slAudio
ciao,
ti descrivo il sistema che uso io per fare presto il pairing audio/video:

1. salvare le slide (o.odp, .ppt, è uguale) in formato pdf.

2. convertire il pdf in tanti png col comando imagemagick

  convert -scene 1 -density 200 lezione.pdf slide_%02d.png

3. registrare gli audio e salvarli con lo stesso nome delle slide, quindi es. slide_01.mp3

3b. se gli mp3 sono stereo conviene portarli a mono

  sox stereo.mp3 mono.mp3 channels 1

3c. se il volume è basso l'opzione -v di sox alza/abbassa il volume: io uso -v 3 per ampli 3x

3d. se c'è rumore di fondo, registrare alcuni secondi di silenzio su noise.mp3

  sox noise.mp3 noise.wav trim 0 2
  sox noise.wav -n noiseprof noise.prof
  rm noise.wav
  sox stereo.mp3 mono.mp3 channels 1
  sox mono.mp3 mono_clear.mp3 noisered noise.prof 0.31

3e. i comandi sox sopra possono essere dentro un for per automatizare tutto, occhio solo al nome dei file finali che devono essere uguali ai nomi dei png. In genere io salvo gli mp3 originali in una cartella e quelli post prodotti li mando nella cartella delle slide .png

4. lanciare il seguente script nella cartella coi file

#!/usr/bin/perl
open(OUT,">list");
foreach $file (split(/\n/,`ls *.mp3`)) {
     $png = $file;
     $png =~ s/mp3/png/;
     $out = $file;
     $out =~ s/mp3/mkv/;
     print STDERR "  $file + $png -> $out\n";
     `ffmpeg -y -loop 1 -framerate 1 -i $png -i $file -c:v libx264 -preset veryslow -crf 0 -c:a copy -shortest $out` if (!-e $out);
     print OUT "file $out\n"
}
close OUT;
`ffmpeg -f concat -safe 0 -i list -c copy video.mkv`;
`rm slide*.mkv`

Il video finale video.mkv si vede bene, si sente bene e occupa circa 680 kb/min.

M.
