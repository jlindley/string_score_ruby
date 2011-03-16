module StringScore

  class InternalError < RuntimeError; end
  class ArgumentError < RuntimeError; end

  NON_STRING_MSG = "Supply a string or an object with can be coerced to a string."
  NON_STRING_ERROR_MESSAGE = /undefined method `to_s'/

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

  class Scorer

    attr_accessor :base_string, :default_fuziness

    def initialize(string, fuzziness=0.0)
      with_error_handling do
        @default_fuziness = fuzziness
        @base_string = string.to_s
      end
    end

    def score(target_string, fuzziness=nil)
      with_error_handling do
        return 1 if (base_string == target_string.to_s)
        partial_score(target_string, (fuzziness || default_fuziness))
      end
    end

    def partial_score(target, fuzziness)

      string = base_string.dup # clean copy for chomping
      over_all_index = 0

      cumulative_score = 0.0

      target_length = target.length.to_f
      string_length = string.length.to_f

      start_of_string_bonus = false

      abbreviation_score = 0
      fuzzies = 1.0
      final_score = 0.0

      target_index = 0

      target.each_char do |c|
        over_all_index = (base_string.length - string.length)

        character_score = 0.0

        index_c_lowercase = string.index(c.downcase)
        index_c_uppercase = string.index(c.upcase)

        current_index = [index_c_lowercase, index_c_uppercase].compact.min
        over_all_index += current_index.to_i

        if ! current_index

          if fuzziness > 0.0
            fuzzies += (1 - fuzziness)
            target_index += 1
            next
          else
            return 0 # abort on any mismatch
          end

        end

        if string.slice(current_index, 1) == c
          character_score = 0.2 # exact case match
        else
          character_score = 0.1 # character but not case match
        end

        # consecutive bonus
        if current_index == 0
          character_score += 0.6
          if target_index == 0
            start_of_string_bonus = true
          end
        end

        # acronym bonus
        previous_index = over_all_index - 1
        if base_string.slice(previous_index, 1) == ' '
          character_score += 0.8
        end

        cumulative_score += character_score
        target_index += 1
        string = string[(current_index + 1), (string.length - 1)]
      end

      matched_score = cumulative_score.to_f / string_length.to_f

      with_long_string_bonus = (((matched_score * (target_length.to_f / string_length.to_f)) + matched_score) / 2)

      final_score = with_long_string_bonus / fuzzies

      if start_of_string_bonus
        if final_score + 0.15 < 1.0
          final_score += 0.15
        elsif final_score + 0.15 >= 1.0
          final_score = 1.0
        end
      end

      if final_score > 1.0 || final_score < 0.0
        raise StringScore::InternalError, "Out of range score: '#{final_score}'"
      end

      final_score
    end

    def with_error_handling

      yield

    rescue StringScore::InternalError, StringScore::ArgumentError

      raise # allow nesting of #with_error_handling

    rescue NoMethodError => e

      if e.message =~ NON_STRING_MSG
        raise StringScore::ArgumentError, NON_STRING_MSG
      else
        raise StringScore::InternalError, "#{e.class}: #{e.message}"
      end

    rescue => e

      raise StringScore::InternalError, "#{e.class}: #{e.message}"

    end

  end

end
