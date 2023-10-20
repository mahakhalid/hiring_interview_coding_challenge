require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:valid_attributes) do
    {
      from_amount_cents: 100,
      from_currency: 'USD',
      to_amount_cents: 120,
      to_currency: 'GBP',
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  let(:invalid_attributes) do
    {
      from_amount_cents: 50,
      from_currency: 'EUR',
      to_amount_cents: 60,
      to_currency: 'GBP'
    }
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @transactions and @pagy' do
      transaction = Transaction.create!(valid_attributes)
      get :index
      expect(assigns(:transactions)).to eq([transaction])
      expect(assigns(:pagy)).to be_a(Pagy)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      transaction = Transaction.create!(valid_attributes)
      get :show, params: { id: transaction.to_param }
      expect(response).to be_successful
    end

    it 'assigns the requested transaction as @transaction' do
      transaction = Transaction.create!(valid_attributes)
      get :show, params: { id: transaction.to_param }
      expect(assigns(:transaction)).to eq(transaction)
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new transaction as @transaction' do
      get :new
      expect(assigns(:transaction)).to be_a_new(Transaction)
    end
  end

  describe 'GET #new_large' do
    it 'returns a success response' do
      get :new_large
      expect(response).to be_successful
    end

    it 'assigns a new transaction as @transaction' do
      get :new_large
      expect(assigns(:transaction)).to be_a_new(Transaction)
    end
  end

  describe 'GET #new_extra_large' do
    it 'returns a success response' do
      get :new_extra_large
      expect(response).to be_successful
    end

    it 'assigns a new transaction as @transaction' do
      get :new_extra_large
      expect(assigns(:transaction)).to be_a_new(Transaction)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Transaction' do
        expect do
          post :create, params: { transaction: valid_attributes, type: 'extra_large' }
        end.to change(Transaction, :count).by(1)
      end

      it 'redirects to the created transaction' do
        post :create, params: { transaction: valid_attributes, type: 'extra_large' }
        expect(response).to redirect_to(Transaction.last)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (new_extra_large)' do
        post :create, params: { transaction: invalid_attributes, type: 'extra_large' }
        expect(response).to be_successful
      end

      it 'returns a success response (new_large)' do
        post :create, params: { transaction: invalid_attributes, type: 'large' }
        expect(response).to be_successful
      end
    end
  end
end
