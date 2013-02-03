class FeedbacksController < ApplicationController
  def add
  feedback = params
	result = 'success'
	result = I18n.t('feedback_form.body_error') unless feedback[:body] && feedback[:body].size > 0
	result = I18n.t('feedback_form.email_error') unless valid_email?(feedback[:email])
	result = I18n.t('feedback_form.name_error') unless feedback[:name] && feedback[:name].size > 0

  params = {:name => feedback[:name], :email => feedback[:email], :body => feedback[:body]}

  feedback_model = Feedback.create(params) if result == 'success'
	FeedbackMailer.feedback_resend(feedback_model).deliver

	respond_to do |format|
		format.html { redirect_to(section_path(:id => Section::FEEDBACK_NAME)) }
		format.js { render :json => {:result => result} }
	end

  end
  
  def valid_email?(email)
	email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  end
end
