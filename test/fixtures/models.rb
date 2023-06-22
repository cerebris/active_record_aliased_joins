# frozen_string_literal: true

### MODELS
class Person < ActiveRecord::Base
  has_many :posts, foreign_key: 'auth_id'
  has_many :comments, foreign_key: 'auth_id'
  has_many :book_comments, foreign_key: 'auth_id'
  has_one :author_detail
end

class AuthorDetail < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'prsn_id'
end

class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'auth_id'
  belongs_to :writer, class_name: 'Person', foreign_key: 'auth_id'
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'auth_id'
  belongs_to :post
end

class Physician < ActiveRecord::Base
  has_many :appointments
  has_many :patients, through: :appointments
  has_many :towns, through: :patients
  has_many :states, through: :patients
end

class Appointment < ActiveRecord::Base
  belongs_to :physician
  belongs_to :patient
end

class Patient < ActiveRecord::Base
  has_many :appointments
  has_many :physicians, through: :appointments
  belongs_to :town
  has_one :state, through: :town
end

class Assembly < ActiveRecord::Base
  has_and_belongs_to_many :parts, association_foreign_key: :part_number
end

class Part < ActiveRecord::Base
  self.primary_key = :number
  has_and_belongs_to_many :assemblies
end

class Town < ActiveRecord::Base
  belongs_to :state, foreign_key: :state_code
end

class State < ActiveRecord::Base
  self.primary_key = :code
  has_many :towns
end
