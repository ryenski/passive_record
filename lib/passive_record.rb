require 'serializers/xml_serializer'

class PassiveRecord

  # Assign values to each of the attributes passed in the params hash
  def initialize(params = {})
    params.each { |k, v| send("#{k}=", v)}
  end

  # Date accessors to be consistent with ActiveRecord:
  attr_accessor :created_at, :updated_at

  # Return a hash of the class's attribute names and values
  #   @name.attributes => {:first_name=>"Dima", :last_name=>"Dozen"}
  def attributes
    @attributes = {}
    self.class.attributes.flatten.each {|att| @attributes[att] = self.send(att) }
    @attributes
  end

  # Compare this object with another object of the same class.
  # Returns true if the attributes and values are identical.
  #   @name === @name   #=> true
  #   @name === @name2  #=> false
  def ===(other)
    self.attributes == other.attributes
  end

  # Builds an XML document to represent the model.
  #
  # @my_passive_model.to_xml
  # @my_passive_model.to_xml(:skip_instruct => true, :root => "records")
  #
  # Associations:
  #   @my_passive_model.to_xml(:include => :all) # include all associations
  #   @my_passive_model.to_xml(:include => [:specific_association]) # include the specific association
  #
  # Including aditional methods:
  #   Post < PassiveRecord
  #     define_attributes [:title, :content, :created_by]
  #     
  #     def complete_title
  #       "#{self.title} by #{self.created_by}"
  #     end
  #   end
  #
  #   post = Post.new(:title => 'Open source projects are awesome!', :created_by => 'Felipe Mesquita', :content => '...')
  #   post.to_xml
  #     #=>   <?xml version='1.0' encoding='UTF-8'?>
  #           <post>
  #             <title>Open source projects are awesome!</title>
  #             <created_by>Felipe Mesquita</created_by>
  #             <content>...</content>
  #           </post>
  #
  #   post.to_xml(:methods => [:complete_title])
  #     #=>   <?xml version='1.0' encoding='UTF-8'?>
  #           <post>
  #             <title>Open source projects are awesome!</title>
  #             <created_by>Felipe Mesquita</created_by>
  #             <content>...</content>
  #             <complete-title>Open source projects are awesome! by Felipe Mesquita</complete-title>
  #           </post>
  #
  def to_xml(options = {})
    xml_serializer.to_xml(self, options)
  end

  class << self
    # Provide some basic ActiveRecord-like methods for working with non-ActiveRecord objects
    #   class Person < PassiveRecord
    #     has_many :names, :addresses, :phone_numbers
    #   end
    def has_many(*associations)
      # Simply sets up an attr_accessor for each item in the list
      @associations = associations
      associations.each {|association| attr_accessor association}
    end

    # Creates instance methods for each item in the list. Expects an array
    #   class Address < PassiveRecord
    #     define_attributes [:street, :city, :state, :postal_code, :country]
    #   end
    def define_attributes(attrs)
      @attributes = attrs
      # Assign attr_accessor for each attribute in the list
      attrs.each {|att| attr_accessor att}
    end

    # Return the list of available attributes for the class
    #
    #   Name.attributes #=> [:id, :first_name, :last_name]
    def attributes
      @attributes
    end

    # Returns the list of available has_many associations
    #
    #   Model.associations #=> [:names, :addresses]
    def associations
      @associations
    end
  end

  protected

  def xml_serializer
    @xml_serializer ||= PassiveRecordModule::Serialization::XmlSerializer.new
  end

end
