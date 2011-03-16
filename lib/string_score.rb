module StringScore

  class InternalError < RuntimeError; end
  class ArgumentError < RuntimeError; end

  def score(target_string, fuzziness = 0.0)
    StringScore.new(self, fuzziness).score(target_string)
  end

  def sort_by_score(target, fuzziness = 0.0, &block)
    StringScore.new(self, fuzziness).sort_by_score(target)
  end

  # proxy to Scorer to simplify calling API
  def self.new(base_string, fuzziness=0.0)
    StringScore::Scorer.new(base_string.to_s, fuzziness)
  end

end

require 'string_score/scorer'
