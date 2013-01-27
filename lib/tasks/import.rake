# encoding: utf-8
namespace :import do
  desc "Load topics from himholod.ru and save to db"
  task :topics => :environment do
    importer = create_importer()
    importer.topics()
  end

  desc "Load files from himholod.ru and save to db"
  task :files => :environment do
    importer = create_importer()
    importer.files()
  end

  desc "Load news from himholod.ru and save to db"
  task :news => :environment do
    importer = create_importer()
    importer.news()
  end

  def create_importer()
    require "nokogiri"
    require "open-uri"
    OpenURI::Buffer.send :remove_const, 'StringMax' if OpenURI::Buffer.const_defined?('StringMax')
    OpenURI::Buffer.const_set 'StringMax', 0 # всегда работать с tempfile
    require "net/http"
    require "uri"
    require "pdf-reader"
    Himholod::Importer.new
  end
end

module Himholod
  class Importer

    BASE_PATH = "http://himholod.ru"

    def topics()
      log "TOPICS import starting"
      sections = (get_sections() << Section.generate_main)
      sections.each_with_index do |section, index|
        unless section.model
          raise "SECTION '#{section.title}'->'#{section.src}' not processed" unless Section::CAN_PASS.index(section.src)
          next
        end
        page = process_page(section, true)

        complete = ((index + 1) / sections.size.to_f * 100).round
        log "Page '#{page.original_uri}' created. Progress #{complete}%"
      end
    end

    def news()
      log "NEWS import starting"
      doc = Nokogiri::HTML(open(BASE_PATH + '/'), "r:windows-1251")
      html = doc.children.last
      body = html.children.last
      table = body.xpath('//table[@width="254"]').last
      tds = table.xpath('tr/td')
      tds.each_with_index do |td, index|
        next unless td['style']
        date = Time.parse(td.text.strip.match(/(?<str>\d+\/\d+\/\d+).+/)[:str])
        link = td.at_css('a')
        title = link.content.strip
        doc = Nokogiri::HTML(open(BASE_PATH + '/' + link['href']), "r:windows-1251")
        html = doc.children.last
        body = html.children.last
        table = body.at_xpath('//table[@height="1000"]')
        content = table.xpath('tbody/tr[2]/td[2]/*')
        images = content.css('img').to_a
        page = Page.new(content, link['href'])
        images.each_with_index do |img, index|
          page.create_image(img)
          complete = ((index + 1) / images.size.to_f * 100).round
          log "   Image '#{img['src']}' completed. Images progress #{complete}%"
        end
        content = Page.remove_title(content)

        n = News.new
        n.date = date
        n.title = title
        n.body = content
        n.save

        complete = ((index + 1) / tds.size.to_f * 100).round
        log "Progress #{complete}%"
      end
    end

    def files()
      log "FILES import starting"
      page = get_page(Section::FILES_INDEX)
      page.file_list()
    end

    def process_page(section, top_level = false)
      page = get_page(section.src)
      page.top_level = top_level
      page.section = section
      sub_sections = page.create!
      sub_sections.each do |sub_section|
        process_page(sub_section)
      end
      page
    end

    def log(*args)
      args.each{|arg| puts arg }
    end

    def get_page(page)
      doc = Nokogiri::HTML(open(BASE_PATH.dup << (page[0,1] == '/' ?  '' : '/') << page.to_s, "r:windows-1251"))
      html = doc.children.last
      body = html.children.last
      table = body.at_xpath('//table[@height="1000"]')
      content = table.xpath('tbody/tr[2]/td[2]/*')
      Page.new(content, page)
    end

    def get_sections()
      doc = Nokogiri::HTML(open(BASE_PATH))
      items = doc.xpath('//div[@id="masterdiv"]//a').map{|n| ::Himholod::Section.new(n) }.select(&:valid?)
      items
    end
  end

  class Section

    FILES_INDEX = "index.php?mid=268"

    CONFIG = {
              'address' => ['Наши координаты'],
              'about' => ['О компании'],
              'management' => ['Система менеджмента качества'],
              #'publications' => ['Публикации в прессе'],  # раздел
              'press' => ['Печатные статьи'],
              #'refrigerating-equipment' => ['Холодильное оборудование'],  # раздел
              'production' => ['Производство'],
              'special-project' => ['Спортивные сооружения'],
              'industrial-project' => ['Объекты общепромышленного характера'], # пусто
              'refrigerating-container' => ['Холодильные установки контейнерного типа'],
              'designing' => ['Проект'],
              'energy-saving' => ['Энергосберегающие технологии'],
              'mobile-coolers' => ['Мобильные холодильные установки контейнерного типа'],
              'services' => ['Сервисное обслуживание'],
              'vacancy' => ['Вакансии компании'],
              'ignore1' => ['Полезная информация'],
              'reference' => [
                              #'Референц-лист проектов',  # раздел
                              'Референц-лист спортивных объектов',
                              'Референц-лист "Холодильные установки контейнерного типа"',
                              'Объекты молочной промышленности',
                              'Объекты промышленного назначения',
                              'Объекты производства соков и детского пиания',
                              'Каток СДЮШОР г.Вологда',
                              'Конькобежный центр "КОЛОМНА" 2012 г. Московская область',
                              'Ледовый Дворец спорта «Дизель-Арена»  ',  # пусто
                              'Ледовый дворец "Марий Эл" г. Йошкар-Ола, сдан в эксплуатацию в 2006 году',
                              'Тренировочный ледовый каток "Дружба" в г. Йошкар-Ола, сдан в эксплуатацию в 2006 году',
                              'Дворец спорта "Янтарь"',
                              'СНЕЖКОМ',
                              'Каток "Лебединое озеро" г. Ереван',
                              'Модернизация катков МОСКОМСПОРТА в 2008 году'],
              'ignore3' => ['Распродажа!!!'],
              'ignore4' => ['Карта сайта'],
              'ignore5' => ['Информация'],
              'testimonial' => ['ОТЗЫВЫ наших клиентов'], # пусто


              #####################
              #                   #
              #   SUB SECTIONS    #
              #                   #
              #####################

              #   холодильные машины
              'refrigerating-equipment' => ['Чиллеры Climaveneta',
                                           'Панельные аккумуляторы холода типа BIC',
                                           'Аммиачные воздухоохладители навесные типа АВН и подвесные типа АВП',
                                           'Автоматические воздухоотделители марки «ВОА»',
                                           'Холодильные, морозильные камеры',
                                           'АММИАЧНЫЕ БЛОКИ ДЛЯ ПОЛУЧЕНИЯ «ЛЕДЯНОЙ ВОДЫ» типа ИПТ (ТРУБЧАТЫЕ ИСПАРИТЕЛИ ПЛЕНОЧНОГО ТИПА)'],
              #   Контейнерные установки
              'refrigerating-container' => ['Емкостное оборудование'],
              #  	Компрессорные агрегаты
              'compressor' => ['Компрессорные агрегаты и холодильные машины на базе полугерметичных компрессоров',
                               'Компрессорные агрегаты и холодильные машины на базе сальниковых компрессоров'],
              # 	Насосные агрегаты
              'pump' => ['$$$$$'],
              # 	Теплобменные аппараты
              'heat-exchanger' => ['Теплообменное оборудование и компрессорно-конденсаторные агрегаты фирмы  Friga Bohn',
                                   'Теплообменное оборудование фирмы  BUCO (Аккумуляторы холода)',
                                   'Теплообменные кожухотрубные аппараты производства ООО "НПФ "ХИМХОЛОДСЕРВИС"',
                                   'Испарительные конденсаторы типа VXC фирмы BALTIMORЕ',
                                   'Испарительные конденсаторы фирм DECSA и BALTIMORE',
                                   'Аммиачные испарительные блоки типа БИА',
                                   'КОНДЕНСАТОРЫ КОЖУХОТРУБЧАТЫЕ ГОРИЗОНТАЛЬНЫЕ АММИАЧНЫЕ КТГА и КГА',
                                   'ИСПАРИТЕЛИ АММИАЧНЫЕ  ИМКА-360 и ИМКА-460',
                                   'Испарительные конденсаторы типа МИК',
                                   'Испарители с внутритрубным кипением типа ИТ',
                                   'АММИАЧНЫЕ  КОЖУХОТРУБНЫЕ  ИСПАРИТЕЛИ ЗАТОПЛЕННОГО ТИПА  ИТГА',
                                   'КОНДЕНСАТОР МК-60',
                                   'Испарители МИ-90',
                                   'Пленочные испарители'],
              #   Комплектующие
              'utility' => ['ООО Маркетинговое предприятие «Мониторинг Экспресс»',
                            'МНОГОКАНАЛЬНЫЙ СТАЦИОНАРНЫЙ ГАЗОАНАЛИЗАТОР АММИАКА "ЭССА" ',
                            'Маслоохладители типа МОХ',
                            'СИЛОВЫЕ ЩИТЫ с устройством плавного пуска'],
              #   Энергосберегающие технологии
              'energy-saving' => ['$$$$$'],
              # 	Мобильные холодильные установки
              'mobile-coolers' => ['$$$$$'],




              # 	Мобильные холодильные установки
              'press-about-us' => ['Пресса о нас'],
              'scientific' => ['Научные труды'],
              'press' => ['Холодильные машины ООО "НПФ "ХИМХОЛОДСЕРВИС" для Ледовых дворцов',
                          'Энергосберегающие системы кондиционирования воздуха в спортивных и общественных зданиях, сооружаемых к Олимпиаде "Сочи 2014"',
                          'Реконструкция московских катков (2007г)'],
              'other' => ['Таблица перевода величин',
                          'РАСПРОДАЖА',
                          'ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ ИСПАРИТЕЛЬНЫХ КОНДЕНСАТОРОВ ТИПА VXC ФИРМЫ BALTIMORE',
                          'ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ ПАНЕЛЬНЫХ АККУМУЛЯТОРОВ ХОЛОДА ТИПА BIC',
                          'ТЕХНИЧЕСКИЕ ДАННЫЕ ИСПАРИТЕЛЬНЫХ КОНДЕНСАТОРОВ ФИРМЫ DECSA',
                          'АММИАЧНЫЕ ВОЗДУХООХЛАДИТЕЛИ НАВЕСНЫЕ ТИПА АВН И ПОДВЕСНЫЕ ТИПА АВП',
                          'АММИАЧНЫЕ БЛОКИ ДЛЯ ПОЛУЧЕНИЯ «ЛЕДЯНОЙ ВОДЫ» типа ИПТ',
                          'АММИАЧНЫЕ ИСПАРИТЕЛЬНЫЕ БЛОКИ ТИПА БИА',
                          'КОНДЕНСАТОРЫ КОЖУХОТРУБЧАТЫЕ ГОРИЗОНТАЛЬНЫЕ АММИАЧНЫЕ КТГА и КГА',
                          'ЕМКОСТНОЕ ОБОРУДОВАНИЕ',
                          'ИСПАРИТЕЛИ АММИАЧНЫЕ ИМКА-360 и ИМКА-460',
                          'ИСПАРИТЕЛЬНЫЕ КОНДЕНСАТОРЫ ТИПА МИК',
                          'ИСПАРИТЕЛИ С ВНУТРИТРУБНЫМ КИПЕНИЕМ ТИПА ИТ',
                          'АММИАЧНЫЕ КОЖУХОТРУБНЫЕ ИСПАРИТЕЛИ ЗАТОПЛЕННОГО ТИПА ИТГА',
                          'МНОГОКАНАЛЬНЫЙ СТАЦИОНАРНЫЙ ГАЗОАНАЛИЗАТОР АММИАКА ',
                          'МАСЛООХЛАДИТЕЛИ ТИПА МОХ',
                          'ИСПАРИТЕЛИ МИ-90',
                          'ПЛЕНОЧНЫЕ ИСПАРИТЕЛИ'],


              #######################
              #                     #
              #        FILES        #
              #                     #
              #######################
              'presentations' => [
                                  'Контейнеры',
                                  'Публ_Колосов8'
                                  ],
              'certification' => [
                                  'СЕРТИФИКАТЫ НА ХОЛОДИЛЬНЫЕ МАШИНЫ СЕРИИ 130, 420, 630',
                                  'СЕРТИФИКАТЫ НА АГРЕГАТЫ СЕРИИ А 130, А 420',
                                  'СЕРТИФИКАТ НА УХК',
                                  'СЕРТИФИКАТЫ ISO, OHSAS',
                                  'СЕРТИФИКАТЫ НА ХОЛОДИЛЬНЫЕ МАШИНЫ СЕРИИ МКТ ( МВТ) 50, 100, 130, 150, 200, 250, 300, 400, 500 ',
                                  'РАЗРЕШЕНИЕ НА ПРИМЕНЕНИЕ',
                                  'СЕРТИФИКАТ НА ЭЛЕКТРОЩИТЫ']
             }

    CAN_PASS = ['http://www.himholod.ru/','www.himholod.ru','http://www.himholod.ru','http://himholod.ru/','http://himholod.ru','himholod.ru',
                "index.php?mid=238","index.php?mid=270","index.php?mid=271","index.php?mid=273","index.php?mid=277", # чиллеры (удаленный раздел)
                "http://www.mexpress.ru",
                "index.php?mid=235", # научные публикации - пустой
                "index.php?mid=192", # карта сайта
                "index.php?mid=305", # отзывы клиентов - пустая страница
                "index.php?mid=210", # "Объекты общепромышленного характера"  - пустая страница
                "index.php?mid=299", # публкации - пустая страница
                "index.php?mid=291", # Ледовый Дворец спорта «Дизель-Арена» - пусто
                FILES_INDEX
               ]

    attr_accessor :src, :title, :model
    def initialize(content)
      @src = content['href']
      @title = content.content.to_s
    end

    def valid?
      src[0, 9] == 'index.php'
    end

    def model
      name = 'undefined'
      CONFIG.each do |n, titles|
        if(titles.index(@title))
          name = n
          break
        end
      end
      return nil if name && name[0,6] == 'ignore'
      ::Section.find_by_name(name)
    end

    def self.generate_main()
      Class.new(Section){

        def initialize
          @src = ''
          @title = 'Главная страница'
        end

        def valid?
          true
        end

        def model
          ::Section.main
        end
      }.new
    end

    class SubSection < Section
      def initialize(href, title, section_name)
        @src = href
        @title = title
        @model = ::Section.find_by_name(section_name)
      end

      def valid?
        !self.model.nil?
      end

      def model
        @model
      end
    end
  end

  class Page

    attr_accessor :content, :original_uri, :section, :top_level

    FILENAME_MATCHER = /[\w\-\d_\.]+\.(jpg|jpeg|png|gif)$/

    def initialize(content, original_uri)
      @content = content
      @original_uri = original_uri
      @next_filename = 0
      @top_level = false
    end

    # сохранить в базу страницу и включаемые в нее картинки
    def create!
      @sub_pages_sections = []
      hyperlinks = content.css('a').to_a
      hyperlinks.each do |link|
        next if link['href'].to_s.match(/himholod\@himholod\.ru/) || link['href'].to_s[0,6] == 'mailto'
        log "HYPERLINK '#{link.content}'->'#{link['href']}' on page '#{section.title}'" unless top_level
        sub_section = Section::CONFIG.select{|k,v| v.index(link.content)}.first
        if sub_section
          @sub_pages_sections << Section::SubSection.new(link['href'], link.content, sub_section.first.to_s)
        else
          raise "LINK '#{link.content}'->'#{link['href']}' on page '#{section.title}' not processed" unless Section::CAN_PASS.index(link['href'])
        end
      end

      images = content.css('img').to_a
      images.each_with_index do |img, index|
        create_image(img)
        complete = ((index + 1) / images.size.to_f * 100).round
        log "   Image '#{img['src']}' completed. Images progress #{complete}%"
      end

      text_page = if(self.top_level)
                    TextPage.find_by_section_id(section.model.id)
                  end
      number = 0
      while(TextPage.find_by_name(section.model.name.to_s + '-page' + (number == 0 ? '' : number.to_s)))
        number += 1
      end

      unless text_page
        text_page = TextPage.new
        text_page.section = section.model
        text_page.name = section.model.name.to_s + '-page' + (number == 0 ? '' : number.to_s)
      end
      text_page.title = section.title.strip
      text_page.body = self.class.remove_title(content).to_s
      text_page.save

      @sub_pages_sections
    end

    def self.remove_title(body)
      body = body.to_s.strip
      m = body.match(/\<span class\="headers1"\>[^\<]*\<\/span\>\<br\>/)
      if m && body[0, m[0].size] == m[0]
        body[0, m[0].size] = ''
      end
      body
    end

    def create_image(img)
      original_uri = img['src'][0, 4] == 'http' ? URI(img['src']).path : img['src']
      return if original_uri[0, 3] == 'C:\\'
      local_filename = FILENAME_MATCHER.match(original_uri) ? FILENAME_MATCHER.match(original_uri)[0] : generate_next_filename('jpg')

      tempfile = open(Himholod::Importer::BASE_PATH + '/' + original_uri)

      picture = Ckeditor::Picture.new
      picture.data = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => local_filename)

      picture.save
      img['src'] = picture.url
      picture
    end

    def file_list()
      list = []
      current_section_title = nil
      trs = self.content.css('tr')
      trs.each_with_index do |tr, index|
        if tr['class'] == 'bl'
          current_section_title = tr.children.first.content if tr.children.size == 1
        elsif tr['class'] == 'bs'
          link = tr.at_xpath('td[1]/a')
          section_select = Section::CONFIG.select{|k,values| values.index(current_section_title) }.first
          section_name = section_select ? section_select.first.to_s : 'other'
          section = ::Section.find_by_name(section_name)

          tempfile = open(Himholod::Importer::BASE_PATH + '/' + link['href'])
          pdf = PDF::Reader.new(tempfile.path) rescue nil

          file = Ckeditor::AttachmentFile.new
          file.data = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => section.name + '_file.' + (pdf ? 'pdf' : 'jpg') )
          file.section = section
          file.title = current_section_title.to_s + ' - ' + link.content.strip
          file.save
        end

        complete = ((index + 1) / trs.size.to_f * 100).round
        log "Progress #{complete}%"
      end
      list
    end

    def generate_next_filename(ext)
      filename = 'image' << @next_filename.to_s << '.' << ext
      @next_filename += 1
      filename
    end

    def log(*args)
      args.each{|arg| puts arg }
    end

  end
end

__END__

index.php?mid=239


HYPERLINK 'himholod@himholod.ru'->'himholod@himholod.ru' on page 'Наши координаты'

HYPERLINK 'Пресса о нас'->'index.php?mid=302' on page 'Публикации в прессе'
HYPERLINK 'Холодильные машины ООО "НПФ "ХИМХОЛОДСЕРВИС" для Ледовых дворцов'->'index.php?mid=189' on page 'Публикации в прессе'
HYPERLINK 'Энергосберегающие системы кондиционирования воздуха в спортивных и общественных зданиях, сооружаемых к Олимпиаде "Сочи 2014"'->'index.php?mid=207' on page 'Публикации в прессе'
HYPERLINK 'Реконструкция московских катков (2007г)'->'index.php?mid=215' on page 'Публикации в прессе'

HYPERLINK 'Теплообменное оборудование и компрессорно-конденсаторные агрегаты фирмы  Friga Bohn'->'index.php?mid=232' on page 'Холодильное оборудование'
HYPERLINK 'Теплообменное оборудование фирмы  BUCO (Аккумуляторы холода)'->'index.php?mid=234' on page 'Холодильное оборудование'
HYPERLINK 'ООО Маркетинговое предприятие «Мониторинг Экспресс»'->'index.php?mid=237' on page 'Холодильное оборудование'
HYPERLINK 'Чиллеры (водоохлаждающие холодильные машины)'->'index.php?mid=238' on page 'Холодильное оборудование'
HYPERLINK 'Чиллеры Climaveneta'->'index.php?mid=239' on page 'Холодильное оборудование'
HYPERLINK 'Теплообменные кожухотрубные аппараты производства ООО "НПФ "ХИМХОЛОДСЕРВИС"'->'index.php?mid=244' on page 'Холодильное оборудование'
HYPERLINK 'Испарительные конденсаторы типа VXC фирмы BALTIMORЕ'->'index.php?mid=246' on page 'Холодильное оборудование'
HYPERLINK 'Панельные аккумуляторы холода типа BIC'->'index.php?mid=247' on page 'Холодильное оборудование'
HYPERLINK 'Испарительные конденсаторы фирм DECSA и BALTIMORE'->'index.php?mid=248' on page 'Холодильное оборудование'
HYPERLINK 'Аммиачные воздухоохладители навесные типа АВН и подвесные типа АВП'->'index.php?mid=249' on page 'Холодильное оборудование'
HYPERLINK 'Автоматические воздухоотделители марки «ВОА»'->'index.php?mid=250' on page 'Холодильное оборудование'
HYPERLINK 'Холодильные, морозильные камеры'->'index.php?mid=251' on page 'Холодильное оборудование'
HYPERLINK 'АММИАЧНЫЕ БЛОКИ ДЛЯ ПОЛУЧЕНИЯ «ЛЕДЯНОЙ ВОДЫ» типа ИПТ (ТРУБЧАТЫЕ ИСПАРИТЕЛИ ПЛЕНОЧНОГО ТИПА)'->'index.php?mid=252' on page 'Холодильное оборудование'
HYPERLINK 'Аммиачные испарительные блоки типа БИА'->'index.php?mid=253' on page 'Холодильное оборудование'
HYPERLINK 'КОНДЕНСАТОРЫ КОЖУХОТРУБЧАТЫЕ ГОРИЗОНТАЛЬНЫЕ АММИАЧНЫЕ КТГА и КГА'->'index.php?mid=254' on page 'Холодильное оборудование'
HYPERLINK 'Емкостное оборудование'->'index.php?mid=255' on page 'Холодильное оборудование'
HYPERLINK 'ИСПАРИТЕЛИ АММИАЧНЫЕ  ИМКА-360 и ИМКА-460'->'index.php?mid=256' on page 'Холодильное оборудование'
HYPERLINK 'Испарительные конденсаторы типа МИК'->'index.php?mid=257' on page 'Холодильное оборудование'
HYPERLINK 'Испарители с внутритрубным кипением типа ИТ'->'index.php?mid=258' on page 'Холодильное оборудование'
HYPERLINK 'АММИАЧНЫЕ  КОЖУХОТРУБНЫЕ  ИСПАРИТЕЛИ ЗАТОПЛЕННОГО ТИПА  ИТГА'->'index.php?mid=259' on page 'Холодильное оборудование'
HYPERLINK 'МНОГОКАНАЛЬНЫЙ СТАЦИОНАРНЫЙ ГАЗОАНАЛИЗАТОР АММИАКА "ЭССА" '->'index.php?mid=260' on page 'Холодильное оборудование'
HYPERLINK 'КОНДЕНСАТОР МК-60'->'index.php?mid=261' on page 'Холодильное оборудование'
HYPERLINK 'Маслоохладители типа МОХ'->'index.php?mid=262' on page 'Холодильное оборудование'
HYPERLINK 'Испарители МИ-90'->'index.php?mid=263' on page 'Холодильное оборудование'
HYPERLINK 'Пленочные испарители'->'index.php?mid=264' on page 'Холодильное оборудование'
HYPERLINK 'СИЛОВЫЕ ЩИТЫ с устройством плавного пуска'->'index.php?mid=265' on page 'Холодильное оборудование'
HYPERLINK 'Компрессорные агрегаты и холодильные машины на базе полугерметичных компрессоров'->'index.php?mid=266' on page 'Холодильное оборудование'
HYPERLINK 'Компрессорные агрегаты и холодильные машины на базе сальниковых компрессоров'->'index.php?mid=267' on page 'Холодильное оборудование'
HYPERLINK 'Оборудование производства Climaveneta'->'index.php?mid=270' on page 'Холодильное оборудование'
HYPERLINK 'Оборудование фирмы Climaveneta'->'index.php?mid=271' on page 'Холодильное оборудование'
HYPERLINK '- пустое название -'->'index.php?mid=273' on page 'Холодильное оборудование'
HYPERLINK 'Оборудование фирмы Climaveneta'->'index.php?mid=277' on page 'Холодильное оборудование

HYPERLINK 'Референц-лист спортивных объектов'->'index.php?mid=216' on page 'Референц-лист проектов'
HYPERLINK 'Референц-лист "Холодильные установки контейнерного типа"'->'index.php?mid=289' on page 'Референц-лист проектов'
HYPERLINK 'Объекты молочной промышленности'->'index.php?mid=295' on page 'Референц-лист проектов'
HYPERLINK 'Объекты промышленного назначения'->'index.php?mid=296' on page 'Референц-лист проектов'
HYPERLINK 'Объекты производства соков и детского пиания'->'index.php?mid=297' on page 'Референц-лист проектов'
HYPERLINK 'Каток СДЮШОР г.Вологда'->'index.php?mid=285' on page 'Референц-лист проектов'
HYPERLINK 'Конькобежный центр "КОЛОМНА" 2012 г. Московская область'->'index.php?mid=293' on page 'Референц-лист проектов'
HYPERLINK 'Ледовый Дворец спорта «Дизель-Арена»  '->'index.php?mid=291' on page 'Референц-лист проектов'
HYPERLINK 'Ледовый дворец "Марий Эл" г. Йошкар-Ола, сдан в эксплуатацию в 2006 году'->'index.php?mid=217' on page 'Референц-лист проектов'
HYPERLINK 'Тренировочный ледовый каток "Дружба" в г. Йошкар-Ола, сдан в эксплуатацию в 2006 году'->'index.php?mid=218' on page 'Референц-лист проектов'
HYPERLINK 'Дворец спорта "Янтарь"'->'index.php?mid=279' on page 'Референц-лист проектов'
HYPERLINK 'СНЕЖКОМ'->'index.php?mid=280' on page 'Референц-лист проектов'
HYPERLINK 'Каток "Лебединое озеро" г. Ереван'->'index.php?mid=282' on page 'Референц-лист проектов'
HYPERLINK 'Модернизация катков МОСКОМСПОРТА в 2008 году'->'index.php?mid=281' on page 'Референц-лист проектов'

HYPERLINK 'Скачать файл  '->'showfile.php?id=5' on page 'Информация'
HYPERLINK 'ТЕХНИЧЕСКИЕ ХАРАКТЕРИСТИКИ ИСПАРИТЕЛЬНЫХ КОНДЕНСАТОРОВ ТИПА VXC ФИРМЫ BALTIMORE'->'showfile.php?id=9' on page 'Информация'
HYPERLINK 'Технические характеристики панельных аккумуляторов холода типа BIC'->'showfile.php?id=10' on page 'Информация'
HYPERLINK 'Технические данные испарительных конденсаторов фирмы DECSA'->'showfile.php?id=11' on page 'Информация'
HYPERLINK 'Приложение 1'->'showfile.php?id=14' on page 'Информация'
HYPERLINK 'Приложение 2'->'showfile.php?id=15' on page 'Информация'
HYPERLINK 'характеристики ИПТ'->'showfile.php?id=16' on page 'Информация'
HYPERLINK 'БИА'->'showfile.php?id=17' on page 'Информация'
HYPERLINK 'Технические характеристики'->'showfile.php?id=18' on page 'Информация'
HYPERLINK 'Технические характеристики'->'showfile.php?id=19' on page 'Информация'
HYPERLINK 'Таблица размеров РКЦ'->'showfile.php?id=20' on page 'Информация'
HYPERLINK 'Таблица размеров РЛД'->'showfile.php?id=21' on page 'Информация'
HYPERLINK 'Таблица размеров РЦЗ'->'showfile.php?id=22' on page 'Информация'
HYPERLINK 'Технические характеристики'->'showfile.php?id=23' on page 'Информация'
HYPERLINK 'Основные присоединительные размеры'->'showfile.php?id=24' on page 'Информация'
HYPERLINK 'Технические характеристики'->'showfile.php?id=25' on page 'Информация'
HYPERLINK 'Технические данные'->'showfile.php?id=26' on page 'Информация'
HYPERLINK 'Основные размеры аппаратов с прямыми трубами'->'showfile.php?id=27' on page 'Информация'
HYPERLINK 'Сечение и параметры внутриреберной 10-ти канальной трубы '->'showfile.php?id=28' on page 'Информация'
HYPERLINK 'Техническая характеристика и размеры'->'showfile.php?id=29' on page 'Информация'
HYPERLINK 'Технические характеристики'->'showfile.php?id=30' on page 'Информация'
HYPERLINK 'Технические данные'->'showfile.php?id=31' on page 'Информация'
HYPERLINK 'Технические характеристики маслоохладителей типа МОХ'->'showfile.php?id=32' on page 'Информация'
HYPERLINK 'Техническая характеристика'->'showfile.php?id=33' on page 'Информация'
HYPERLINK 'Сравнение'->'showfile.php?id=34' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=35' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=36' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=37' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=38' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=39' on page 'Информация'
HYPERLINK 'МКТ и МВТ 130, 420 и 630'->'showfile.php?id=40' on page 'Информация'
HYPERLINK 'А 130, А 420'->'showfile.php?id=41' on page 'Информация'
HYPERLINK 'А 130, А 420'->'showfile.php?id=42' on page 'Информация'
HYPERLINK 'А 130, А 420'->'showfile.php?id=43' on page 'Информация'
HYPERLINK 'А 130, А 420'->'showfile.php?id=44' on page 'Информация'
HYPERLINK 'УХК'->'showfile.php?id=45' on page 'Информация'
HYPERLINK ''->'showfile.php?id=58' on page 'Информация'
HYPERLINK ''->'showfile.php?id=59' on page 'Информация'
HYPERLINK ''->'showfile.php?id=60' on page 'Информация'
HYPERLINK 'Добровольная сертификация'->'showfile.php?id=46' on page 'Информация'
HYPERLINK 'OHSAS 18001'->'showfile.php?id=47' on page 'Информация'
HYPERLINK 'ISO 9001'->'showfile.php?id=48' on page 'Информация'
HYPERLINK 'ISO 14001'->'showfile.php?id=49' on page 'Информация'
HYPERLINK 'МКТ (МВТ) 50 - 500'->'showfile.php?id=51' on page 'Информация'
HYPERLINK 'МКТ (МВТ) 50 - 500'->'showfile.php?id=52' on page 'Информация'
HYPERLINK 'Разрешение на применение'->'showfile.php?id=53' on page 'Информация'
HYPERLINK 'Сертификат на электрощиты'->'showfile.php?id=54' on page 'Информация'
HYPERLINK 'картинка'->'showfile.php?id=61' on page 'Информация'
HYPERLINK ''->'showfile.php?id=63' on page 'Информация'
HYPERLINK ''->'showfile.php?id=65' on page 'Информация'
HYPERLINK ''->'showfile.php?id=64' on page 'Информация'
HYPERLINK ''->'showfile.php?id=66' on page 'Информация'
HYPERLINK 'вагон'->'showfile.php?id=67' on page 'Информация'
HYPERLINK 'Колосов_8'->'showfile.php?id=68' on page 'Информация'