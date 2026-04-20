require "./base.rb"

class WriteLine < BaseNode

  def initialize(args = [])
    @args = args
  end

  def evaluate()
    return @args
  end 
end