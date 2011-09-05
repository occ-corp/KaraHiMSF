module ActsAsSessionable
  def self.included(klass)
    klass.class_eval do
      def self.acts_as_sessionable(options={ })
        options.symbolize_keys!

        before_filter :_restore_session, :only => (options[:methods] || [])

        const_set("SESSION_PARAMS", options[:params] || [])

        protected

        @_init_params = options[:init_params]

        def _init_params
          _init_params_proc = self.class.instance_variable_get("@_init_params")
          if _init_params_proc.is_a?(Proc)
            self.instance_exec &_init_params_proc
          elsif !_init_params_proc.nil?
            self.send(_init_params_proc)
          end
        end

        def _restore_session
          unless session.has_key?(self.controller_name.to_sym)
            session[self.controller_name.to_sym] = { }
            _init_params
          end
          if params[:session_save] == "true"
            self.class.const_get("SESSION_PARAMS").each { |k| session[self.controller_name.to_sym][k] = params[k] }
          else
            self.class.const_get("SESSION_PARAMS").each do |k|
              if params[k].to_s.empty?
                params[k] = session[self.controller_name.to_sym][k]
              else
                session[self.controller_name.to_sym][k] = params[k]
              end
            end
          end
        end
      end
    end
  end
end
