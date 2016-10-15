//
//  MetaDataResponse.swift
//  Alamofire
//
//  Created by Theodore Felix Leo on 15/10/16.
//  Copyright © 2016 Alamofire. All rights reserved.
//

import Foundation


public struct MetaDataResponse<MetaValue, DataValue> {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let result: Result<DataValue>
    public let meta: MetaValue
    public let timeline: Timeline
    var _metrics: AnyObject?

    public init(request: URLRequest?,
                response: HTTPURLResponse?,
                data: Data?,
                result: Result<DataValue>,
                meta: MetaValue,
                timeline: Timeline = Timeline()) {

        self.request = request
        self.response = response
        self.data = data
        self.result = result
        self.meta = meta
        self.timeline = timeline
    }
}

@available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
extension MetaDataResponse: Response {
#if !os(watchOS)
    /// The task metrics containing the request / response statistics.
    public var metrics: URLSessionTaskMetrics? { return _metrics as? URLSessionTaskMetrics }
#endif
}
