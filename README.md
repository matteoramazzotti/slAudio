# slidio

this is the procedure I use to rapidly produce videos from a lesson in pdf and a set of audio files, one per slide:

1. save slides (or .odp, .ppt, it's the same) in pdf format.

2. convert the pdf in many png files with the imagemagick command

     convert -scene 1 -density 200 lezione.pdf slide_%02d.png

3. record audio files (one per slide) and save them with the same name of the slides, so for slide_01.png name the file slide_01.mp3

3b. if mp3 is stereo,convert them to mono with sox

     sox stereo.mp3 mono.mp3 channels 1

3c. if volume is low or high sox can adjust it, e.g. to imcrease thevolume 3x use 

     sox -v 3 lowvol.mp3 3xvol.mp3 channels 1

  or directly combine with the previous 

     sox -v 3 stereo.mp3 mono.mp3 channels 1 

3d. in csae of background noise, record some second of silence as noise.mp3, then use the following to produce a clean audio

     sox noise.mp3 noise.wav trim 0 2
     sox noise.wav -n noiseprof noise.prof
     rm noise.wav
     sox stereo.mp3 mono.mp3 channels 1
     sox mono.mp3 mono_clear.mp3 noisered noise.prof 0.31

3e. all previous command can be looped in a bash for processing all audio files.

4. Once all slide.png have a slide.mp3, run the following perl script:

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
     `fmpeg -f concat -safe 0 -i list -c copy video.mkv`;
     `rm slide*.mkv`

The final video has a duration equal to the sum of the durations of the audio files and the final video.mkv is pretty in adio and video and is size is approx 680 kb/min (a good compromise using mono audio and a decent video quality).

Hope this helps.
MR
