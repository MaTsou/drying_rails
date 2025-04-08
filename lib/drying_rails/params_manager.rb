# frozen_string_literal: true

module DryingRails
  # params manager module
  module ParamsManager
    protected

    def permitted_params
      set_model_vars
      sanitize_decimal_values # YES, this is a controller concern !
      params
        .require(@model_name)
        .permit(@model.permitted_attributes)
    end

    private

    def set_model_vars
      @model_name = params[:controller].singularize.to_sym
      @model = Object.const_get @model_name.to_s.camelize
    end

    def sanitize_decimal_values
      return unless @model.respond_to? :numerical_attributes

      @model.numerical_attributes&.each do |field|
        params[@model_name]
          .fetch(field, '')
          .to_s
          .gsub!(',', '.')
      end
    end
  end
end
