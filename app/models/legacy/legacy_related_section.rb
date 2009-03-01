class LegacyRelatedSection < LegacyData
  set_table_name 'articlereltype'
  cattr_accessor :callbacks, :import_to_class
  set_inheritance_column "legacy_type"
  import_to :placement
  IMPORT_KEYS = {
    :placement => {
      :article_id => :confirm_article,
      :page_id => :confirm_section
    }
  }

  def confirm_section
    page = Page.find_by_legacy_id_and_legacy_type typeid, 'section'
    unless page
      section = LegacySection.find typeid
      page = section.import
    end
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
