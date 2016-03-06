# Antiphonale Romanum 1983

Collection of chants following the [1983 Ordo cantus officii][oco].

(Yes, I do know that there is already
a [new 2015 edition of the OCO][oco2015].)

## Building

Install [gregorio][gregorio] (version 4.x is required)
and LuaLaTeX.

Get some Ruby interpreter and install gems `gly` and `rake`.

`gem install gly rake`

Then run rake tasks. `rake` alone builds all possible
targets.

See output of `rake -T` for available targets.
E.g. `rake libelli:psalterium` builds a book containing
all already transcribed chants of the psalter.

(If the build crashes, don't hesitate to punch me.
I always use the latest development version of `gly` for work
on this project and I am quite reluctant releasing new `gly` versions,
so the last released `gly` isn't always capable of building
this project.)

## How to contribute

Contributions are most welcome.

* transcribe scores from the printed sources designated
  by OCO (e.g. antiphons for some feast)
* proofread some part of the existing transcriptions
* transcribe some of the unedited antiphons
* criticize and improve existing transcriptions of unedited
  antiphons

[oco]: http://musicasacra.com/pdf/LOTH-schema.pdf
[oco2015]: http://www.libreriaeditricevaticana.va/content/libreriaeditricevaticana/it/novita-editoriali/ordo-cantus-officii.html

[gly]: https://github.com/igneus/gly
[gregorio]: http://gregorio-project.github.io
