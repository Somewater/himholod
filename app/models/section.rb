class Section < ActiveRecord::Base

  MAIN_NAME = 'main'
  NEWS_NAME = 'news'
  FEEDBACK_NAME = 'feedback'
  ORDER = "weight ASC"
  CONDITIONS = 'visible = TRUE'

  extend ::I18nColumns::Model
  i18n_columns :title

  attr_accessible :name, :weight, :visible, :parent_id, :picture_id
  belongs_to :parent, :class_name => 'Section'
  belongs_to :picture, :class_name => 'Ckeditor::Picture'
  has_many :children, :class_name => 'Section', :foreign_key => 'parent_id', :order => Section::ORDER, :conditions => CONDITIONS
  has_many :text_pages
  has_many :ckeditor_assets, :class_name => 'Ckeditor::AttachmentFile'

  validates :parent, :presence =>  { :unless => :main? }
  validates :name, :presence => true, :format => /^[a-z][a-z0-9\-]+$/ , :unless => :main?

  def self.main
    self.find_by_name(MAIN_NAME)
  end

  def self.tree
    self.find_all_by_parent_id(Section.main.id, :order => Section::ORDER, :conditions => CONDITIONS)
  end

  def main?
    self.name == MAIN_NAME
  end

  def feedback?
    self.name == FEEDBACK_NAME
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

  def hierarchy_name
    n = self.pretty_name
    self.chain(true).reverse.drop(1).each_with_index do |section, index|
      if index > 2
        n = '.. > ' + n
        break
      end
      n = section.pretty_name + ' > ' + n
    end
    n
  end

  def pretty_name
    t = self.title
    t && t.size > 0 ? t : self.name
  end
end
