#require 'legacy/article'
class LegacyImporter
  def do_site
    site = LegacySite.find 1
    site.import
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

  def do_articles
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

  def self.run
    importer = LegacyImporter.new
    importer.do_site
    importer.do_templates
    importer.do_section_headers
    importer.do_all_articles
    importer.do_related_sections


  end
end
