module KerberosSpnegoHelper
  def allow_basic_auth?
    true # different behavior in GitLab Enterprise Edition
  end

  def allow_kerberos_spnego_auth?
    false # different behavior in GitLab Enterprise Edition
  end
end
