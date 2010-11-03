module Guard
  class Guard
    attr_accessor :watchers, :options

    DEFAULT_OPTIONS = {
      :reload  => {:at_start => false, :disable => false},
      :run_all => {:at_start => false, :disable => false}
    }.freeze
    
    def initialize(watchers = [], options = {})
      @watchers, @options = watchers, DEFAULT_OPTIONS.merge(options)
    end
    
    # Guardfile template needed inside guard gem
    def self.init(name)
      if ::Guard::Dsl.guardfile_included?(name)
        ::Guard::UI.info "Guardfile already include #{name} guard"
      else
        content = File.read('Guardfile')
        guard   = File.read("#{::Guard.locate_guard(name)}/lib/guard/#{name}/templates/Guardfile")
        File.open('Guardfile', 'wb') do |f|
          f.puts content
          f.puts ""
          f.puts guard
        end
        ::Guard::UI.info "#{name} guard added to Guardfile, feel free to edit it"
      end
    end
    
    # ================
    # = Guard method =
    # ================
    
    # Call once when guard starts
    # Please override initialize method to init stuff
    def start
      true
    end
    
    # Call once when guard quit
    def stop
      true
    end
    
    # Should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    def reload
      true
    end

    # disable reload method if return true. When is overwriten, must return false if `super' return false
    def reload?
      options[:reload] == true || (options[:reload].is_a?(Hash) && !options[:reload][:disable])
    end

    # enable call of reload method after start method if return true. When is overwriten, must return false if `super' return false
    def reload_at_start?
      options[:reload].is_a?(Hash) && !!options[:reload][:at_start]
    end
    
    # Should be principally used for long action like running all specs/tests/...
    def run_all
      true
    end

    # disable run_all method if return true. When is overwriten, must return false if `super' return false
    def run_all?
      options[:run_all] == true || (options[:run_all].is_a?(Hash) && !options[:run_all][:disable])
    end

    # enable call of run_all method after start method if return true. When is overwriten, must return false if `super' return false
    def run_all_at_start?
      options[:run_all].is_a?(Hash) && !!options[:run_all][:at_start]
    end
    
    def run_on_change(paths)
      true
    end
    
  end
end