class SearchController < ApplicationController

  require "nokogiri"

  PAGE_SIZE = 20
  INDEX_NAME = 'main_index'

  class SearchResult
    attr_reader :model

    def initialize(model, controller)
      @model = model
      @controller = controller
    end

    def title
      unless @title
        @title =  case(@model)
                    when TextPage
                      @model.section.title
                    else
                      @model.title # News, Ckeditor::AttachmentFile
                    end
      end
      @title
    end

    def description
      unless @description
        @description = case(@model)
                         when Ckeditor::AttachmentFile
                          @model.description
                         else
                          n = Nokogiri::HTML(@model.body)
                          n.css('style,br').remove
                          n.text.strip.gsub(/\s+/, ' ') # News, TextPage
                         end
      end
      @description
    end

    def path
      unless @path
        @path = case(@model)
                  when TextPage
                    @controller.section_path(@model.section)
                  when News
                    @controller.news_path(@model)
                  when Ckeditor::AttachmentFile
                    @model.url
                  else
                  '/'
                end
      end
      @path
    end

    def type
      unless @type
        @type = case(@model)
                  when TextPage
                   'search.types.pages'
                  when News
                    'search.types.news'
                  when Ckeditor::AttachmentFile
                    'search.types.files'
                  else
                    'Undefined'
                end
      end
      @type
    end

    def section_chain
      unless @section_chain
        @section_chain = case(@model)
                           when TextPage
                            @model.section
                           when News
                            Section.find_by_name(Section::NEWS_NAME)
                           when Ckeditor::AttachmentFile
                            @model.section
                          else
                            nil
                         end
        @section_chain = @section_chain ? @section_chain.chain : []
      end
      @section_chain
    end
  end

  def search_words
    @page_number = [(params[:page] || '1').to_i, 1].max - 1
    @query = params['words'] || params['wordsline']
    @query = @query.to_s.strip
    @words = @query.split.select{|w| w.size > 2}.map(&:strip)
    @results = []
    if !@query || @query.size < 3 && @words.size == 0
      flash.now[:alert] = I18n.t('search.empty_request')
    elsif @words.size > 3
      flash.now[:alert] = I18n.t('search.more_word_request')
    else
      # array of SearchResult
      @results = []
      @results_by_type = {}

      translations = []
      words_query = @words.map{|w| w.to_s + '~ OR ' + w.to_s + '*'}.map{|q| "(#{q})" }.join(' OR ')
      query = ['title', 'body', 'description'].map{|field| "#{field}_#{I18n.locale}:(#{words_query})"  }.join(' OR ')
      @translations_quantity, @translations = \
        ActsAsFerret.find_ids(query, INDEX_NAME, :limit => PAGE_SIZE, :offset => PAGE_SIZE * @page_number)
      @pages = (@translations_quantity.to_f / PAGE_SIZE).ceil

      if(@translations_quantity == 0)
        flash.now[:notice] = I18n.t('search.empty_result')
      else
        # всё хорошо
        @translations.each do |translation|
          model_class = eval(translation[:model])
          model = model_class.find(translation[:id]) rescue nil
          next unless model
          s = SearchResult.new(model, self)
          @results << s
          @results_by_type[s.type] = [] unless @results_by_type[s.type]
          @results_by_type[s.type] << s
        end
      end
    end
  end
end
