require "active_model_serializers/hash_wrapper/version"

module ActiveModelSerializers
  module HashWrapper

    class << self

      def wrapper_class(model_name)
        model_name = model_name.to_s

        Class.new(::ActiveModelSerializers::Model) do

          attr_accessor :source_hash

          delegate :[], to: :source_hash

          define_singleton_method :name do
            model_name
          end

          def read_attribute_for_serialization(attr_name)
            value = source_hash.has_key?(attr_name) ? source_hash[attr_name] : source_hash[attr_name.to_s]

            value = create_nested_wrapper(value, attr_name) if value.is_a?(Hash)

            value = value.map { |v| v.is_a?(Hash) ? create_nested_wrapper(v, attr_name) : v } if value.is_a?(Array)

            value
          end

          def as_json(*)
            # fallbacks to dumping the source_hash if AMS cannot infer a serializer,
            # and an explicit serializer is not specified
            source_hash
          end

        private

          def create_nested_wrapper(hash, attr_name)
            model_name = hash[:_hash_wrapper_model_name] || attr_name.to_s.classify
            ::ActiveModelSerializers::HashWrapper.create(model_name, hash)
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
