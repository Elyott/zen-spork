require 'json-diff'

class Recipe < ApplicationRecord

  belongs_to :user
  has_one :spork
  has_many :sporks, foreign_key: "original_recipe_id"

  validates :title, presence: true
  validates_length_of :title, :maximum => 30
  validates :content, presence: true

  validate :content_is_acceptable
  validate :photo_url_resembles_a_url
  validate :reference_url_resembles_a_url

  def sporks_count
    self.sporks.count
  end

  def similarity
    if self.spork.present?
      JsonDiff.similarity(self.spork.original_recipe.content, self.content, similarity: nil)
    else
      0
    end
  end

  def content_is_acceptable
      begin
        errors.add(:content, "steps cannot be blank") if content["steps"].blank?
        errors.add(:content, "must have at least one step") if content["steps"].length.zero?
      rescue
        errors.add(:content, "must exist")
      end
  end

  def photo_url_resembles_a_url
    if photo_url.present?
      # not checking for ending in .jpg, .png, etc, because many images are served from routes without valid image file extensions.
      errors.add(:photo_url, "must be valid http or https url") unless /^https?:\/\// =~ photo_url
    end
  end

  def reference_url_resembles_a_url
    if reference_url.present?
      errors.add(:reference_url, "must be valid http or https url") unless /^https?:\/\// =~ reference_url
    end
  end
end
