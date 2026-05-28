# Pet Speak Audio

Drop short, owned or royalty-free animal audio clips in this folder to make the Pet Speak speaker button use real pet sounds instead of the fallback generated tones.

Supported file formats:
- `caf`
- `wav`
- `mp3`
- `m4a`

Expected base filenames:
- `dog_love`
- `dog_treat`
- `dog_play`
- `dog_calm`
- `cat_love`
- `cat_treat`
- `cat_play`
- `cat_calm`

Recommended clip style:
- Keep clips around 0.5 to 2 seconds.
- Use clean animal-only sounds with little background noise.
- Normalize volume so dog and cat clips feel consistent.
- Avoid copyrighted clips unless you have clear app distribution rights.

The app checks this folder first, then falls back to generated audio if a clip is missing.

Bundled starter clips:
- Dog clips use the public-domain Wikimedia Commons file `George_vuf_1996.ogg`, transcoded to MP3.
- Cat treat/play clips use the public-domain Wikimedia Commons file `Meow_of_a_pleading_cat.oga`, transcoded to MP3.
- Cat love/calm clips use the Wikimedia Commons file `Purring_cat.oga`, transcoded to MP3.

Source pages:
- https://commons.wikimedia.org/wiki/File:George_vuf_1996.ogg
- https://commons.wikimedia.org/wiki/File:Meow_of_a_pleading_cat.oga
- https://commons.wikimedia.org/wiki/File:Purring_cat.oga
