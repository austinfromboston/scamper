#require 'legacy/article'
class LegacyImporter
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
      raise "created now" if Page.find_by_legacy_id 25
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
  end

  def template_tree( legacy_section, templated_sections )
    lp = Page.find_by_legacy_id( legacy_section.id ) 
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

  def self.run
    importer = LegacyImporter.new
    importer.do_site
    importer.do_templates
    importer.do_section_headers
    importer.do_all_articles
    importer.do_related_sections

    importer.do_template_inheritance


  end
end
