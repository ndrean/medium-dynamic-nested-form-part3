class Book < ApplicationRecord
  belongs_to :author
  attr_accessor :new_author
  accepts_nested_attributes_for :author
  # to create an author from a new model Book

end
