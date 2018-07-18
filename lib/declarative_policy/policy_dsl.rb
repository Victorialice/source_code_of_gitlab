module DeclarativePolicy
  # The return value of a rule { ... } declaration.
  # Can call back to register rules with the containing
  # Policy class (context_class here). See Base.rule
  #
  # Note that the #policy method just performs an #instance_eval,
  # which is useful for multiple #enable or #prevent callse.
  #
  # Also provides a #method_missing proxy to the context
  # class's class methods, so that helper methods can be
  # defined and used in a #policy { ... } block.
  class PolicyDsl
    def initialize(context_class, rule)
      @context_class = context_class
      @rule = rule
    end

    def policy(&block)
      instance_eval(&block)
    end

    def enable(*abilities)
      @context_class.enable_when(abilities, @rule)
    end

    def prevent(*abilities)
      @context_class.prevent_when(abilities, @rule)
    end

    def prevent_all
      @context_class.prevent_all_when(@rule)
    end

    def method_missing(msg, *args, &block)
      return super unless @context_class.respond_to?(msg)

      @context_class.__send__(msg, *args, &block) # rubocop:disable GitlabSecurity/PublicSend
    end

    def respond_to_missing?(msg)
      @context_class.respond_to?(msg) || super
    end
  end
end
