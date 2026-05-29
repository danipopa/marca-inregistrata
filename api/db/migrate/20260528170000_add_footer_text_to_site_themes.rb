class AddFooterTextToSiteThemes < ActiveRecord::Migration[8.1]
  DEFAULT_FOOTER_TEXT = "SANDU si Asociatii IP Attorney este o agentie de proprietate industriala specializata in marci, desene si modele, brevete de inventie, membra a CNCPIR (Camera Nationala a Consilierilor de Proprietate Industriala din Romania).".freeze

  def up
    add_column :site_themes, :footer_text, :text
    update "UPDATE site_themes SET footer_text = #{quote(DEFAULT_FOOTER_TEXT)} WHERE footer_text IS NULL"
  end

  def down
    remove_column :site_themes, :footer_text
  end
end
