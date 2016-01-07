require 'gly'

class PsalterBuilder
  def initialize
    # gly file basename => Gly::Document
    @documents = {}

    parser = Gly::Parser.new

    Dir['../psalterium/h*.gly'].each do |f|
      File.open(f) do |fr|
        @documents[File.basename(f)] = parser.parse fr
      end
    end
  end

  def build!
    header

    week = 0
    @documents.keys.sort.each do |k|
      w = k[1].to_i
      if w != week
        puts '\chapter*{%s}' % "Hebdomada #{'I' * w}"
        week = w
      end

      doc = @documents[k]

      day doc
    end

    footer
  end

  def header
    rep = {
      title: 'Psalterium\\\\ per quattuor hebdomadas distributum',
      subtitle: 'Cum cantu secundum Ordo cantus officii 1983'
    }
    puts File.read('header.tex') % rep
  end

  def footer
    puts '\end{document}'
  end

  def day(doc)
    convertor = Gly::DocumentGabcConvertor.new(doc)
    convertor.convert

    puts '\section*{%s}' % doc.header['title']
    puts

    hour 'Laudes matutinae'
    %w(l1 l2 l3).each {|aid| antiphon aid, doc }
    puts

    unless File.basename(doc.path).include? 'sabbato'
      hour 'Vesperae'
      %w(v1 v2).each {|aid| antiphon aid, doc }
      antiphon 'v3', doc, repeated: true
    end
    puts
  end

  def hour(t)
    puts '\subsection*{%s}' % t
  end

  def antiphon(aid, document, options={})
    score = document[aid]
    ant_source = document

    if options[:repeated] && ! score
      docname = File.basename document.path
      week = docname[1].to_i

      lookup_weeks = [week % 2, 1]

      lookup_weeks.each do |w|
        ant_source = @documents[docname.sub(/h\d/, "h#{w}")]
        score = ant_source && ant_source[aid]
        break if score
      end
    end

    unless score
      puts '\emph{Antiphona %s non est inventa.}' % aid
      return
    end

    gabc_fname = File.basename(ant_source.path, '.gly') + "_#{aid}.gabc"

    system "gregorio #{gabc_fname}"

    gtex_fname = gabc_fname.sub /\.gabc/i, ''
    piece_title = %w(book manuscript arranger author).collect do |m|          score.headers[m]
    end.delete_if(&:nil?).join ', '
    unless piece_title.empty?
      puts "\\commentary{\\footnotesize{#{piece_title}}}"
      puts '\nobreak'
    end

    annotations = score.headers.each_value('annotation')
    begin
      puts "\\setfirstannotation{#{annotations.next}}"
      puts "\\setsecondannotation{#{annotations.next}}"
    rescue StopIteration
      # ok, no more annotations
    end

    puts "\\includescore{#{gtex_fname}}"
    puts '\vspace{3mm}'
  end
end

PsalterBuilder.new.build!
