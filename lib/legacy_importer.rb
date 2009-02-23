#require 'legacy/article'
class LegacyImporter
  def self.run
    # section headers create sections nicely
    legs = LegacyArticle.all :conditions => [ "amp_class = ?", 8 ]
    legs.each(&:import)

    # finish with all other content
    legs = LegacyArticle.all :conditions => [ "amp_class != ?", 8 ], :limit => 10
    legs.each(&:import)
  end
end
