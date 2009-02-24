#require 'legacy/article'
class LegacyImporter
  def self.run
    site = LegacySite.find 1
    site.import
    #task must be run prefixed by db:migrate or this explodes
    legs = LegacyArticle.all :conditions => [ 'amp_class = ?', 8 ]
    legs.each(&:import)

    # finish with all other content
    legs = LegacyArticle.all :conditions => [ "amp_class != ?", 8 ]
    legs.each(&:import)
  end
end
