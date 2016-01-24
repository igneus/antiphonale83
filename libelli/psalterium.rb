require 'gly'
require 'set'

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

    @scores_to_compile = Set.new
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

    @scores_to_compile.each do |gabc_fname|
      system "gregorio #{gabc_fname}"
    end
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

    if resp_id_base.include? 'dominica'
      hour 'Ad I Vesperas'
      2.times {|i| antiphon "vi#{i+1}", doc }
      antiphon "vi3", doc, repeated: true
      responsory "#{resp_id_base}vi", resp_doc
      puts
    end

    hour 'Ad Officium lectionis'

    if doc['ol1a']
      puts '\emph{in Adventu, tempore Nativitatis, in Quadragesima et tempore paschali:}'
      puts
      3.times {|i| antiphon "ol#{i+1}a", doc, may_not_exist: i > 0 }
      puts
      puts '\emph{tempore per annum:}'
      puts
    end

    3.times {|i| antiphon "ol#{i+1}", doc, may_not_exist: i > 0 }
    puts

    hour 'Ad Laudes matutinas'
    3.times {|i| antiphon "l#{i+1}", doc }
    responsory "#{resp_id_base}l", resp_doc
    antiphon 'lb', doc, repeated: true unless resp_id_base.include? 'dominica'
    puts

    hour 'Ad Horam mediam'
    3.times {|i| antiphon "m#{i+1}", doc }
    puts

    unless resp_id_base.include? 'sabbato'
      if resp_id_base.include? 'dominica'
        hour 'Ad II Vesperas'
        antiphon "v1", doc, repeated: true
        antiphon "v2", doc
        # Ap 19 has no antiphons in psalter
      else
        hour 'Ad Vesperas'
        2.times {|i| antiphon "v#{i+1}", doc }
        antiphon 'v3', doc, repeated: true
      end
      responsory "#{resp_id_base}v", resp_doc
      antiphon 'vm', doc, repeated: true unless resp_id_base.include? 'dominica'
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
      if options[:may_not_exist] != true
        puts '\emph{Antiphona %s non est inventa.}' % aid
      end

      return
    end

    gabc_fname = File.basename(ant_source.path, '.gly') + "_#{aid}.gabc"

    @scores_to_compile << gabc_fname

    gtex_fname = gabc_fname.sub /\.gabc/i, '.gtex'
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
