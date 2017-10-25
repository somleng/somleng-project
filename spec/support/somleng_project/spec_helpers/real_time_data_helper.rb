class SomlengProject::SpecHelpers::RealTimeDataHelper
  def project_assertions
    asserted_data[:projects]
  end

  def aggregate_data_assertions
    asserted_data[:aggregate]
  end

  def project_env
    Hash[project_assertions.map { |project_key, data| [data[:env_var_key], data[:project_id]] }]
  end

  def document_assertions
    asserted_documents = {}
    project_assertions.map { |_, assertions| assertions[:real_time_data_assertions] }.compact.each do |document_assertion|
      asserted_document = document_assertion[:asserted_in]
      next if !asserted_document
      asserted_documents[asserted_document] = (asserted_documents[asserted_document] || []) + (document_assertion[:content] || [])
    end
    asserted_documents
  end

  private

  def asserted_data
    @asserted_data ||= {
      :aggregate => {
        :real_time_data_assertions => {
          :content => [],
          :data => {
            "calls_count" => 235736
          }
        }
      },
      :projects => {
        :avf => {
          :project_id => "11d41773-cb37-4614-883d-602bb4e1824e",
          :env_var_key =>  "AVF_PROJECT_ID",
          :real_time_data_assertions => {
            :content => [
              "$0.7680 per minute",
              "$31,130.88",
              "https://www.twilio.com/voice/pricing/so"
            ],
            :asserted_in => "SomlengProject::IntroductionForDevelopmentOrganizationsRenderer"
          }
        },
        :ews => {
          :project_id => "6bb193d9-876e-4846-a42f-8a35db66b477",
          :env_var_key => "EWS_PROJECT_ID",
          :real_time_data_assertions => {
            :content => [
              "113 K calls",
              "229 K minutes",
              "79.9 K calls",
              "81.1 K minutes",
              "$8,105.19",
              "https://www.twilio.com/voice/pricing/kh"
            ],
            :data => {
              "calls_count" => 192432
            },
            :asserted_in => "SomlengProject::IntroductionForDevelopmentOrganizationsRenderer"
          }
        }
      }
    }
  end
end
