import Vapor
import SendGridKit

extension Application {
    public struct SendGridClients {
        public struct Provider {
            public static var http: Self {
                .init {
                    $0.sendGridClients.use { $0.sendGridClients.http }
                }
            }
            
            let run: (Application) -> ()
            
            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makeSendGridClient: ((Application) -> SendGridClient)?
            init() { }
        }
        
        struct Key: StorageKey {
            typealias Value = Storage
        }
        
        let application: Application
        
        var http: SendGridClient {
            guard let config = self.application.sendGridClients.configuration else {
                fatalError("SendGridClient has not been configured. Use app.sendGridClients.configuration = ...")
            }
            return self.application.http.client.shared.sendGridDelegating(to: self.application.eventLoopGroup.next(), conf: config)
        }
        
        func initialize() {
            self.application.storage[Key.self] = .init()
        }
        
        func use(_ makeSendGridClient: @escaping (Application) -> (SendGridClient)) {
            self.storage.makeSendGridClient = makeSendGridClient
        }
        
        var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("SendGridClients not initialized. Initialize with app.sendGridClients.initialize()")
            }
            return storage
        }
        
        struct ConfigurationKey: StorageKey {
            typealias Value = SendGridConfiguration
        }
        
        var configuration: SendGridConfiguration? {
            get {
                self.application.storage[ConfigurationKey.self]
            }
            nonmutating set {
                if self.application.storage.contains(Key.self) {
                    self.application.logger.warning("Cannot modify client configuration template after client has been used.")
                } else {
                    self.application.storage[ConfigurationKey.self] = newValue
                }
            }
        }
    }
    
    public var sendGridClients: SendGridClients {
        .init(application: self)
    }
}


extension HTTPClient {
    func sendGridDelegating(to eventLoop: EventLoop, conf: SendGridConfiguration)
    -> SendGridClient {
        
        return SendGridClient( http: self, eventLoop: eventLoop, config: conf)
    }
}
    
//    public struct Sendgrid {
//        private final class Storage {
//            let apiKey: String
//
//            init(apiKey: String) {
//                self.apiKey = apiKey
//            }
//        }
//
//        private struct Key: StorageKey {
//            typealias Value = Storage
//        }
//
//        private var storage: Storage {
//            if self.application.storage[Key.self] == nil {
//                self.initialize()
//            }
//            return self.application.storage[Key.self]!
//        }
//
//        public func initialize() {
//            guard let apiKey = Environment.process.SENDGRID_API_KEY else {
//                fatalError("No sendgrid API key provided")
//            }
//
//            self.application.storage[Key.self] = .init(apiKey: apiKey)
//        }
//
//        fileprivate let application: Application
//
//        public var client: SendGridClient {
//            .init(httpClient: self.application.http.client.shared, apiKey: self.storage.apiKey)
//        }
//    }
//
//    public var sendgrid: Sendgrid { .init(application: self) }
//}

