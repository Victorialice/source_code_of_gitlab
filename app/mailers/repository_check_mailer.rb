class RepositoryCheckMailer < BaseMailer
  def notify(failed_count)
    @message =
      if failed_count == 1
        "One project failed its last repository check"
      else
        "#{failed_count} projects failed their last repository check"
      end

    mail(
      to: User.admins.pluck(:email),
      subject: "GitLab Admin | #{@message}"
    )
  end
end
