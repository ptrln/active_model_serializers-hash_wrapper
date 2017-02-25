require "active_model_serializers/hash_wrapper/version"

module ActiveModelSerializers
  module HashWrapper

    class << self

      def wrapper_class(model_name)
        Class.new(::ActiveModelSerializers::Model) do

          attr_accessor :source_hash

          delegate :[], to: :source_hash

          define_singleton_method :name do
            model_name
          end

          def read_attribute_for_serialization(attr_name)
            source_hash.has_key?(attr_name) ? source_hash[attr_name] : source_hash[attr_name.to_s]
          end

        end
      end

      def create(model_name, hash)
        klass = wrapper_class(model_name)
        klass.new(source_hash: hash)
      end

    end

  end
end
