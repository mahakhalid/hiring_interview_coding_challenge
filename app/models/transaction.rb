class Transaction < ApplicationRecord
  AVAILABLE_CURRENCIES = ['USD', 'GBP', 'AUD', 'CAD'].freeze

  belongs_to :manager, optional: true

  monetize :from_amount_cents, with_currency: ->(t) { t.from_currency }, numericality: { greater_than: 0 }
  monetize :to_amount_cents, with_currency: ->(t) { t.to_currency }

  # Validation for first_name and last_name
  validates :first_name, presence: true, if: -> { requires_personal_info? }

  # Validation for currency selection
  validates :from_currency, inclusion: AVAILABLE_CURRENCIES
  validates :to_currency, inclusion: AVAILABLE_CURRENCIES

  validate :currencies_validation
  validate :manager_validation

  before_create :generate_uid
  before_validation :convert

  def client_full_name
    "#{first_name} #{last_name}"
  end

  # Check if this is a large or extra large transaction
  def requires_personal_info?
    large? || extra_large?
  end

  def large?
    from_amount_in_usd > Money.from_amount(100)
  end

  def extra_large?
    from_amount_in_usd > Money.from_amount(1000)
  end

  # Optimize by memoizing the result
  def from_amount_in_usd
    @from_amount_in_usd ||= from_amount.exchange_to('USD')
  end

  private

  def generate_uid
    self.uid = SecureRandom.hex(10) # Make the UID longer for added security
  end

  def convert
    self.to_amount ||= from_amount.exchange_to(to_currency) # Only convert if to_amount is not already set
  end

  def currencies_validation
    errors.add(:from_currency, "can't be converted to the same currency.") if from_currency == to_currency
    errors.add(:from_currency, "available only for conversions over $1000.") if !extra_large? && from_currency != 'USD'
  end

  def manager_validation
    errors.add(:base, "conversions over $1000 require a personal manager.") if extra_large? && manager.nil?
  end
end