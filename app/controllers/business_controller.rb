class BusinessController < ApplicationController
  before_action :authenticate_user!
  before_action :pro_user
  before_action :prepare_params, only: [:activate, :update_settings]
  # before_action :prepare_business_list, only: [:all_business]
  
  def index
  end
  
  def business
  	unless params[:type]
  	  params[:type] == 'all'
  	end
  	
  	if(params[:type] == 'my')
  	  @businesses = current_user.businesses.paginate(:per_page => 4, :page => params[:page])
  	# elsif ['all', 'problem', 'recent'].include? params[:type]
	else
	  @businesses = eval('Business.' + params[:type]).paginate(:per_page => 4, :page => params[:page])  
  	# elsif params[:type].class == Fixnum 
  	#   @business = Business.find(
  	#   redirect_to 
  	end
  	render 'all_business'
  end
  
  def activate
  	# begin
  	  @business = Business.find(params[:id])
  	  parent_link = PartnerLink.find_or_create_by(
  	  	user_id: current_user.id, 
  	  	use_for: @business.name
  	  )
  	  parent_link.update_attribute(:link, ref_link)
  	  UserBusiness.find_or_create_by(
  	    user_id: current_user.id, 
        business_id: @business.id
      ).update_attributes(partner_link_id: parent_link.id, block_reg: params['block_reg'])

  	  flash[:notice] = 'Поздавляем, бизнес успешно активирован'
  	  redirect_to "/landings/?business_id=#{@business.id}"
  	# rescue
  	#   flash[:error] = 'Что то пошло не так, обратитесь в тех поддержку'
  	#   redirect_to business_path 'all'
  	# end
  end
  
  def deactivate
  	settings = UserBusiness.find_by(user_id: current_user.id, business_id: params[:id])
  	unless settings
  	  flash[:error] = 'Не удалось найти..'
  	  redirect_to business_path 'all'
  	  return
  	end
  	unless settings.destroy
  	  flash[:error] = 'Что то пошло не так, обратитесь в тех поддержку'
      redirect_to business_path 'all'
  	  return
  	end
  	flash[:notice] = 'Вы успешно деактивировали бизнес'
  	redirect_to business_path 'my'
  end

  def settings
  	@settings = UserBusiness.find_by(
  	  user_id: current_user.id, business_id: params[:id]
  	)
  	@partner_link = @settings.partner_link
  	@business = Business.find(params[:id])
  end
  
  def update_settings
  	@settings = UserBusiness.find_by(user_id: current_user.id, business_id: params[:id])
  	@settings.update_attribute(:block_reg, params['block_reg'])
  	@settings.partner_link.update_attribute(:link, ref_link)
  	flash[:notice] = "Изменения сохранены"
  	redirect_to user_business_path, id: params[:id]
  end
  
  private
  def pro_user
  	redirect_to '/' unless user_has_rights
  end

  def prepare_params
  	if (params[:link].blank? && params[:partner_link][:link].blank?) || params[:id].blank?
  	# if params[:ref_link].blank?
  	  flash[:error] = 'Введите свою реферральную ссылку, пожалуйста'
  	  redirect_to business_path 'all'
  	end
  	# params.require(:ref_link)
  end

  def ref_link
  	ref_link_str = params[:link] || params[:partner_link][:link]
  	if redex_business? and not ref_link_str.start_with?('redex_site.com/')
  	  'redex_site.com/' + ref_link_str
  	else
  	  ref_link_str
  	end  	
  end

  def redex_business?
  	params[:id] == "1" #Redex business_id
  end
  
  def prepare_business_list	
  end
end
  