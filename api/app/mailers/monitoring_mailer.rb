class MonitoringMailer < ApplicationMailer
  def match_alert(match_id)
    match = MonitoringMatch.find(match_id)
    subscription = match.monitoring_subscription
    body = "Monitorizare: #{subscription.mark}\nNumăr: #{subscription.registration_number} (#{subscription.registration_office})\n\n" \
      "Rezultat analizat de echipă: #{match.name} (#{match.office})\nReferință: #{match.external_id}\n"
    mail(to: subscription.email, subject: "Monitorizare marcă: rezultat nou pentru #{subscription.mark}", body: body, content_type: "text/plain")
  end

  def monthly_report(subscription_id, since)
    subscription = MonitoringSubscription.find(subscription_id)
    checks = subscription.monitoring_checks.where("finished_at > ?", Time.iso8601(since))
    matches = subscription.monitoring_matches.where(review_status: "relevant").where("first_seen_at > ?", Time.iso8601(since))
    body = "Raport de monitorizare: #{subscription.mark}\nPerioadă: #{since} — #{Time.current.iso8601}\n" \
      "Verificări finalizate: #{checks.where(status: 'succeeded').count}\nVerificări eșuate: #{checks.where(status: 'failed').count}\n" \
      "Rezultate relevante: #{matches.count}\nRezultate în curs de analiză: #{subscription.monitoring_matches.where(review_status: 'pending').count}\n\n"
    matches.find_each { |match| body << "#{match.name} (#{match.office}) — #{match.external_id}\n" }
    mail(to: subscription.email, subject: "Raport lunar de monitorizare: #{subscription.mark}", body: body, content_type: "text/plain")
  end
end
