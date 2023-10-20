class TransactionsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @transactions = pagy(Transaction.all.includes(:manager))
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    @transaction = new_transaction
    @manager = manager

    render "new_#{params[:type]}"
  end

  def new_large
    @transaction = new_transaction
  end

  def new_extra_large
    @transaction = new_transaction
    @manager = manager
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @manager = params[:type] == 'extra' ? manager : nil
  
    if @transaction.save
      redirect_to @transaction
    else
      render "new_#{params[:type]}"
    end
  end

  private

  def new_transaction
    Transaction.new
  end

  def manager
    Manager.order("RANDOM()").first
  end

  def transaction_params
    permitted_params = params.require(:transaction).permit(:from_amount_cents, :from_currency, :to_amount_cents, :to_currency)
    (params[:type] == 'extra_large' || params[:type] == 'large') ? permitted_params.merge(params.permit(:first_name, :last_name)) : permitted_params
  end

end
