module StringScore

  class InternalError < RuntimeError; end
  class ArgumentError < RuntimeError; end

  def score(target_string, fuzziness = 0.0)
    if @string_scorer && @string_scorer.base_string != self
      @string_scorer = nil
    end
    @string_scorer ||= StringScore.new(self, fuzziness)
    @string_scorer.score(target_string)
  end

  # proxy to Scorer to simplify calling API
  def self.new(base_string, fuzziness=0.0)
    StringScore::Scorer.new(base_string.to_s, fuzziness)
  end

end

require 'string_score/scorer'
