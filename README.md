## Preview

<figure class="video_container">
  <iframe src="https://www.youtube.com/embed/oJ5Or8FDinE" frameborder="0" allowfullscreen="true"> </iframe>
</figure>

<figure class="video_container">
  <iframe src="https://www.youtube.com/embed/zq6wmiuq3eQ" frameborder="0" allowfullscreen="true"> </iframe>
</figure>

## Essential

- [x] Actually make UCS viewable.

* [x] Rendering notes.
* [ ] Correcting hold notes.

Optimizations

* [ ] Don't draw all holds. Draw a hold from H to end H with y scale factor.
* [x] Precompute step numbers and put into notes.note. ({1, 0, 0, ...}).
* [ ] Fix frequent lag on VSync
* [ ] Try profiling and try to optimize further by precomputing and sacrifing memory instead of performance.

## Touching up

* [x] Grab glow asset.
* [ ] Adjust receptor tap light to match exactly like the arcade version.
* [x] Make explosion asset. Trigger hit explosion asset when note is hit. Use queue to help with this.
* [x] Make font https://love2d.org/wiki/love.graphics.newImageFont. Load and test font with extraspacing maybe.
* [x] PERFECT display.
* [x] COMBO display.
* [x] COMBO COUNTER display. 
* [ ] Only show when counter is at 4 or more. Printing with three 0 padding with printf %03d. 
* [x] When UCS is loaded, or file is dropped, do glow and explosion on all arrows.
* [ ] ADJUST BPM IN receptor instead of taking first BPM.

## Code maintenance

* [ ] Refactor and tidy up all functions and global variables.
* [ ] Document every function.
* [ ] Document every variable and global variables.
