class Author < ApplicationRecord
    has_many :books
    accepts_nested_attributes_for :books
    validates :name, uniqueness: true, reject_if: blank?
    # to create dynamic books for an author in 'authors/new'
end
