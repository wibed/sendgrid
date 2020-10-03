import Vapor
import SendGridKit


extension Request {
    public var sendgrid: SendGridClient {
        application.sendGridClients.http.delegating(to: self.eventLoop)
    }
}
