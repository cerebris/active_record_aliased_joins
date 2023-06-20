# frozen_string_literal: true

### MODELS
class Person < ActiveRecord::Base
  has_many :posts, foreign_key: 'author_id'
  has_many :comments, foreign_key: 'author_id'
  has_many :book_comments, foreign_key: 'author_id'
  has_one :author_detail
end

class AuthorDetail < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'person_id'
end

class Post < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'author_id'
  belongs_to :writer, class_name: 'Person', foreign_key: 'author_id'
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :author, class_name: 'Person', foreign_key: 'author_id'
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
  has_and_belongs_to_many :parts
end

class Part < ActiveRecord::Base
  has_and_belongs_to_many :assemblies
end

class Town < ActiveRecord::Base
  belongs_to :state
end

class State < ActiveRecord::Base
  has_many :towns
end
