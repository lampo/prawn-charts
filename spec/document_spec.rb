require_relative 'spec_helper'

describe Prawn::Document do
  subject { Prawn::Document.new }

  specify { subject.must_respond_to :bar_chart }
end
