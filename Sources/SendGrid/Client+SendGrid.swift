import Vapor


//extension SendGridClient: Client {
//    public func delegating(to eventLoop: EventLoop) -> Client {
//        SendGridClient(http: self.http, eventLoop: eventLoop, config: self.config!)
//    }
//    
//    public func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
//        do {
//            let httpRequest = try HTTPClient.Request(url: request.url.string,
//                                                 method: request.method,
//                                                 headers: request.headers,
//                                                 body: .byteBuffer(request.body!)
//            )
//            
//            return self.execute(httpRequest)
//                .flatMap{ response -> EventLoopFuture<ClientResponse> in
//                    return self.eventLoop.makeSucceededFuture(
//                        ClientResponse(status: response.status,
//                                      headers: response.headers,
//                                      body: response.body
//                        )
//                    )
//            }
//        } catch {
//            return self.eventLoop.makeFailedFuture(error)
//        }
//    }
//}
