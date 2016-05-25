//
//  HTTPUtils.swift
//  WolfCore
//
//  Created by Robert McNally on 7/5/15.
//  Copyright © 2015 Arciem LLC. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
}

public enum ContentType: String {
    case JSON = "application/json"
    case JPG = "image/jpeg"
    case PNG = "image/png"
    case HTML = "text/html"
    case TXT = "text/plain"
}

public enum HeaderField: String {
    case Accept = "Accept"
    case ContentType = "Content-Type"
    case Encoding = "Encoding"
    case Authorization = "Authorization"
}

public enum ResponseCode: Int {
    case OK = 200
    case Created = 201
    case Accepted = 202
    case NoContent = 204

    case BadRequest = 400
    case Forbidden = 403
    case NotFound = 404

    case InternalServerError = 500
    case NotImplemented = 501
    case BadGateway = 502
    case ServiceUnavailable = 503
    case GatewayTimeout = 504
}

public class HTTP {
    public static func retrieve(withRequest request: NSMutableURLRequest,
                                            success: (NSHTTPURLResponse, NSData) -> Void,
                                            failure: (ErrorType) -> Void,
                                            finally: (() -> Void)? = nil) {

        let session = NSURLSession.sharedSession()

        logTrace("request :\(request)")

        let task = session.dataTaskWithRequest(request) { (let data, let response, let error) in
            guard error == nil else {
                dispatchOnMain { failure(error!) }
                dispatchOnMain { finally?() }
                return
            }

            guard let httpResponse = response as? NSHTTPURLResponse else {
                fatalError("improper response type: \(response)")
            }

            guard data != nil else {
                dispatchOnMain { failure(HTTPError(response: httpResponse)) }
                dispatchOnMain { finally?() }
                return
            }

            dispatchOnMain { success(httpResponse, data!) }
            dispatchOnMain { finally?() }
        }

        task.resume()
    }

    public static func retrieveJSON(withRequest request: NSMutableURLRequest,
                                                success: (NSHTTPURLResponse, JSONObject) -> Void,
                                                failure: (ErrorType) -> Void,
                                                finally: (() -> Void)? = nil) {

        request.setValue(ContentType.JSON.rawValue, forHTTPHeaderField: HeaderField.Accept.rawValue)

        retrieve(withRequest: request, success: { (response, data) -> Void in
            do {
                let json = try JSON.decode(data)
                logTrace(try! UTF8.decode(data))
                success(response, json)
            } catch(let error) {
                failure(error)
            }
            },
                 failure: failure,
                 finally: finally
        )
    }

    public static func retrieveImage(withURL url: NSURL,
                                             success: (OSImage) -> Void,
                                             failure: (ErrorType) -> Void,
                                             finally: (() -> Void)? = nil) {

        let request = NSMutableURLRequest()
        request.HTTPMethod = HTTPMethod.GET.rawValue
        request.URL = url

        retrieve(withRequest: request,
                 success: { (response, data) -> Void in
                    if let image = OSImage(data: data) {
                        success(image)
                    } else {
                        failure(HTTPError(response: response))
                    }
            },
                 failure: failure,
                 finally: finally
        )
    }
}
