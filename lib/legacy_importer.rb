class LegacyImporter
  def self.run
    if File.exist?( File.join( RAILS_ROOT, 'config', 'legacy', 'init.rb' ))
      load File.join( RAILS_ROOT, 'config', 'legacy', 'init.rb' )
    end
    importer = LegacyImporter.new
    importer.do_site
    importer.do_templates
    importer.do_section_headers
    importer.do_all_articles
    importer.do_related_sections

    importer.do_template_inheritance
    importer.do_navs

    importer.do_images
  end

  def do_site
    @site = LegacySite.find 1
    @site.import
  end
  def do_templates
    LegacyTemplate.all.each { |lt| lt.import }
  end
  def do_section_headers
    legs = LegacyArticle.all :conditions => [ 'amp_class = ?', 8 ]
    legs.each do |la|
      begin
        la.import
      rescue LegacyData::TrashedItemImport, LegacyData::OrphanItemImport
        puts "Deleting LegacyArticle #{la.id} as this item is TRASH"
        la.kill_tree
      end
    end
  end

  def do_all_articles
    legs = LegacyArticle.all :conditions => [ "amp_class != ?", 8 ]
    legs.each do |la|
      begin
        la.import
      rescue LegacyData::TrashedItemImport, LegacyData::OrphanItemImport
        puts "Deleting LegacyArticle #{la.id} as this item is TRASH"
        la.kill_tree
      end
    end

  end

  def do_related_sections
     LegacyRelatedSection.all( :select => "distinct articleid, typeid" ).each { |r| r.import }
  end

  def do_template_inheritance
    @site ||= LegacySite.find 1
    @site.imported ||= Site.first

    # create custom template for the landing page
    frontpage = Page.find @site.imported.landing_page_id
    fp_container = LegacyIntrotext.find LegacyIntrotext::AMP_FRONTPAGE
    legacy_fptemplate_id = fp_container.templateid
    frontpage.update_attribute :page_layout_id, PageLayout.find_by_legacy_id( legacy_fptemplate_id ).id

    # find base template and blanket all pages with that to start
    base_layout = PageLayout.find_by_legacy_id @site.template
    Page.update_all [ "page_layout_id = ?", base_layout.id ], [ "page_layout_id is ?", nil ]
    raise "global update failed" unless Page.find_all_by_page_layout_id(nil).empty?

    # iterate through the sections
    templated_sections = LegacySection.all :conditions => [ "templateid is not ? and templateid != ?", nil, 0 ]

    template_tree( LegacySection.find( LegacySection::AMP_ROOT ), 
                  templated_sections.map(&:id) ) unless templated_sections.empty?
    # oh yeah, classes have templates too!
    templated_classes = LegacyClass.all :conditions => [ "templateid is not ? and templateid != ?", nil, 0 ]
    templated_classes.each do |t_class|
      class_page = Page.find_by_legacy_type_and_legacy_id 'class', t_class.id
      imported_layout = PageLayout.find_by_legacy_id t_class.templateid
      class_page.update_attribute( :page_layout_id, imported_layout.id ) if imported_layout and class_page
    end
  end

  def template_tree( legacy_section, templated_sections )
    lp = Page.find_by_legacy_id_and_legacy_type( legacy_section.id,'section' ) 
    if lp && templated_sections.include?( legacy_section.id )
      apply_template_to_tree( lp, PageLayout.find_by_legacy_id( legacy_section.templateid ) )
    else
      LegacySection.find_all_by_parent( legacy_section.id ).each do | ls|
        template_tree( ls, templated_sections )
      end
    end
  end

  def apply_template_to_tree( page, layout_id )
    page.update_attribute :page_layout_id, layout_id
    page.child_pages.each { |cp| apply_template_to_tree( cp, layout_id ) }
  end

  def do_nav_layouts
    LegacyNavLayout.find_by_section_id LegacySection::AMP_ROOT
    LegacyNavLayout.all.each { |nl| nl.import; nl.nav_side = 'right'; nl.import }
  end

  def do_nav_elements
    LegacyNav.all.each { |nav| nav.import }
  end

  def do_navs
    do_nav_layouts
    do_nav_elements
  end

  def do_images
    LegacyImage.all.each { |li| li.import }
  end


  class Configuration
    class Template
      def replace(attr, item_to_match, replace_action)
        LegacyTemplate.after_import do
          initial_value = imported.send(attr)
          updated_value = replace_action
          if replace_action.is_a? Proc
            updated_value = cblock.call(initial_value)
          end
          imported.update_attribute attr, initial_value.gsub( item_to_match, updated_value )
        end
      end

      def ignore(attr, item_to_match)
        replace attr, item_to_match, ''
      end

      def php_include( filename )
        Regexp.new( LegacyTemplate::PHP_TOKEN_PATTERN % ('[^<>]*' + filename + '[^<>]*' ))
      end
      def custom_block( block_name )
        "{% custom_block #{block_name} %}"
      end
      def layout_area( block_name )
        "{% layout_area #{block_name} %}"
      end
    end
    def templates(&block)
      t = Template.new
      t.instance_eval(&block)
    end

    def navs(&block)
      t = Nav.new
      t.instance_eval(&block)
    end

    def nav_layouts(&block)
      t = NavLayout.new
      t.instance_eval(&block)
    end

    class NavLayout
      def after_import( options, &block )
        LegacyNavLayout.after_import do
          action_allowed = true
          if options[:if] 
            action_allowed = options[:if].call(self)
          end
          instance_eval(&block) if action_allowed
        end
      end
    end

    class Nav
      def add_attributes( new_attrs, options = {} )
        LegacyNav.before_import do
          action_allowed = true
          if options[:if] 
            action_allowed = options[:if].call(self)
          end
          self.attributes = new_attrs if action_allowed 
        end
      end
    end

  end

  def self.configure(&block)
    config = Configuration.new 
    yield config
  end
end
