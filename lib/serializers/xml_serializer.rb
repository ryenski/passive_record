module PassiveRecordModule
  module Serialization
    class XmlSerializer
      # Builds an XML document to represent the model.
      #
      # @my_passive_model.to_xml
      # @my_passive_model.to_xml(:skip_instruct => true, :root => "records")
      #
      # Associations:
      # @my_passive_model.to_xml(:include => :all) # include all associations
      # @my_passive_model.to_xml(:include => [:specific_association]) # include the specific association
      def to_xml(record, options = {})
        options.reverse_merge!({ :root => record.class.to_s.underscore })
        attributes = record.attributes
        attributes.merge!(includes_of(record, options[:include]))
        attributes.to_xml(options)
      end

      protected
        def includes_of(record, includes)
          if includes.nil?
            return {}
          elsif (includes.is_a?(Symbol) && includes == :all)
            includes = record.class.associations
          end
          includes.inject({}) do |hash, attribute|
            association = record.send(attribute.to_sym)
            attrs = association.is_a?(Array) ? association.collect { |a| a.attributes } : association.attributes rescue {}
            hash.merge!({ attribute.to_sym => attrs })
          end
        end
    end
  end
end
