require 'gly'

def roman(int)
  [nil, 'I', 'II', 'III', 'IV'][int]
end

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
      if k.include? 'responsoria'
        Gly::DocumentGabcConvertor.new(@documents[k]).convert
        next
      end

      w = k[1].to_i
      if w != week
        puts '\chapter{%s}' % "Hebdomada #{roman(w)}"
        week = w
      end

      doc = @documents[k]
      base_week = week > 2 ? week - 2 : week
      resp_doc = @documents["h#{base_week}responsoria.gly"]

      day doc, resp_doc
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
    puts '\tableofcontents'
    puts '\end{document}'
  end

  def day(doc, resp_doc)
    convertor = Gly::DocumentGabcConvertor.new(doc)
    convertor.convert

    resp_id_base = File.basename(doc.path, '.gly')[2..-1]

    puts '\section{%s}' % doc.header['title']
    puts

    hour 'Officium lectionis'
    3.times {|i| antiphon "ol#{i+1}", doc }
    puts

    hour 'Laudes matutinae'
    3.times {|i| antiphon "l#{i+1}", doc }
    responsory "#{resp_id_base}l", resp_doc
    antiphon 'lb', doc, repeated: true
    puts

    hour 'Hora media'
    3.times {|i| antiphon "m#{i+1}", doc }
    puts

    unless File.basename(doc.path).include? 'sabbato'
      hour 'Vesperae'
      2.times {|i| antiphon "v#{i+1}", doc }
      antiphon 'v3', doc, repeated: true
      responsory "#{resp_id_base}v", resp_doc
      antiphon 'vm', doc, repeated: true
      puts
    end
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

  alias_method :responsory, :antiphon
end

PsalterBuilder.new.build!
