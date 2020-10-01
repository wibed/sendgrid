import Vapor
import SendGridKit

extension HTTPClient {
    func sendGridDelegating(to eventLoop: EventLoop, conf: SendGridConfiguration)
    -> SendGridClient {
        
        return SendGridClient( http: self, eventLoop: eventLoop, config: conf)
    }
}
