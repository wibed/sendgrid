import Vapor
import SendGridKit


extension Request {
    var sendgrid: SendGridClient {
        application.sendGridClients.http.delegating(to: self.eventLoop)
    }
}
