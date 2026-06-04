require "test_helper"

class Api::V1::ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "sends a contact message" do
    assert_emails 1 do
      post api_v1_contact_messages_url,
        params: {
          contact_message: {
            name: "Client Test",
            email: "client@example.com",
            phone: "0770 000 000",
            message: "Vreau detalii despre inregistrarea unei marci."
          }
        },
        headers: { "REMOTE_ADDR" => "203.0.113.12" },
        as: :json
    end

    assert_response :created
    assert_equal "Mesajul a fost trimis.", response.parsed_body["message"]

    email = ActionMailer::Base.deliveries.last
    assert_equal [ "contact@inregistrare-marca.com" ], email.to
    assert_equal [ "client@example.com" ], email.reply_to
    assert_includes email.subject, "Mesaj nou"
    assert_includes email.text_part.body.to_s, "Client Test"
    assert_includes email.text_part.body.to_s, "203.0.113.12"
  end

  test "rejects incomplete contact messages" do
    assert_no_emails do
      post api_v1_contact_messages_url,
        params: {
          contact_message: {
            name: "Client Test",
            email: "invalid",
            message: ""
          }
        },
        as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "Completeaza numele, emailul si mesajul.", response.parsed_body["message"]
  end
end
