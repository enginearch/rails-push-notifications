module RailsPushNotifications
  #
  # Abstract. This class is the base of all application entity type.
  #
  # @author Carlos Alonso
  #
  class BaseApp < ActiveRecord::Base

    self.abstract_class = true

    # has_many notifications
    has_many :notifications, as: :app

    #
    # This method will find all notifications owned by this app and
    # push them.
    #
    def push_notifications
      puts "In push notifications"
      pending = find_pending
      logger.warn "Pending length: #{pending.length}"
      pending.update_all(processing: true) # in case other threads want to do that too
      p "updated processing"
      to_send = pending.map do |notification|
        notification_type.new notification.destinations, notification.data
      end
      logger.warn "To send length: #{to_send.length}"
      pusher = build_pusher
      pusher.push to_send
      logger.warn "after push"
      pending.each_with_index do |p, i|
        logger.warn "update with: #{results}"
        p.update_attributes! results: to_send[i].results, processing: false
      end
      puts "After push notifications"
    end

    protected

    #
    # Method that searches the owned notifications for those not yet sent
    #
    def find_pending
      notifications.where sent: false, processing: false
    end
  end
end
