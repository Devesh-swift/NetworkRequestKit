//
//  NetworkClient.swift
//  CalendarApp
//
//  Created by David on 2016/9/5.
//  Copyright © 2016年 David. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

public protocol NetworkClientType {
	func performRequest<Request: NetworkRequest>(_ networkRequest: Request) -> Promise<Data>
	func performArrayRequest<Request: NetworkRequest>(_ networkRequest: Request) -> Promise<(Data, Progress?)>
}

public struct NetworkClient: NetworkClientType {
	
	public func performRequest<Request : NetworkRequest>(_ networkRequest: Request) -> Promise<Data> {
		
		let (promise, fulfill, reject) = Promise<Data>.pending()
		print("🔗", #function, "send request to url:", networkRequest.url)
        print("📩 method:", networkRequest.method)
        print("🚠 parameters:", networkRequest.parameters ?? [:])
		
		request(networkRequest.url,
		        method: networkRequest.method,
		        parameters: networkRequest.parameters,
		        encoding: networkRequest.encoding,
		        headers: networkRequest.headers)
			.validate().response { (response) in
				if let data = response.data , response.error == nil {
					fulfill(data)
				} else if let error = response.error, let data = response.data {
                    let e = AlamofireErrorHandler.handleNetworkRequestError(error, data: data, urlResponse: response.response)
					reject(e)
				} else {
					reject(NetworkRequestError.unknownError)
				}
		}
		
		return promise
	}
	
	public func performArrayRequest<Request : NetworkRequest>(_ networkRequest: Request) -> Promise<(Data, Progress?)> {
		return performRequest(networkRequest).then { data in
			return Promise(value: (data, networkRequest.progress))
		}
	}
	
}
