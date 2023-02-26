# talkingSlides

talkingSlides is the perl script I use for the automatic production of video lessons from a static prestantation (slides) in pdf format and a bunch of mp3 files, one per slide. Personally I produce slides in libreoffice impress (and save it as pdf) and then I talk on slides (one by one) using the Ubuntu default Sound Recorder. The program will basically allow slides to talk.

```
USAGE: talkMyslides.pl lesson01
```
The initial folder structure is 
```
lesson01
   mp3/
        slide_01.mp3
        ...
        slide_NN.mp3
   lesson01.pdf
```
talkingSlides will
- learn the backgroud noise profile from the initial 2 seconds of slide_01.mp3
- denoise all other audio files
- produce a bunch of .png files from the main lesson.pdf file

and will produce

- an html index file that displays an interactive page with still images and an audio player
- a set of zip files for downloading the whole lesson
- a video (mkv container, ~ 850 KB/min, 50 MB/h) with all the talking slides merged (video h264 1 fps, audio mp3 44100 Hz mono) 

It follows a simple step-by-step procedure to explain the talkingSlide approach:

1. save slides (or .odp, .ppt, it's the same) in pdf format.

2. convert the pdf in many png files with the imagemagick command
```
convert -scene 1 -density 200 lezione.pdf slide_%02d.png
```
3. record audio files (one per slide) and save them with the same name of the slides, so for slide_01.png name the file slide_01.mp3

3b. if mp3 is stereo,convert them to mono with sox
```
sox stereo.mp3 mono.mp3 channels 1
```
3c. if volume is low or high sox can adjust it, e.g. to imcrease thevolume 3x use 
```
sox -v 3 lowvol.mp3 3xvol.mp3 channels 1
```
   or directly combine with the previous 
```
sox -v 3 stereo.mp3 mono.mp3 channels 1 
```
3d. in csae of background noise, record some second of silence as noise.mp3, then use the following to produce a clean audio
```
sox noise.mp3 noise.wav trim 0 2
sox noise.wav -n noiseprof noise.prof
rm noise.wav
sox stereo.mp3 mono.mp3 channels 1
sox mono.mp3 mono_clear.mp3 noisered noise.prof 0.31
```
3e. all previous command can be looped in a bash for processing all audio files.

4. Once all slide.png have a slide.mp3, run the following perl script:
```
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
```
Hope this helps.

MR
