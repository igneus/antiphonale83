# Antiphonale Romanum 1983

Collection of chants following the [1983 Ordo cantus officii][oco].

(Yes, I do know that there is already
a [new 2015 edition of the OCO][oco2015].)

## Building

Install [gregorio][gregorio] (version 4.x is required)
and LuaLaTeX.

Get some Ruby interpreter and install gems `gly` and `rake`.

`gem install gly rake`

Gemfile is also available for those who like to use Bundler.

Then run rake tasks. `rake` alone builds all possible
targets.

See output of `rake -T` for available targets.
E.g. `rake libelli:psalterium` builds a book containing
all already transcribed chants of the psalter.

## How to contribute

Contributions in form of score transcriptions are most welcome.

Scores are entered in the [gly][gly] format.

[oco]: http://musicasacra.com/pdf/LOTH-schema.pdf
[oco2015]: http://www.libreriaeditricevaticana.va/content/libreriaeditricevaticana/it/novita-editoriali/ordo-cantus-officii.html

[gly]: https://github.com/igneus/gly
[gregorio]: http://gregorio-project.github.io
