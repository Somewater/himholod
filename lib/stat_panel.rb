require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

#module RailsAdmin
 # module Config
  #  module Actions
      class StatPanel < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
            if params[:task] == 'dbdump'
              database_conf = Rails.configuration.database_configuration[Rails.env]
              Cocaine::CommandLine.path = Rails.root.to_s
              content = `mysqldump -u #{database_conf['username']} -p#{database_conf['password']} --databases #{database_conf['database']} | gzip -f`
              t = Time.new
              response.headers['Content-Disposition'] = "attachment; filename=\"dbdump_#{(t.month)}_#{t.day}.sql.gz\""
              render :text => content, :content_type => 'application/x-gzip'
            else
              render :action => @action.template_name
            end
          end
        end
      end
  #  end
 # end
#end
