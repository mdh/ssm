module SimpleStateMachine
  
  def event event_name, state_transitions
    @state_machine_definition ||= StateMachineDefinition.new self
    @state_machine_definition.define_event event_name, state_transitions
  end
  
  def state_machine_definition
    @state_machine_definition
  end
  
  class StateMachineDefinition
    
    attr_reader :events

    def initialize subject
      @events  = {}
      @active_record = subject.ancestors.map {|klass| klass.to_s}.include?("ActiveRecord::Base")
      @decorator = if @active_record
        Decorator::ActiveRecord.new(subject)
      else
        Decorator::Default.new(subject)
      end
    end
    
    def define_event event_name, state_transitions
      @events[event_name.to_s] ||= {}
      if @active_record
        @events["#{event_name}!"] ||= {}
      end
      state_transitions.each do |from, to|
        @events[event_name.to_s][from.to_s] = to.to_s
        @events["#{event_name}!"][from.to_s] = to.to_s if @active_record
        @decorator.decorate(from, to, event_name)
      end
    end

  end
  
  class StateMachine
    def initialize(subject)
      @subject = subject
    end
    
    def next_state(event_name)
      @subject.class.state_machine_definition.events[event_name.to_s][@subject.state]
    end
    
    def transition(event_name)
      from = @subject.state
      if to = next_state(event_name)
        yield
        @subject.state = to
        if event_name.to_s[-1,1] == '!'
          begin
            @subject.send :state_transition_succeeded_callback!
          rescue ::ActiveRecord::RecordInvalid
            @subject.state = from
            raise
          end
        else
          result = @subject.send :state_transition_succeeded_callback
            @subject.state = from unless result
          result
        end
      else
        @subject.send :illegal_event_callback, event_name
      end
    end
    
  end
  
  module Decorator
    class Base

      def initialize(subject)
        @subject = subject
        @subject.send :include, InstanceMethods
      end

      def decorate from, to, event_name
        define_state_helper_method(from)
        define_state_helper_method(to)
        define_event_method(event_name)
        decorate_event_method(event_name)
      end
    
      private

        def define_state_helper_method state
          unless @subject.method_defined?("#{state.to_s}?")
            @subject.send(:define_method, "#{state.to_s}?") do
              self.state == state.to_s
            end
          end
        end

        def define_event_method event_name
          unless @subject.method_defined?("#{event_name}")
            @subject.send(:define_method, "#{event_name}") {}
          end
        end

        def decorate_event_method event_name
          # TODO put in transaction for activeRecord?
          unless @subject.method_defined?("with_managed_state_#{event_name}")
            @subject.send(:define_method, "with_managed_state_#{event_name}") do |*args|
              return state_machine.transition(event_name) do
                send("without_managed_state_#{event_name}", *args)
              end
            end
            @subject.send :alias_method, "without_managed_state_#{event_name}", event_name
            @subject.send :alias_method, event_name, "with_managed_state_#{event_name}"
          end
        end
    
    end
  
    class Default < Base
      def initialize(subject)
        super(subject)
        define_state_getter_method
        define_state_setter_method
      end
    
      private
      
        def define_state_setter_method
          unless @subject.method_defined?('state=')
            @subject.send(:define_method, 'state=') do |new_state|
              @state = new_state.to_s
            end
          end
        end

        def define_state_getter_method
          unless @subject.method_defined?('state')
            @subject.send(:define_method, 'state') do
              @state
            end
          end
        end
      
    end
    
    class ActiveRecord < Base
      def initialize(subject)
        super(subject)
        @subject.send :include, ActiveRecordInstanceMethods
      end

      def decorate from, to, event_name
        super from, to, event_name
        define_event_method("#{event_name}!")
        decorate_event_method("#{event_name}!")
      end
    end
    
  end
  
  module InstanceMethods
    
    def state_machine
      @state_machine ||= StateMachine.new(self)
    end

    private

      def state_transition_succeeded_callback
        true
      end

      def state_transition_succeeded_callback!
        true
      end
    
      def illegal_event_callback event_name
        # override with your own implementation, like setting errors in your model
        raise "You cannot '#{event_name}' when state is '#{state}'"
      end
  end

  module ActiveRecordInstanceMethods

    private

      def state_transition_succeeded_callback
        save
      end

      def state_transition_succeeded_callback!
        save!
      end
  
  end

end