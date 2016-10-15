//
//  MetaDataResponseSerialization.swift
//  Alamofire
//
//  Created by Theodore Felix Leo on 15/10/16.
//  Copyright © 2016 Alamofire. All rights reserved.
//

import Foundation

public protocol MetaDataResponseSerializerProtocol {
    associatedtype SerializedObject
    associatedtype MetaObject

    var serializeResponse: (URLRequest?, HTTPURLResponse?, Data?, Error?) ->  (Result<SerializedObject>, MetaObject) { get }
}

public struct MetaDataResponseSerializer<MetaValue, DataValue>: MetaDataResponseSerializerProtocol {

    public typealias SerializedObject = DataValue
    public typealias MetaObject = MetaValue

    public var serializeResponse: (URLRequest?, HTTPURLResponse?, Data?, Error?) -> (Result<DataValue>, MetaValue)

    public init(serializeResponse: @escaping (URLRequest?, HTTPURLResponse?, Data?, Error?) -> (Result<DataValue>, MetaValue)) {
        self.serializeResponse = serializeResponse
    }
}

extension DataRequest {

    @discardableResult
    public func response<T: MetaDataResponseSerializerProtocol>(
        queue: DispatchQueue? = nil,
        responseSerializer: T,
        completionHandler: @escaping (MetaDataResponse<T.MetaObject, T.SerializedObject>) -> Void) -> Self {

        delegate.queue.addOperation {
            let result = responseSerializer.serializeResponse(
                self.request,
                self.response,
                self.delegate.data,
                self.delegate.error)

            let requestCompletedTime = self.endTime ?? CFAbsoluteTimeGetCurrent()
            let initialResponseTime = self.delegate.initialResponseTime ?? requestCompletedTime

            let timeline = Timeline(
                requestStartTime: self.startTime ?? CFAbsoluteTimeGetCurrent(),
                initialResponseTime: initialResponseTime,
                requestCompletedTime: requestCompletedTime,
                serializationCompletedTime: CFAbsoluteTimeGetCurrent()
            )

            var dataResponse = MetaDataResponse<T.MetaObject, T.SerializedObject>(
                request: self.request,
                response: self.response,
                data: self.delegate.data,
                result: result.0,
                meta: result.1,
                timeline: timeline
            )

            dataResponse.add(self.delegate.metrics)

            (queue ?? DispatchQueue.main).async { completionHandler(dataResponse) }
        }
        
        return self
    }

}
