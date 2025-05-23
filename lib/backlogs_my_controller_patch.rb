require_dependency 'my_controller'

module BacklogsMyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        # unloadable # Send unloadable so it will not be unloaded in development
        after_action :save_backlogs_preferences, :only => [:account]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def save_backlogs_preferences
        if request.put? && flash[:notice] == l(:notice_account_updated)
          color = (params[:backlogs] ? params[:backlogs][:task_color] : '').to_s
          if color == '' || color.match(/^#[A-Fa-f0-9]{6}$/)
            User.current.backlogs_preference[:task_color] = color
          else
            flash[:notice] = "Invalid task color code #{color}"
          end
        end
      end
    end
end

MyController.send(:include, BacklogsMyControllerPatch) unless MyController.included_modules.include? BacklogsMyControllerPatch
