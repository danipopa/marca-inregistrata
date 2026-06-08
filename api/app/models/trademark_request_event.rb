class TrademarkRequestEvent < ApplicationRecord
  belongs_to :trademark_request
  belongs_to :admin_user, class_name: "User", optional: true

  validates :action, presence: true
end
