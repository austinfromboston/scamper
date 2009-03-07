class LegacyRelatedSection < LegacyData
  set_table_name 'articlereltype'
  cattr_accessor :callbacks, :import_to_class
  set_inheritance_column "legacy_type"
  import_to :placement
  IMPORT_KEYS = {
    :placement => {
      :child_item_type => 'Article',
      :child_item_id   => :confirm_article,
      :page_id    => :confirm_section,
      :view_type  => lambda { |rl| 
          section = LegacySection.find (rl.typeid)
          'hidden' if section && section.usetype 
      }
    }
  }

  def confirm_section
    page = Page.find_by_legacy_id_and_legacy_type typeid, 'section'
    section = LegacySection.find typeid
    page ||= section.import
    page.id
  rescue
    nil
  end

  def confirm_article
    art = Article.find_by_legacy_id_and_legacy_type articleid, 'article'
    unless art
      article = LegacyArticle.find articleid
      art = article.import
    end
    art.id
  rescue
    nil
 end
end
