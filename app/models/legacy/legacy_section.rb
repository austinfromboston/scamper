class LegacySection < LegacyData
  set_table_name "articletype"
  set_inheritance_column nil
  before_create :set_defaults
  def set_defaults
    self.timestamp ||= Time.now
  end
end
