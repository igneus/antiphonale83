# builder.rb

require 'gly'
require 'set'

module Antiphonal
  # builds TeX source code of an antiphonal or a similar book(let)
  class Builder
    def initialize(write_to=nil, &block)
      @build_block = block
      @out_fname = write_to
      @documents = DocumentLoader.new Dir.pwd
      @scores_to_compile = []
    end

    attr_accessor :title, :subtitle
    attr_reader :documents

    # for direct printing to the output stream
    attr_reader :out

    def build!
      @out = File.open output_path, 'w'
      @build_block.call self
      @out.close
    end

    # print TeX command with argument(s)
    def tex_cmd(cname, *args)
      @out.puts "\\" + cname + args.collect {|a| "{#{a}}"}.join('')
    end

    # common TeX commands for quick use
    TEX_COMMANDS = %w(chapter section subsection subsubsection)
    TEX_COMMANDS.each do |c|
      define_method c do |arg|
        tex_cmd(c, arg)
      end
    end

    # build a score as antiphon
    def antiphon(score, options={})
      unless score
        if options[:may_not_exist] != true
          puts '\emph{Antiphona non est inventa.}'
        end

        return
      end

      title = piece_title(score)
      unless title.empty?
        puts "\\grecommentary{\\footnotesize{#{title}}}"
        puts '\nobreak'
      end

      annotations = score.headers.each_value('annotation')
      begin
        puts "\\greannotation{#{annotations.next}}"
        puts "\\greannotation{#{annotations.next}}"
      rescue StopIteration
        # ok, no more annotations
      end

      gtex_fname = score.gabc_fname.sub /\.gabc/i, '.gtex'
      puts "\\gregorioscore{#{gtex_fname}}"
      puts '\vspace{3mm}'
    end

    # build short text to be printed above the antiphon
    # (usually source/author information)
    def piece_title(score)
      %w(book manuscript arranger author).collect do |m|          score.headers[m]
      end.delete_if(&:nil?).join ', '
    end

    private

    def output_path
      @out_fname || File.basename($0.sub(/\.rb/i, '.tex'))
    end
  end
end
