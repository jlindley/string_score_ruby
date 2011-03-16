require 'string_score'

String.send(:include, StringScore)

RSpec::Matchers.define :be_greater_than do |expected|
  match do |actual|
    expected < actual
  end
end

RSpec::Matchers.define :be_less_than do |expected|
  match do |actual|
    expected > actual
  end
end

RSpec::Matchers.define :be_about do |expected|
  match do |actual|
    expected.to_f.round(5) == actual.to_f.round(5) # to 3 decimal points
  end
end

describe StringScore do

  subject { StringScore.new('Hello World') }

  it "provides a method directly on a string instance" do
    "foobar".score('foo').should == StringScore.new("foobar").score('foo')
  end

  it "scores at 1 for exact match" do
    subject.score('Hello World').should == 1
  end

  # probably rare but need to handle just in case
  it "allows updates of string to match against" do
    string_to_match = "Hello World"
    string_to_match.score('Hello World').should == 1
    string_to_match.gsub!(/\w/, 'X')
    string_to_match.score('Hello World').should_not == 1
  end

  it "scores 0 for non-matches (character not in string)" do
    subject.score("hellx").should == 0
    subject.score("hello_world").should == 0
  end

  it "matches sequentially" do
    subject.score('WH').should == 0
  end

  it "prefers same-case matches" do
    subject.score('hello').should be_less_than(subject.score('Hello'))
  end

  it "scores higher on closers matchs" do
    subject.score('H').should be_less_than(subject.score('He'))
  end

  it "will match despite wrong case" do
    subject.score("hello").should be_greater_than(0)
  end

  it "scores progressively higher weighting on more matches" do
    subject.score("e").should be_less_than(subject.score("h"))
    subject.score("h").should be_less_than(subject.score("he"))
    subject.score("hel").should be_less_than(subject.score("hell"))
    subject.score("hell").should be_less_than(subject.score("hello"))
    subject.score("hello").should be_less_than(subject.score("helloworld"))
    subject.score("helloworl").should be_less_than(subject.score("hello worl"))
    subject.score("hello worl").should be_less_than(subject.score("hello world"))
  end

  it "provides a consecutive letter bonus" do
    subject.score('Hel').should be_greater_than(subject.score('Hld'))
  end

  it "gives an acronym bonus" do
    subject.score('HW').should be_greater_than(subject.score('Ho'))
    'yet another Hello World'.score('yaHW').should be_greater_than('Hello World'.score('yet another'))
    "Hillsdale Michigan".score("HiMi").should be_greater_than("Hillsdale Michigan".score("Hill"))

    # I think these pass in error in the js version, will check
    # "Hillsdale Michigan".score("HiMi").should be_greater_than("Hillsdale Michigan".score("hills"))
    # "Hillsdale Michigan".score("HiMi").should be_greater_than("Hillsdale Michigan".score("hillsd"))
    # "Hillsdale Michigan".score("HiMi").should be_greater_than("Hillsdale Michigan".score("illsda"))
  end

  it "gives a bonus for matching the start of the string" do
    "Hillsdale".score("hi").should be_greater_than("Chippewa".score("hi"))
    "hello world".score("h").should be_greater_than("hello world".score("w"))
  end

  it "gives proper string weights" do
    "Research Resources North".score('res').should be_greater_than("Mary Conces".score('res'))
    "Research Resources North".score('res').should be_greater_than("Bonnie Strathern - Southwest Michigan Title Search".score('res'))
  end

  it "gives start of string bonuses" do
    "Mary Large".score('mar').should be_greater_than("Large Mary".score('mar'))
    "Silly Mary Large".score('mar').should be_about("Silly Large Mary".score('mar'))
  end


  it "can fuzzily match strings" do
    subject.score('Hz').should == 0
    subject.score('Hz', 0.5).should be_less_than(subject.score('H', 0.5))
  end

  it "should be tuned well" do
    "hello world".score("hello worl", 0.5).should be_greater_than("hello world".score("hello wor1", 0.5))
    'Hello World'.score('jello',0.5).should be_greater_than(0)
  end

  it "should have varying degrees of fuziness" do
    subject.score('Hz', 0.9).should be_greater_than(subject.score('Hz', 0.5))
  end

end
