require_relative 'spec_helper'

describe Prawn::Charts::Base do
  subject { Prawn::Charts::Base.new }

  def defaults
    {
      padding:  10,
      at:       [0,0],
      width:    500,
      height:   200,
      spacing:  10,
    }
  end

  def override
    {
      padding:  2,
      at:       [10,10],
      width:    50,
      height:   3,
      spacing:  2,
    }
  end

  describe 'attributes' do
    specify { subject.must_respond_to :title }
    specify { subject.must_respond_to :legend }
    specify { subject.must_respond_to :padding }
    specify { subject.must_respond_to :x }
    specify { subject.must_respond_to :y }
    specify { subject.must_respond_to :y1 }
    specify { subject.must_respond_to :at }
    specify { subject.must_respond_to :width }
    specify { subject.must_respond_to :height }
    specify { subject.must_respond_to :spacing }
  end

  describe 'defaults' do
    specify { subject.defaults.must_equal defaults }
    specify { subject.padding.must_equal defaults[:padding] }
    specify { subject.at.must_equal defaults[:at] }
    specify { subject.width.must_equal defaults[:width] }
    specify { subject.height.must_equal defaults[:height] }
    specify { subject.spacing.must_equal defaults[:spacing] }

    describe 'overriding defaults' do
      subject { Prawn::Charts::Base.new(override) }
      specify { subject.padding.must_equal 2 }
      specify { subject.at.must_equal [10,10]}
      specify { subject.width.must_equal 50}
      specify { subject.height.must_equal 3}
      specify { subject.spacing.must_equal 2}
    end
  end
end
