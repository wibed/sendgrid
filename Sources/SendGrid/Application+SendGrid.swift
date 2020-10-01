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
    
