class FeedbackMailer < ActionMailer::Base
  default from: "root@himholod.ru"
  def feedback_resend(feedback)
    @feedback = feedback
    mail(:to => 'web@himholod.ru', :subject => "Feedback")
  end
end
