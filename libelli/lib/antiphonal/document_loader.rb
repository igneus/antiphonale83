module Antiphonal
  # loads and caches gly documents
  class DocumentLoader
    def initialize(dir='.')
      @base_dir = dir
      @cache = {}
      @parser = Gly::Parser.new
    end

    # loads gly document or returns it from cache
    def [](path)
      fullpath = File.expand_path path, @base_dir
      @cache[fullpath] ||= load fullpath
    end

    private

    def load(path)
      File.open(path) do |fr|
        return @parser.parse fr
      end
    end
  end
end
