# frozen_string_literal: true

module DryingRails
  # ControllerHelpers module define 'execute' helper to call Dry Container
  # registered objects together with two syntactic sugars : 'locals_for' and
  # 'perform'
  module ControllerHelpers
    def execute(action, entity = nil, **options)
      res = DryingContainer[action].call entity, Ustruct.new(options)
      block_given? ? yield(res) : res
    end

    # short cuts...
    def locals_for(action, entity = nil, **options, &block)
      execute "exposers.#{action}", entity, **options, &block
    end

    def perform(action, entity = nil, *_args, **options, &block)
      execute "actions.#{action}", entity, **options, &block
    end
  end
end
