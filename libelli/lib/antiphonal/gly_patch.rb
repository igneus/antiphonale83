module Gly
  class Document
    alias_method :old_add, :<<

    def <<(score)
      old_add score
      score.gabc_fname = score_gabc_fname(score)
    end

    private

    def score_gabc_fname(score)
      unless score.headers['id']
        raise RuntimeError.new('score has no id')
      end

      @path.sub(/\.tex$/i, "_#{score.headers['id']}.gabc")
    end
  end

  class Score
    attr_accessor :gabc_fname
  end
end
