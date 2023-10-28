import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

enum HTTPSClientError: Error {
    case httpError(statusCode: Int)
}

class HTTPSClient {
    let clientHeaders: [String: String]

    init(clientHeaders: [String: String] = [:]) {
        self.clientHeaders = clientHeaders
    }

    func get(
        url: URL,
        ifNoneMatch: String? = nil,
        onComplete: @escaping (HTTPURLResponse, Foundation.Data?) -> Void = HTTPSClient.defaultOnComplete,
        onError: @escaping (Error) -> Void = HTTPSClient.defaultOnError
    ) {
        request(url: url, method: "GET", ifNoneMatch: ifNoneMatch, onComplete: onComplete, onError: onError)
    }

    func put(
        url: URL, body: Foundation.Data? = nil,
        onComplete: @escaping (HTTPURLResponse, Foundation.Data?) -> Void = HTTPSClient.defaultOnComplete,
        onError: @escaping (Error) -> Void = HTTPSClient.defaultOnError
    ) {
        request(url: url, method: "PUT", body: body, onComplete: onComplete, onError: onError)
    }

    func post(
        url: URL, body: Foundation.Data? = nil,
        onComplete: @escaping (HTTPURLResponse, Foundation.Data?) -> Void = HTTPSClient.defaultOnComplete,
        onError: @escaping (Error) -> Void = HTTPSClient.defaultOnError
    ) {
        request(url: url, method: "POST", body: body, onComplete: onComplete, onError: onError)
    }

    func post(
        url: URL,
        bodyString: String,
        onComplete: @escaping (HTTPURLResponse, Foundation.Data?) -> Void = HTTPSClient.defaultOnComplete,
        onError: @escaping (Error) -> Void = HTTPSClient.defaultOnError
    ) {
        post(url: url, body: bodyString.data(using: .utf8), onComplete: onComplete, onError: onError)
    }

    private static func defaultOnError(_ err: Error) {
        print("Got error: \(err)")
    }

    private static func defaultOnComplete(_ response: HTTPURLResponse, _ data: Foundation.Data?) {
        print("Got response \(response.statusCode)")
        print("Got headers: \(response.allHeaderFields)")
        if let data = data {
            print("DATA", String(decoding: data, as: UTF8.self))
        }
    }

    func request(
        url: URL, method: String,
        ifNoneMatch: String? = nil,
        body: Foundation.Data? = nil,
        onComplete: @escaping (HTTPURLResponse, Foundation.Data?) -> Void = HTTPSClient.defaultOnComplete,
        onError: @escaping (Error) -> Void = HTTPSClient.defaultOnError
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        #if !canImport(FoundationNetworking)
            request.allowsExpensiveNetworkAccess = true
            request.allowsConstrainedNetworkAccess = true
        #endif

        if let ifNoneMatch {
            request.setValue(ifNoneMatch, forHTTPHeaderField: "If-None-Match")
        }

        if let body = body {
            request.setValue("\(String(describing: body.count))", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        for (headerName, headerValue) in clientHeaders {
            request.setValue(headerValue, forHTTPHeaderField: headerName)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                onError(error!)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Could not cast response to HTTPURLResponse: \(String(describing: response))")
            }
            guard httpResponse.statusCode < 400 else {
                let error = HTTPSClientError.httpError(statusCode: httpResponse.statusCode)
                onError(error)
                return
            }
            onComplete(httpResponse, data)
        }

        task.resume()
    }
}
