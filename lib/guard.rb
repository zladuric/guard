require 'bundler'

module Guard
  
  autoload :UI,         'guard/ui'
  autoload :Dsl,        'guard/dsl'
  autoload :Interactor, 'guard/interactor'
  autoload :Listener,   'guard/listener'
  autoload :Watcher,    'guard/watcher'
  autoload :Notifier,   'guard/notifier'
  
  class << self
    attr_accessor :options, :guards, :listener
    
    # initialize this singleton
    def init(options = {})
      @options  = options
      @listener = Listener.init
      @guards   = []
      return self
    end
    
    def start(options = {})
      init options
      
      Dsl.evaluate_guardfile
      if guards.empty?
        UI.error "No guards found in Guardfile, please add at least one."
      else
        Interactor.init_signal_traps
        
        listener.on_change do |files|
          run do
            guards.each do |guard|
              paths = Watcher.match_files(guard, files)
              supervised_task(guard, :run_on_change, paths) unless paths.empty?
            end
          end
        end
        
        UI.info "Guard is now watching at '#{Dir.pwd}'"
        guards.each do |guard|
          if supervised_task(guard, :start)
            %w[reload run_all].each do |m|
              guard.send(m) if guard.respond_to?(:"#{m}_at_start?") && guard.send(:"#{m}_at_start?")
            end
          end
        end
        listener.start
      end
    end
    
    def add_guard(name, watchers = [], options = {})
      guard_class = get_guard_class(name)
      @guards << guard_class.new(watchers, options)
    end
    
    def get_guard_class(name)
      require "guard/#{name.downcase}"
      klasses = []
      ObjectSpace.each_object(Class) do |klass|
        klasses << klass if klass.to_s.downcase.match "^guard::#{name.downcase}"
      end
      klasses.first
    rescue LoadError
      UI.error "Could not find gem 'guard-#{name}' in the current Gemfile."
    end
    
    # Let a guard execute his task but
    # fire it if his work lead to system failure
    def supervised_task(guard, task_to_supervise, *args)
      if !guard.respond_to(:"#{task_to_supervise}?") || guard.send(:"#{task_to_supervise}?")
        guard.send(task_to_supervise, *args)
      else
        false
      end
    rescue Exception
      UI.error("#{guard.class.name} guard failed to achieve its <#{task_to_supervise.to_s}> command: #{$!}")
      ::Guard.guards.delete guard
      UI.info("Guard #{guard.class.name} has just been fired")
      return $!
    end
    
    def locate_guard(name)
      `gem open guard-#{name} --latest --command echo`.chomp
    rescue
      UI.error "Could not find 'guard-#{name}' gem path."
    end
    
    def run
      listener.stop
      UI.clear if options[:clear]
      begin
        yield
      rescue Interrupt
      end
      listener.start
    end
    
  end
end