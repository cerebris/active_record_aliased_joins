# frozen_string_literal: true

require_relative 'active_record_aliased_joins/version'
require 'active_record/railtie'

# ActiveRecordAliasedJoins
module ActiveRecordAliasedJoins
  class Error < StandardError; end

  # UnsupportedReflectionError
  class UnsupportedReflectionError < StandardError
    def initialize(reflection = nil)
      if reflection
        super("Reflection not supported #{reflection.name.inspect}")
      else
        super('Reflection not supported error.')
      end
    end
  end

  # Module to add joins_with_alias support to ActiveRecord::Base
  module JoinWithAlias
    def joins_with_alias(association_name, alias_name, join_klass = Arel::Nodes::InnerJoin)
      reflection = _reflect_on_association(association_name.to_s)
      raise ActiveRecord::AssociationNotFoundError unless reflection

      source_joins =
        case reflection
        when ActiveRecord::Reflection::HasManyReflection, ActiveRecord::Reflection::HasOneReflection
          join_with_alias_has_many_has_one(reflection, association_name, alias_name, join_klass)
        when ActiveRecord::Reflection::BelongsToReflection
          join_with_alias_belongs_to(reflection, association_name, alias_name, join_klass)
        when ActiveRecord::Reflection::ThroughReflection, ActiveRecord::Reflection::HasAndBelongsToManyReflection
          join_with_alias_through(reflection, association_name, alias_name, join_klass)
        else
          raise UnsupportedReflectionError, reflection
        end

      joins(source_joins.join_sources)
    end

    def left_joins_with_alias(association_name, alias_name)
      joins_with_alias(association_name, alias_name, Arel::Nodes::OuterJoin)
    end

    private

    def join_with_alias_has_many_has_one(reflection, _association_name, alias_name, join_klass = Nodes::InnerJoin)
      s = arel_table
      related_klass = reflection.klass
      r = related_klass.arel_table.alias(alias_name)
      s.join(r, join_klass).on(s[primary_key.to_sym].eq(r[reflection.foreign_key.to_sym]))
    end

    def join_with_alias_belongs_to(reflection, _association_name, alias_name, join_klass = Nodes::InnerJoin)
      s = arel_table
      related_klass = reflection.klass
      r = related_klass.arel_table.alias(alias_name)
      s.join(r, join_klass).on(s[reflection.foreign_key.to_sym].eq(r[primary_key.to_sym]))
    end

    def join_with_alias_through(reflection, association_name, alias_name, join_klass = Nodes::InnerJoin)
      s = arel_table
      related_klass = reflection.klass
      r = related_klass.arel_table.alias(alias_name)

      s_t_reflection = _reflect_on_association(reflection.options[:through].to_s)
      t_klass = s_t_reflection.klass
      t = t_klass.arel_table
      t_r_reflection = t_klass._reflect_on_association(association_name.to_s.singularize)

      s.join(t, join_klass).on(s[primary_key.to_sym].eq(t[s_t_reflection.foreign_key.to_sym]))
       .join(r, join_klass).on(t[t_r_reflection.foreign_key.to_sym].eq(r[related_klass.primary_key.to_sym]))
    end
  end

  ActiveRecord::Base.extend JoinWithAlias if defined?(ActiveRecord)
end
