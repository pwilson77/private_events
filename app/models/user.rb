class User < ApplicationRecord

   has_many :attended_events_tbl, foreign_key: :attendee_id
   has_many :attended_events, through: :attended_events_tbl
   has_many :created_events, foreign_key: :creator_id, class_name: "Event"

    attr_accessor :remember_token    
    before_create :create_remember_digest
    validates :username, presence: true, length: {maximum:50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255}, format:{ with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false}
    has_secure_password

    # Returns the hash digest of the given string.
    def User.digest(token)
        Digest::SHA1.hexdigest(token.to_s)
    end

    # Returns a random token.
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end


    def forget
        update_attribute(:remember_digest, nil)
    end   
    
     # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        digest == Digest::SHA1.hexdigest(token)
    end

    def upcoming_events(user)
        user.attended_events.select(:name).where("eventdate >= ?", Time.current) 
    end
  
    def previous_events(user)
        user.attended_events.select(:name).where("eventdate < ?", Time.current) 
    end


    #------------- private ------------------------

    private

    # Converts email to all lower-case.
    #def downcase_email
    #      self.email = email.downcase
    #end

    
    def create_remember_digest
          self.remember_token   = User.new_token
          self.remember_digest = User.digest(remember_token)
    end

end
