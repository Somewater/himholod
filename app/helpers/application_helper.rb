module ApplicationHelper
  def each_with_borders(array, &block)
    last_index = array.size - 1
    index = 0
    array.each do |item|
      block.call(item, index, index == last_index)
      index += 1
    end
  end

  def section_path(id)
    if(id.to_s == Section::MAIN_NAME || (id.is_a?(Section) && id.main?))
      '/'
    else
      super
    end
  end

  def print_path(item)
    case item
      when TextPage
        super(:type => PrintController::PAGE, :id => item)
      else
        super
    end
  end
end
