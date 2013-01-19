class Section < ActiveRecord::Base

  extend ::I18nColumns::Model
  i18n_columns :title

  attr_accessible :name, :weight, :visible, :parent_id
  belongs_to :parent, :class_name => 'Section'

  MAIN_NAME = 'main'
  ORDER = "weight ASC"

  def self.main
    self.find_by_name(MAIN_NAME)
  end

  def self.tree
    self.find_all_by_parent_id(Section.main.id, :order => Section::ORDER)
  end

  def main?
    self.name == MAIN_NAME
  end

  def to_param
    self.name
  end

  def parents
    result = []
    p = self.parent
    while(p)
      result.unshift(p)
      p = p.parent
    end
    result
  end

  def chain(main = false)
    # цепочка от родителей до указанной секции (исключая главную секцию)
    result = [self]
    p = self.parent
    while(p && (main || !p.main?))
      result.unshift(p)
      p = p.parent
    end
    result
  end

  def children
    Section.find_all_by_parent_id(self.id, :order => Section::ORDER) || []
  end
end
