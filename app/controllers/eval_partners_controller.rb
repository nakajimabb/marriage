class EvalPartnersController < ApplicationController
  def permit
    if current_user.role_matchmaker? && params[:user_id] && params[:partner_id] && params[:permitted]
      user = User.find_by_id(params[:user_id])
      partner = User.find_by_id(params[:partner_id])
      if user.matchmaker_id == current_user.id && current_user.viewable?(partner)
        eval_partner = EvalPartner.find_or_initialize_by(user_id: user.id, partner_id: partner.id)
        eval_partner.permitted = (params[:permitted] == 'true')
        if eval_partner.save
          render status: 200, json: {eval_partner: eval_partner}
        else
          render status: 500, json: {errors: eval_partner.errors}
        end
      end
    else
      render status: 401
    end
  end
end
