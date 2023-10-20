require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'validations' do
    it { should validate_inclusion_of(:from_currency).in_array(Transaction::AVAILABLE_CURRENCIES) }
    it { should validate_inclusion_of(:to_currency).in_array(Transaction::AVAILABLE_CURRENCIES) }

    context 'when it requires personal info' do
      before { allow(subject).to receive(:requires_personal_info?).and_return(true) }

      it { should validate_presence_of(:first_name) }
      it { should validate_presence_of(:last_name) }
    end

    context 'when it does not require personal info' do
      before { allow(subject).to receive(:requires_personal_info?).and_return(false) }

      it { should_not validate_presence_of(:first_name) }
      it { should_not validate_presence_of(:last_name) }
    end
  end

  describe 'associations' do
    it { should belong_to(:manager).optional }
  end

  describe 'callbacks' do
    it { should callback(:generate_uid).before(:create) }
    it { should callback(:convert).before(:validation) }
  end

  describe 'methods' do
    describe '#requires_personal_info?' do
      it 'returns true if it requires personal info' do
        allow(subject).to receive(:large?).and_return(true)
        expect(subject.requires_personal_info?).to be(true)
      end

      it 'returns false if it does not require personal info' do
        allow(subject).to receive(:large?).and_return(false)
        expect(subject.requires_personal_info?).to be(false)
      end
    end

    describe '#large?' do
      it 'returns true if from_amount is greater than $100' do
        allow(subject).to receive(:from_amount_in_usd).and_return(Money.from_amount(101))
        expect(subject.large?).to be(true)
      end

      it 'returns false if from_amount is less than or equal to $100' do
        allow(subject).to receive(:from_amount_in_usd).and_return(Money.from_amount(100))
        expect(subject.large?).to be(false)
      end
    end

    describe '#extra_large?' do
      it 'returns true if from_amount is greater than $1000' do
        allow(subject).to receive(:from_amount_in_usd).and_return(Money.from_amount(1001))
        expect(subject.extra_large?).to be(true)
      end

      it 'returns false if from_amount is less than or equal to $1000' do
        allow(subject).to receive(:from_amount_in_usd).and_return(Money.from_amount(1000))
        expect(subject.extra_large?).to be(false)
      end
    end
  end
end
