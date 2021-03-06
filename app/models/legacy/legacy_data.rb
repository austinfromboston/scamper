class LegacyData < ActiveRecord::Base
  @abstract_class = true
  #import_to_class = nil 
  #callbacks =  { :after_import => [] }

  establish_connection configurations[ ( Rails.env.test? ? 'legacy_test' : 'legacy' ) ]
  IMPORT_KEYS = {}

  attr_accessor :imported
  class TrashedItemImport < StandardError; end
  class OrphanItemImport < StandardError; end

  def local_object(klass)
    klass.new local_attributes(klass.name.underscore.to_sym)
  end
  def local_attributes(object_name)
    local_keys = self.class.const_get(:IMPORT_KEYS)[object_name]
    local_keys.inject({}) do |memo, ( local_key, my_key ) |
      key_value = case; 
                  when my_key.is_a?(Proc): my_key.call(self)
                  when my_key.is_a?(Symbol): self.send(my_key)
                  else my_key
                  end
      memo.merge local_key =>  key_value
                             
                            
    end
  end

  def self.before_import(*args, &block )
    self.callbacks ||=  { :after_import => [], :before_import => [] }
    self.callbacks[:before_import] << args
    if block
      self.callbacks[:before_import] << block
    end
    self.callbacks[:before_import].flatten!
  end

  def self.after_import(*args, &block )
    self.callbacks ||=  { :after_import => [], :before_import => [] }
    self.callbacks[:after_import] << args
    if block
      self.callbacks[:after_import] << block
    end
    self.callbacks[:after_import].flatten!
  end

  def before_import
    self.callbacks ||=  {}
    self.callbacks[:before_import]  ||= []
    self.class.callbacks[:before_import].each do |cb|
      if cb.is_a?( Proc )
        instance_eval( &cb ) 
        next 
      end
      send cb
    end
  end

  def after_import
    self.callbacks ||=  {}
    self.callbacks[:after_import]  ||= []
    self.class.callbacks[:after_import].each do |cb|
      if cb.is_a?( Proc )
        instance_eval( &cb ) 
        next 
      end
      send cb
    end
  end

  def self.import_to( class_name )
    self.import_to_class = const_get( class_name.to_s.classify )
  end

  def import
    log "Importing #{self.class.name} ##{id}"
    before_import
    self.imported = local_object self.class.import_to_class
    imported.save!
    after_import
    log "Success as #{self.class.import_to_class.name} ##{imported.id}" 
    self.imported
  end

  def log(value)
    puts value unless Rails.env.test?
  end

  def simplify_tag( value )
    value.downcase.
      # unicode chars begone
      gsub(/&#\d{4,5};/, '').
      # punctuation
      gsub(/[-;,:'\)\(]/, '').
      # conformance
      gsub( /[^a-z0-9_]/, '_' ).
      # extra space
      squeeze( '_' ).
      gsub( /_$/, '' )
  end

end
