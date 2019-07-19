//
//  TeslaSwift+Combine.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 08/07/2019.
//  Copyright © 2019 Joao Nunes. All rights reserved.
//

import Combine
import TeslaSwift

@available(iOS 13.0, macOS 10.15, watchOS 6, tvOS 13, *)
extension TeslaSwift {
    
    func resultify<Value: Decodable>(subscriber: @escaping (Result<Value, Error>) -> Void) -> ((Value?, Error?) -> ()) {
        
        return { (result: Value?, error: Error?) in
            if let result = result {
                subscriber(.success(result))
            } else if let error = error {
                subscriber(.failure(error))
            } else {
                // not possible
            }
        }
        
    }
    
    public func authenticate(email: String, password: String) -> Future<AuthToken, Error> {
       
        let future = Future<AuthToken,Error> { (subscriber: @escaping (Result<AuthToken, Error>) -> Void) in
            
            self.authenticate(email: email, password: password, completion: self.resultify(subscriber: subscriber))
            
        }
    
        return future
    }
    
    public func revoke() -> Future<Bool, Error> {
        
        let future = Future<Bool,Error> { (subscriber: @escaping (Result<Bool, Error>) -> Void) in
            
            self.revoke(completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicles() -> Future<[Vehicle], Error> {
        
        let future = Future<[Vehicle],Error> { (subscriber: @escaping (Result<[Vehicle], Error>) -> Void) in
            
            self.getVehicles(completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getAllData(_ vehicle: Vehicle) -> Future<VehicleExtended, Error> {
        
        let future = Future<VehicleExtended,Error> { (subscriber: @escaping (Result<VehicleExtended, Error>) -> Void) in
            
            self.getAllData(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleMobileAccessState(_ vehicle: Vehicle) -> Future<Bool, Error> {
        
        let future = Future<Bool,Error> { (subscriber: @escaping (Result<Bool, Error>) -> Void) in
            
            self.getVehicleMobileAccessState(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleChargeState(_ vehicle: Vehicle) -> Future<ChargeState, Error> {
        
        let future = Future<ChargeState,Error> { (subscriber: @escaping (Result<ChargeState, Error>) -> Void) in
            
            self.getVehicleChargeState(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleChargeState(_ vehicle: Vehicle) -> Future<ClimateState, Error> {
        
        let future = Future<ClimateState,Error> { (subscriber: @escaping (Result<ClimateState, Error>) -> Void) in
            
            self.getVehicleClimateState(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleDriveState(_ vehicle: Vehicle) -> Future<DriveState, Error> {
        
        let future = Future<DriveState,Error> { (subscriber: @escaping (Result<DriveState, Error>) -> Void) in
            
            self.getVehicleDriveState(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleGuiSettings(_ vehicle: Vehicle) -> Future<GuiSettings, Error> {
        
        let future = Future<GuiSettings,Error> { (subscriber: @escaping (Result<GuiSettings, Error>) -> Void) in
            
            self.getVehicleGuiSettings(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleState(_ vehicle: Vehicle) -> Future<VehicleState, Error> {
        
        let future = Future<VehicleState,Error> { (subscriber: @escaping (Result<VehicleState, Error>) -> Void) in
            
            self.getVehicleState(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func getVehicleConfig(_ vehicle: Vehicle) -> Future<VehicleConfig, Error> {
        
        let future = Future<VehicleConfig,Error> { (subscriber: @escaping (Result<VehicleConfig, Error>) -> Void) in
            
            self.getVehicleConfig(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func wakeUp(_ vehicle: Vehicle) -> Future<Vehicle, Error> {
        
        let future = Future<Vehicle,Error> { (subscriber: @escaping (Result<Vehicle, Error>) -> Void) in
            
            self.wakeUp(vehicle, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    public func sendCommandToVehicle(_ vehicle: Vehicle, command: VehicleCommand) -> Future<CommandResponse, Error> {
        
        let future = Future<CommandResponse,Error> { (subscriber: @escaping (Result<CommandResponse, Error>) -> Void) in
            
            self.sendCommandToVehicle(vehicle, command: command, completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
    }
    
    
    func checkAuthentication() -> Future<AuthToken, Error> {
        
        let future = Future<AuthToken,Error> { (subscriber: @escaping (Result<AuthToken, Error>) -> Void) in
            
            self.checkAuthentication(completion: self.resultify(subscriber: subscriber))
            
        }
        
        return future
        
    }

    func request<ReturnType: Decodable, BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> Future<ReturnType, Error> {
        
        let future = Future<ReturnType,Error> { (subscriber: @escaping (Result<ReturnType, Error>) -> Void) in
            
            self.request(endpoint, body: body, completion: self.resultify(subscriber: subscriber))

        }
                
        return future
    }
    
    func streamPublisher(vehicle: Vehicle) -> TeslaStreamingPublisher {
        
        guard let email = email,
            let vehicleToken = vehicle.tokens?.first else {
                //dataReceived((nil, TeslaError.streamingMissingEmailOrVehicleToken))
                let endpoint = StreamEndpoint.stream(email: "", vehicleToken: "", vehicleId: "\(vehicle.vehicleID!)")
                return streamPublisher(endpoint: endpoint)
        }
        
        let endpoint = StreamEndpoint.stream(email: email, vehicleToken: vehicleToken, vehicleId: "\(vehicle.vehicleID!)")
        
        
        return streamPublisher(endpoint: endpoint)
    }
}

@available(iOS 13.0, macOS 10.15, watchOS 6, tvOS 13, *)
extension TeslaSwift  {
    
    public struct TeslaStreamingPublisher: Publisher, Cancellable {
        
        public typealias Output = TeslaStreamingEvent
        public typealias Failure = Error
        
        let endpoint: StreamEndpoint
        let stream: TeslaStreaming
        
        init(endpoint: StreamEndpoint, stream: TeslaStreaming) {
            self.endpoint = endpoint
            self.stream = stream
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, TeslaStreamingPublisher.Failure == S.Failure, TeslaStreamingPublisher.Output == S.Input {
            
            stream.openStream(endpoint: endpoint, streamOpen: {
               
                _ = subscriber.receive(TeslaStreamingEvent.open)
                
            }) { (event: StreamEvent?, error: Error?) in
                
                if let event = event {
                    _ = subscriber.receive(TeslaStreamingEvent.event(event))
                } else if let error = error {
                    _ = subscriber.receive(TeslaStreamingEvent.error(error))
                } else {
                    _ = subscriber.receive(TeslaStreamingEvent.disconnected)
                    _ = subscriber.receive(completion: Subscribers.Completion.finished)
                }
                
            }
            
        }
        
        public func cancel() {
            stream.closeStream()
        }
        
    }
    
    func streamPublisher(endpoint: StreamEndpoint) -> TeslaStreamingPublisher {
        
        return TeslaStreamingPublisher(endpoint: endpoint, stream: TeslaStreaming())
    }
    
    public enum TeslaStreamingEvent {
        case open
        case event(StreamEvent)
        case error(Error)
        case disconnected
    }
    
}
