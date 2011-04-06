require 'tilt'

class ComplexView
  def header
    "Colors"
  end

  def item
    unless defined? @items
      @items ||= []
      @items << { :name => 'red', :current => true, :url => '#red' }
      @items << { :name => 'green', :current => false, :url => '#green' }
      @items << { :name => 'blue', :current => false, :url => '#blue' }
    end

    @items
  end
end
