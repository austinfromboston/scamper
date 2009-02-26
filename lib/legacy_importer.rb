#require 'legacy/article'
class LegacyImporter
  def self.run
    site = LegacySite.find 1
    site.import
    LegacyTemplate.all.each { |lt| lt.import }

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

    # finish with all other content
    legs = LegacyArticle.all :conditions => [ "amp_class != ?", 8 ]
    legs.each do |la|
      begin
        la.import
      rescue LegacyData::TrashedItemImport, LegacyData::OrphanItemImport
        puts "Deleting LegacyArticle #{la.id} as this item is TRASH"
        la.kill_tree
      end
    end

     LegacyRelatedSection.all( :select => "distinct articleid, typeid" ).each { |r| r.import }
  end
end
