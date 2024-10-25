#(set-global-staff-size 45)

\layout {
  \override VaticanaLyrics.LyricText.font-size = #-1
}

\paper {
  #(define fonts
     (make-pango-font-tree
      "Junicode"
      "VL Gothic"
      "Courier"
      (/ staff-height pt 25)))
}
