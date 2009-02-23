class LegacyData < ActiveRecord::Base
  @abstract_class = true
  @@callbacks =  { :after_import => [] }
  @@import_to_class = nil 
  attr_accessor :imported

  establish_connection configurations[ ( Rails.env.test? ? 'legacy_test' : 'legacy' ) ]
  IMPORT_KEYS = {}
  def local_object(klass)
    klass.new local_attributes(klass.name.underscore.to_sym)
  end
  def local_attributes(object_name)
    local_keys = self.class.const_get(:IMPORT_KEYS)[object_name]
    local_keys.inject({}) do |memo, ( local_key, my_key ) |
      memo.merge local_key => ( my_key.is_a?(Proc) ? 
                                instance_eval(my_key) : 
                                self.send( my_key ) )
    end
  end

  def self.after_import(*args)
    @@callbacks[:after_import] << args
    @@callbacks[:after_import].flatten!
  end

  def after_import
    @@callbacks[:after_import].each do |cb|
      instance_eval( cb ) and next if cb.is_a?( Proc )
      send cb
    end
  end

  def self.import_to( class_name )
    @@import_to_class = const_get( class_name.to_s.classify )
    @@import_to_class.establish_connection
  end

  def import
    self.imported = local_object @@import_to_class
    imported.save!
    after_import
  end
end
