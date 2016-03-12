require_relative 'lib/antiphonal'

include Antiphonal
include Antiphonal::Helpers

Builder.new do |b|
  1.upto(5) do |week|
    b.chapter "Hebdomada #{roman(week)}"

    doc = b.documents["../quadragesima/hebdomada#{week}.gly"]
    Weekdays.each do |day|
      b.section day.latin

      b.antiphon doc[day.shortcut + 'b']
      b.antiphon doc[day.shortcut + 'm']
    end
  end
end.build!
