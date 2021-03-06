class Admin::UsersController < Admin::AdminController

  before_action :set_user, only: [:show, :changerole, :givebonus, :destroy]

  def index
    @users = User.order(created_at: :desc).paginate(:per_page => 15, :page => params[:page])
  end

  def show
    @descendants = @user.descendants
    @parent = @user.parent
    @user_paid = 0;
    # We have scope for this
    Payment.where(to_user_id: @user.id).each do |p|
      @user_paid += p.amount.to_f
    end
    @user_got = 0;
    # We have scope for this
    Withdrawal.where(user_id: @user.id, status: true).each do |w|# I'm not sure about this one)), .amount...
      @user_got += w.amount;
    end
  end

  def changerole
    @user.role = Role.find(params[:role_id])
    if @user.save
      render plain: "User role changed"
    else
      render plain: "Error while changing user role"
    end
  end

  def changeparent
    @user = User.find(params[:id])
    @user.parent = User.find(params[:parent_id])
    if @user.save
      render plain: "User parent changed"
    else
      render plain: "Error while changing user parent"
    end
  end

  def givebonus
    @user.wallet.bonus_balance += params[:amount].to_f
    if @user.wallet.save
      render plain: "Bonus balance updated"
    else
      render plain: "Error while updating bonus balance"
    end
  end

  def destroy
    if @user.destroy
      render plain:'User destroyed'
    else
      render plain:'User not deleted', status: 406
    end
  end

  def parse
    data = params[:data]
    result = User.select(:id, :name, :last_name).where("name REGEXP('^#{data}') OR last_name REGEXP('^#{data}')").limit 10
    logger.debug result.to_a
    render json: result
  end
  private
  def set_user
    @user = User.find params[:id]
  end
end
