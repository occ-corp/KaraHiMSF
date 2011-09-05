# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:each) do
    I18n.locale = :ja
  end

end

def build_simple_evaluation_tree(klass=EvaluationTree)
  klass.delete_all

  users = User.all

  @evaluation_tree_head = klass.create :user => users.first,
  :name => "head"

  @evaluation_tree_child0 = klass.create :user => users[1],
  :name => "child0"
  @evaluation_tree_child0.move_to_child_of @evaluation_tree_head

  @evaluation_tree_child1 = klass.create :user => users[2],
  :name => "child1"
  @evaluation_tree_child1.move_to_child_of @evaluation_tree_head

  @evaluation_tree_sub_child = klass.create :user => users[3],
  :name => "sub_child"
  @evaluation_tree_sub_child.move_to_child_of @evaluation_tree_child1
end
