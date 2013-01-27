module I18nColumns

  LOCALES = ['ru', 'en']

  module Migrate
    def up_i18n_column(table, name, type, drop_old = false, options = {})
      if drop_old
        remove_column table, name
      end
      LOCALES.each do |l|
        add_column table, name.to_s + '_' + l, type, options
      end
    end

    def down_i18n_column(table, name, type, recreate_old = false, options = {})
      raise "Illegal arguments list: recreate=false, but options existed" if !recreate_old && !options.empty?
      LOCALES.each do |l|
        remove_column table, name.to_s + '_' + l
      end
      if recreate_old
        add_column table, name, type, options
      end
    end
  end

  module Model
    def i18n_columns(*names)
      names.each do |name|
        self.translates(name)
        self.attr_accessible(*LOCALES.map{|l| name.to_s + '_' + l })
        self.send(:define_method, (name.to_s + '_all=').to_sym) do |value|
          I18nColumns::LOCALES.each do |l|
            self.send (name.to_s + '_' + l + '=').to_sym, value
          end
        end
      end
    end
  end
end