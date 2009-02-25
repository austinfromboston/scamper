#require 'legacy/article'
class LegacyImporter
  def self.run
    site = LegacySite.find 1
    site.import
    LegacyTemplate.all.each { |lt| lt.import }

    legs = LegacyArticle.all :conditions => [ 'amp_class = ?', 8 ]
    legs.each(&:import)

    # finish with all other content
     legs = LegacyArticle.all :conditions => [ "amp_class != ?", 8 ]
     legs.each(&:import)
     LegacyRelatedSection.all( :select => "distinct articleid, typeid" ).each { |r| r.import }
  end
end
