class SearchController < ApplicationController

  class SearchResult
    attr_reader :model, :text_fields

    def initialize(model, text_fields, controller)
      @model = model
      @text_fields = text_fields
      @controller = controller
    end

    def title
      unless @title
        @title =  case(@model)
                    when TextPage
                      @model.section.title
                    else
                      @model.title
                    end
      end
      @title
    end

    def description
      unless @description
        @description = @model[@text_fields.first] || ''
      end
      @description
    end

    def path
      unless @path
        @path = case(@model)
                  when TextPage
                    @controller.section_path(@model.section)
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
                  else
                    'Undefined'
                end
      end
      @type
    end
  end

  def search_words
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
      #Product::Translation.where(['CONCAT(description,title) LIKE ("%?%")', word])

      translations = []
      translated_class_to_fields = {}
      [TextPage].each do |model_class|
        translated_fields = model_class.columns.select{|c| c.type == :text}.map(&:name)
        if(translated_fields.size > 0)
          @words.each do |word|
            result = model_class.where(["CONCAT(#{translated_fields.map{|m| "IFNULL(#{m},'')" }.join(',')}) LIKE (?)", '%' + word.to_s + '%'])
            translations << result.to_a if result && result.size > 0
          end
          translated_class_to_fields[model_class] = [model_class, translated_fields]
        end
      end

      translations_uniq = []
      translations.flatten.each{|t|translations_uniq << t unless translations_uniq.index(t)}

      if(translations_uniq.size == 0)
        flash.now[:notice] = I18n.t('search.empty_result')
      elsif translations_uniq.size > 50
        flash.now[:notice] = I18n.t('search.empty_result')
      else
        # всё хорошо
        translations_uniq.slice(0,20).each do |translation|
          model_class, translated_fields = translated_class_to_fields[translation.class]
          s = SearchResult.new(translation, translated_fields, self)
          @results << s
          @results_by_type[s.type] = [] unless @results_by_type[s.type]
          @results_by_type[s.type] << s
        end


      end
    end
  end
end
