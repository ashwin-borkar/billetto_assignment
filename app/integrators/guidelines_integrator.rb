module GuidelinesIntegrators
  class ScheduleCodeRefactorWhenRfcApproved
    include Handler.async(queue: "low")
    subscribes_to Guidelines::RfcApproved

    def call(fact)
      rfc = ObjectRepository.find(fact.data.fetch(:tid))
      command_bus.call(ClickUp::AddNewTaskToTheBacklog.new(**build_task(rfc)))
    end

    private

    def build_task(rfc)
      {
        name: "Code Refactor for RFC #{rfc.number}",
        description: rfc.description,
        priority: "medium"
      }
    end
  end

  def self.subscriptions
    [
      ScheduleCodeRefactorWhenRfcApproved.subscriptions,
    ].reduce(&:merge)
  end
end
