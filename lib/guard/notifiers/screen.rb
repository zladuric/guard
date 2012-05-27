require 'rbconfig'

module Guard
  module Notifier
  # Notification using GNU screen
  # - add :screen notifier to Guardfile
    module Screen
      extend self
      
      def available?(silent = false)
        if (RbConfig::CONFIG['host_os'] =~ /linux|freebsd|openbsd|sunos|solaris/) and (not `screen -ls| awk '/Attached/ {print $1}' | cut -d. -f1`.empty?)
          true
        else
          ::Guard::UI.error 'The :screen notifier will run on a Linux or similar OS inside an attached GNU screen session' unless silent
        end
      end
      # Show a system notification.
      #
      # @param [String] type the notification type. Either 'success', 'pending', 'failed' or 'notify'
      # @param [String] title the notification title
      # @param [String] message the notification message body
      # @param [String] image the path to the notification image
      # @param [Hash] options additional notification library options
      # @option options [String] c the notification category
      # @option options [Number] t the number of milliseconds to display (1000, 3000)

      def notify(type, title, message, image, options = {})
        SCREEN_PID = `screen -ls| awk '/Attached/ {print $1}' | cut -d. -f1`
        system("screen -S #{SCREEN_PID} -X eval \'caption always \"RSPEC: #{message}\"\'")
        # this is probably a bad idea, but I want to test and try what I have done
        sleep 4
        system("screen -S #{SCREEN_PID} -X eval \"caption splitonly\"")
      end
    end
  end
end
